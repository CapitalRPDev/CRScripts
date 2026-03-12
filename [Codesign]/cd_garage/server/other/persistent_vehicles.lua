if not Config.PersistentVehicles.ENABLE then return end

PersistentVehiclesTable = {}

RegisterCommand('persistent_removeall', function(source)
    if source == 0 then
        PersistentVehiclesTable = {}
        DB.exec('UPDATE cd_garage_persistentvehicles SET persistent = "{}"')
        print('Cleared all persistent vehicles.')
    end
end, true)

RegisterServerEvent('cd_garage:AddPersistentVehicles')
AddEventHandler('cd_garage:AddPersistentVehicles', function(plate, netid, job_vehicle)
    local _source = source
    if not plate and not netid then return end
    local plate = GetCorrectPlateFormat(plate)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    if PersistentVehiclesTable[plate] == nil then
        PersistentVehiclesTable[plate] = {}
        PersistentVehiclesTable[plate].plate = plate
    end
    PersistentVehiclesTable[plate].netid = netid
    PersistentVehiclesTable[plate].coords = GetEntityCoords(vehicle)
    PersistentVehiclesTable[plate].heading = GetEntityHeading(vehicle)
    PersistentVehiclesTable[plate].identifier = GetIdentifier(_source)
    if job_vehicle then
        PersistentVehiclesTable[plate].job_vehicle = job_vehicle
    end
    TriggerClientEvent('cd_garage:PersistentVehicles_GetVehicleProperties', _source, plate, netid)
end)

RegisterNetEvent('cd_garage:RemovePersistentVehicles')
AddEventHandler('cd_garage:RemovePersistentVehicles', function(plate)
    if not plate then return end
    plate = GetCorrectPlateFormat(plate)
    PersistentVehiclesTable[plate] = nil
end)

RegisterNetEvent('cd_garage:PlateChangedPersistentVehicles', function(old_plate, new_plate)
    if not old_plate or not new_plate then return end
    local old_plate = GetCorrectPlateFormat(old_plate)
    local new_plate = GetCorrectPlateFormat(new_plate)
    if not PersistentVehiclesTable[old_plate] then return end
    local data = json.decode(json.encode(PersistentVehiclesTable[old_plate]))
    PersistentVehiclesTable[old_plate] = nil
    PersistentVehiclesTable[new_plate] = data
    PersistentVehiclesTable[new_plate].plate = new_plate
    PersistentVehiclesTable[new_plate].props.plate = new_plate
end)

local loop_is_going = false
function PersistentVehicle_FakePlate(old_plate, new_plate)
    CreateThread(function()
        while loop_is_going do Wait(10) end
        if not PersistentVehiclesTable[old_plate] then return end
        local data = json.decode(json.encode(PersistentVehiclesTable[old_plate]))
        PersistentVehiclesTable[old_plate] = nil
        PersistentVehiclesTable[new_plate] = data
        PersistentVehiclesTable[new_plate].plate = new_plate
        PersistentVehiclesTable[new_plate].props.plate = new_plate
        PersistentVehiclesTable[new_plate].fakeplate = true
    end)
end

CreateThread(function()
    Wait(1000)
    while true do
        loop_is_going = true
        local allVehicles = GetAllVehicles()
        for cd = 1, #allVehicles, 1 do
            local vehicle = allVehicles[cd]
            if DoesEntityExist(vehicle) then
                local plate = GetCorrectPlateFormat(GetVehicleNumberPlateText(vehicle))
                local persistData = PersistentVehiclesTable[plate]
                if persistData then
                    persistData.has_despawned = false
                    local coords = GetEntityCoords(vehicle)
                    persistData.coords = coords
                    persistData.heading = GetEntityHeading(vehicle)
                    persistData.lock_state = GetVehicleDoorLockStatus(vehicle)
                end
            end
        end
        local temp_table = {}
        for c, d in pairs(PersistentVehiclesTable) do
            if d.has_despawned == nil then
                d.has_despawned = true
                temp_table[#temp_table+1] = d
            else
                d.has_despawned = nil
            end
        end

        if #temp_table > 0 then
            RespawnVehicle(temp_table)
        end
        loop_is_going = false
        Wait(5000)
    end
end)

function RespawnVehicle(data)
    local allPlayers = GetPlayers()
    local proximityCheckDistance = 20.0
    local maxSpawnDistance = 424.0

    local playerCoords = {}
    for i = 1, #allPlayers do
        playerCoords[allPlayers[i]] = GetEntityCoords(GetPlayerPed(allPlayers[i]))
    end

    for i = 1, #data do
        local vehData = data[i]
        local closestPlayer = nil
        local smallestDistance = maxSpawnDistance + 1

        for _, playerId in ipairs(allPlayers) do
            local playerPos = playerCoords[playerId]
            local dist = #(playerPos - vector3(vehData.coords.x, vehData.coords.y, vehData.coords.z))

            if dist < proximityCheckDistance and dist < smallestDistance then
                smallestDistance = dist
                closestPlayer = playerId
            end
        end

        if closestPlayer then
            TriggerClientEvent('cd_garage:PersistentVehicles_SpawnVehicle', closestPlayer, vehData)
            if PersistentVehiclesTable[vehData.plate] then
                PersistentVehiclesTable[vehData.plate].has_despawned = nil
            end
        end
    end
end


RegisterServerEvent('cd_garage:PersistentVehicles_GetVehicleProperties')
AddEventHandler('cd_garage:PersistentVehicles_GetVehicleProperties', function(plate, props)
    PersistentVehiclesTable[plate].props = props
end)