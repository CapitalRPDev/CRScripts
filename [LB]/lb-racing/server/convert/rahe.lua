if not Config.Convert then
    return
end

local scriptName = "rahe_racing"

MySQL.ready.await()

while not DatabaseCheckerFinished do
    Wait(500)
end

local converted = MySQL.scalar.await("SELECT 1 FROM lbracing_converted_scripts WHERE script_name = ?", { scriptName }) ~= nil

if converted then
    return debugprint("Rahe Racing has already been converted. Delete 'rahe' from the lbracing_converted_scripts database (sql) table to convert all data again.")
end

local database = MySQL.scalar.await("SELECT DATABASE()")

if not database then
    return infoprint("error", "Rahe Convert - Failed to get database name.")
end

local hasRaheRacing = MySQL.scalar.await(
    "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?",
    { database, "ra_racing_tracks" }
) ~= nil

if not hasRaheRacing then
    return debugprint("Rahe Racing tables do not exist, skipping conversion.")
end

infoprint("info", "Converting data from Rahe Racing.")

local function ConvertAccounts()
    MySQL.rawExecute.await([[
        INSERT INTO lbracing_accounts (id, username, avatar, rating, races_won, races_played, created_at)
        SELECT
            player_identifier,
            alias,
            profile_picture,
            rating,
            (SELECT COUNT(1) FROM ra_racing_results r WHERE r.player_identifier = u.player_identifier AND r.`position` = 1),
            (SELECT COUNT(1) FROM ra_racing_results r WHERE r.player_identifier = u.player_identifier),
            created_at

        FROM ra_racing_user_settings u

        ON DUPLICATE KEY UPDATE id = id
    ]])

    MySQL.rawExecute.await("UPDATE lbracing_accounts SET avatar = NULL WHERE avatar = 'https://media.rahe.dev/img/defaultprofile.webp'")
end

ConvertAccounts()

---@alias RawRaheTrack { id: number, creator_identifier: string, name: string, description: string, type: "CIRCUIT" | "SPRINT", checkpoints: string, objects: string, is_verified: number, is_deleted: number, created_at: number }

local newTrackIdLookup = {}
local tracks = MySQL.query.await("SELECT * FROM ra_racing_tracks") --[[@as RawRaheTrack[] ]]

---@param track RawRaheTrack
local function ConvertTrack(track)
    local checkpoints = json.decode(track.checkpoints) --[[@as { blip: number, coords: { x: number, y: number, z: number } }[] ]]
    local barriers = json.decode(track.objects) --[[@as { objectId: number, rotation: { x: number, y: number, z: number }, coords: { x: number, y: number, z: number }, hash: string }[] ]]

    ---@type Vector3Array[]
    local encodedCheckpoints = {}
    ---@type vector3[]
    local formattedCheckpoints = {}

    for i = 1, #checkpoints do
        local coords = checkpoints[i].coords

        formattedCheckpoints[i] = vector3(coords.x, coords.y, coords.z)
        encodedCheckpoints[i] = VectorToArray(formattedCheckpoints[i]) --[[@as Vector3Array]]
    end

    ---@type [Vector4Array, number][]
    local encodedBarriers = {}
    local formattedBarriers = {}

    for i = 1, #barriers do
        local barrier = barriers[i]
        local model = type(barrier.hash) == "string" and joaat(barrier.hash) or barrier.hash
        local heading = barrier.rotation and barrier.rotation.z or 0.0

        formattedBarriers[i] = {
            coords = vector4(barrier.coords.x, barrier.coords.y, barrier.coords.z, heading),
            model = model,
        }

        encodedBarriers[i] = {
            VectorToArray(formattedBarriers[i].coords) --[[@as Vector4Array]],
            formattedBarriers[i].model,
        }
    end

    ---@type NewTrackData
    local formattedTrack = {
        id = 0, -- set after inserting
        creator = {
            id = track.creator_identifier or "",
        },
        name = track.name or "Unknown",
        vehicleType = "car",
        trackType = track.type == "CIRCUIT" and "circuit" or "sprint",
        startPosition = formattedCheckpoints[1],
        checkpoints = formattedCheckpoints,
        barriers = formattedBarriers,
        uses = 0,
        createdAt = track.created_at,
        length = GetTrackLength(track.type == "CIRCUIT" and "circuit" or "sprint", formattedCheckpoints),
    }

    local newId = MySQL.insert.await([[
        INSERT INTO lbracing_tracks (creator, track_name, vehicle_type, track_type, track_length, start_position, checkpoints, barriers, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?))
    ]], {
        formattedTrack.creator.id,
        formattedTrack.name,
        formattedTrack.vehicleType,
        formattedTrack.trackType,
        formattedTrack.length,
        json.encode(encodedCheckpoints[1]),
        json.encode(encodedCheckpoints),
        json.encode(encodedBarriers),
        math.floor(formattedTrack.createdAt / 1000)
    })

    formattedTrack.id = newId
    newTrackIdLookup[track.id] = newId

    AddTrack(formattedTrack)
