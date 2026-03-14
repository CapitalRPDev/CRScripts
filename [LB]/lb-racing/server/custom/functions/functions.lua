---@param identifier string
---@param title string
---@param content? string
---@param customData? table
function SendNotification(identifier, title, content, customData)
    local notification = customData or {}

    notification.app = "lb-racing"
    notification.title = title
    notification.content = content

    if GetResourceState("lb-phone") == "started" and Config.App.LBPhone then
        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(identifier)

        if phoneNumber then
            local success, errorMessage = pcall(function()
                exports["lb-phone"]:SendNotification(phoneNumber, notification)
            end)

            if not success then
                debugprint("lb-phone notification error: " .. errorMessage)
            end
        end
    end

    if GetResourceState("lb-tablet") == "started" and Config.App.LBTablet then
        local tabletId = exports["lb-tablet"]:GetEquippedTablet(identifier)

        if tabletId then
            notification.tabletId = tabletId

            local success, errorMessage = pcall(function()
                exports["lb-tablet"]:SendNotification(notification)
            end)

            if not success then
                debugprint("lb-tablet notification error: " .. errorMessage)
            end
        end
    end
end

---@param source number
---@param message string
---@param level? "info" | "success" | "warning" | "error"
---@param title? string
function NotifyPlayer(source, message, level, title)
    TriggerClientEvent("lb-racing:notify", source, message, level, title)
end

---@param source number
---@param title string
---@param content? string
---@param customData? table
function AppNotifyPlayer(source, title, content, customData)
    TriggerClientEvent("lb-racing:notifyDevices", source, title, content, customData)
end

---@param identifier string
---@param amount number
---@param title string
function LogTransaction(identifier, amount, title)
    amount = math.floor(amount + 0.5)

    if GetResourceState("lb-phone") == "started" then
        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(identifier)

        if phoneNumber then
            exports["lb-phone"]:AddTransaction(phoneNumber, amount, title)
        end
    end
end

function GetRandomTrackId()
    ---@type number | nil
    return MySQL.scalar.await([[
        SELECT track.id

        FROM lbracing_tracks track

        WHERE NOT EXISTS (
            SELECT 1
            FROM lbracing_races race
            WHERE
                race.track_id = track.id
                AND not race.finished
                AND NOT race.canceled
                AND TIME_TO_SEC(TIMEDIFF(NOW(), race.start_date)) < ?
            )

        ORDER BY RAND()

        LIMIT 1
    ]], { (Config.AutoStart + Config.Countdown) * 2 })
end

---@param model number
---@param coords vector3
function SpawnVehicle(model, coords)
    local vehicleType

    for _, class in pairs(Config.VehicleClasses) do
        for _, vehicle in pairs(class) do
            if vehicle.model == model then
                vehicleType = vehicle.type
                break
            end
        end
    end

	local vehicle = CreateVehicleServerSetter(model, vehicleType or "automobile", coords.x, coords.y, coords.z, 0.0)
	local timer = GetGameTimer() + 5000

	while not DoesEntityExist(vehicle) do
		Wait(0)

		if GetGameTimer() > timer then
            DeleteEntity(vehicle)

			infoprint("error", "Vehicle failed to spawn after 5s")
			return
		end
	end

	return vehicle
end

---@param source number
---@param vehicle number
function GiveVehicleKeys(source, vehicle)
    if GetResourceState("qbx_vehiclekeys") == "started" then
        exports.qbx_vehiclekeys:GiveKeys(source, vehicle, true)
    end
end

---@param bucketId number
function IsRoutingBucketEmpty(bucketId)
    local players = GetPlayers()
    local empty = true

    for i = 1, #players do
        local src = players[i]

        if GetPlayerRoutingBucket(src) == bucketId then
            empty = false

            break
        end
    end

    return empty
end

---@param raceId number
function GetBucketForRace(raceId)
    local bucketId = raceId

    while not IsRoutingBucketEmpty(bucketId) do
        bucketId += 1
    end

    return bucketId
end
