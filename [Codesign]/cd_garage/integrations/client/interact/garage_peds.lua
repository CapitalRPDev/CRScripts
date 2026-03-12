if not Config.SpawnGaragePeds then return end

GaragePeds = {}

function LoadGaragePeds()
    GaragePeds = {}
    for _, cd in pairs(Config.Locations) do
        GaragePeds[#GaragePeds+1] = {
            spawned = false,
            coords = vector(cd.x_1, cd.y_1, cd.z_1),
            heading = cd.h_2,
            ped_model = `s_m_y_valet_01`
        }
    end
    if Config.GangGarages.ENABLE then
        for _, cd in pairs(Config.GangGarages.Locations) do
            GaragePeds[#GaragePeds+1] = {
                spawned = false,
                coords = vector(cd.coords.x, cd.coords.y, cd.coords.z),
                heading = cd.spawn_coords.w,
                ped_model = `g_m_y_ballaorig_01`

            }
        end
    end
    if Config.Impound.ENABLE then
        for _, cd in pairs(Config.ImpoundLocations) do
            GaragePeds[#GaragePeds+1] = {
                spawned = false,
                coords = vector(cd.coords.x, cd.coords.y, cd.coords.z),
                heading = cd.spawnpoint.h,
                ped_model = `s_m_y_cop_01`
            }
        end
    end
end

LoadGaragePeds()

local function SetPlayerCoordsSafely(ped, coords)
    local x, y, z = coords.x, coords.y, coords.z
    local ground_found = false
    local ground_Z = z
    local attempt = 0

    while not ground_found and attempt < 50 do
        ground_found, ground_Z = GetGroundZFor_3dCoord(x, y, z, true)
        if ground_found and math.abs(ground_Z - z) > 0.1 then
            break
        end

        z = z - 10.0
        attempt = attempt + 1
        Wait(100)
    end
    SetEntityCoords(ped, x, y, ground_Z, false, false, false, true)
end

local function SpawnStaticPed(coords, heading, ped_model)
    RequestModel(ped_model)
    local timeout = 0
    while not HasModelLoaded(ped_model) and timeout <= 50 do
        Wait(0)
        timeout=timeout+1
    end
    local ped = CreatePed(0, ped_model, coords.x, coords.y, coords.z, heading, false, true)
    SetPlayerCoordsSafely(ped, coords)
    SetModelAsNoLongerNeeded(ped_model)
    SetEntityInvincible(ped, true)
    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityCollision(ped, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    ClearPedTasksImmediately(ped)
    return ped
end

local function CheckDuplicatedPed(coords, ped_model)
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then
            local pedModel = GetEntityModel(ped)
            local pedPos = GetEntityCoords(ped)

            if pedModel == ped_model and #(pedPos - coords) < 1.0 then
                SetEntityAsNoLongerNeeded(ped)
                DeleteEntity(ped)
            end
        end
    end
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, pedData in pairs(GaragePeds) do
            local inDistance = false
            local dist = #(playerCoords - pedData.coords)
            if dist < 50.0 then
                inDistance = true
            end
            if not pedData.spawned and inDistance then
                CheckDuplicatedPed(pedData.coords, pedData.ped_model)
                pedData.ped = SpawnStaticPed(pedData.coords, pedData.heading, pedData.ped_model)
                pedData.spawned = true
            elseif pedData.spawned and not inDistance then
                if pedData.ped and DoesEntityExist(pedData.ped) then
                    SetEntityAsNoLongerNeeded(pedData.ped)
                    DeleteEntity(pedData.ped)
                end
                pedData.spawned = false
            end

        end
        Wait(1000)
    end
end)