end

for i = 1, #tracks do
    ConvertTrack(tracks[i])
end

---@alias RawRaheRace { id: number, track_id: number, started_by_identifier: string, participant_amount: number, is_competition: number, prize_money: number, start_time?: number, vehicle_class: string, lap_amount: number, finished_at?: number}

local newRaceIdLookup = {}
local races = MySQL.query.await("SELECT * FROM ra_racing_races") --[[@as RawRaheRace[] ]]

---@param race RawRaheRace
local function ConvertRace(race)
    local trackId = newTrackIdLookup[race.track_id] or 0
    local vehicleTiers

    if race.vehicle_class and #race.vehicle_class == 1 then
        vehicleTiers = json.encode({ race.vehicle_class })
    end

    local startTime = race.start_time or race.finished_at

    if not startTime then
        return debugprint("Rahe Racing - no start time for race, skipping.")
    end

    local currentTime = os.time()
    local createdAt = math.min(math.floor(startTime / 1000) - 600, currentTime)
    local track = GetTrack(trackId)

    if not track then
        return debugprint("Rahe Racing - track not found")
    end

    local newRaceId = MySQL.insert.await(
        "INSERT INTO lbracing_races (host, race_name, track_id, vehicle_tiers, laps, starting_prize, entry_fee, commission, participants, min_participants, max_participants, prize_distribution, invite_only, start_date, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?), FROM_UNIXTIME(?))",
        {
            race.started_by_identifier,
            track.name,
            trackId,
            vehicleTiers,
            race.lap_amount,
            race.prize_money,
            0,
            0,
            race.participant_amount,
            2,
            math.max(race.participant_amount, 24),
            json.encode({ 100 }),
            0,
            math.floor(startTime / 1000),
            createdAt
        }
    )

    newRaceIdLookup[race.id] = newRaceId
end

for i = 1, #races do
    ConvertRace(races[i])
end

---@alias RawRaheResult { id: number, race_id: number, track_id: number, player_identifier: string, position: number, prize_money: number, rating_gain: number, vehicle_model: string, vehicle_model_name: string, vehicle_class: string, best_time: string, best_time_string: string, total_time: string, total_time_string: string, finished_at: number }

local results = MySQL.query.await("SELECT * FROM ra_racing_results") --[[@as RawRaheResult[] ]]

---@param result RawRaheResult
local function ConvertResult(result)
    local raceId = newRaceIdLookup[result.race_id]

    if not raceId then
        return
    end

    local vehicleTier = result.vehicle_class ~= "DNF" and result.vehicle_class or nil
    local vehicleModel = result.vehicle_model ~= "DNF" and tonumber(result.vehicle_model) or nil

    MySQL.update(
        "INSERT INTO lbracing_race_participants (race_id, participant_id, vehicle_tier, vehicle_model, placing, rating_change, finish_time) VALUES (?, ?, ?, ?, ?, ?, ?)",
        {
            raceId,
            result.player_identifier,
            vehicleTier,
            vehicleModel,
            result.position,
            result.rating_gain,
            result.total_time
        }
    )
end

for i = 1, #results do
    ConvertResult(results[i])
end

MySQL.update.await("INSERT INTO lbracing_converted_scripts (script_name) VALUES (?)", { scriptName })

infoprint("success", "Converted data from Rahe Racing.")
