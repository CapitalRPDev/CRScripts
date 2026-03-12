function OnStreetsCheck(data)
    local plate = GetCorrectPlateFormat(data.plate)
    for c, d in pairs(GetAllVehicles()) do
        if DoesEntityExist(d) then
            if GetCorrectPlateFormat(GetVehicleNumberPlateText(d)) == plate then
                local coords = GetEntityCoords(d)
                if data.shell_coords and GetVehicleEngineHealth(d) > 0 then
                    local dist = #(vector3(coords.x, coords.y, coords.z)-vector3(data.shell_coords.x, data.shell_coords.y, data.shell_coords.z))
                    if dist > 30 then
                        return {result = 'onstreets', message = Locale('vehicle_onstreets'), coords = coords}
                    end
                else
                    local canSpawn = not Config.CanSpawnWhenDestroyed
                    local isDestroyed = GetVehicleEngineHealth(d) < 0.0

                    if canSpawn and isDestroyed then
                        return {result = 'onstreets', message = Locale('vehicle_onstreets_destroyed'), coords = coords}
                    end

                    if not canSpawn and isDestroyed then
                        return nil
                    end

                    return {result = 'onstreets', message = Locale('vehicle_onstreets'), coords = coords}
                end
            end
        end
    end
end

function IsPedInVehicle(source)
    local ped = GetPlayerPed(source)
    local inVehicle = GetVehiclePedIsIn(ped, false)
    if inVehicle then
        return true
    else
        return false
    end
end

function GetClosestVehicle(source, distance)
    local ped = GetPlayerPed(source)
    if IsPedInVehicle(source) then
        return GetVehiclePedIsIn(ped, false)
    else
        local result = false
        local ped_coords = GetEntityCoords(ped)
        local smallest_distance = 1000
        local vehicle = GetAllVehicles()
        for cd = 1, #vehicle, 1 do
            local vehcoords = GetEntityCoords(vehicle[cd])
            local dist = #(ped_coords-vehcoords)
            if dist < distance and dist < smallest_distance then
                smallest_distance = dist
                result = vehicle[cd]
            end
        end
        return result
    end
end

function HasVehicleAlreadySpawned(plate, persistant)
    if persistant then
        return false
    end

    local fakeData = FakePlateTable and FakePlateTable[plate]
    if fakeData and fakeData.originalplate then
        plate = fakeData.originalplate
    end

    local result = DB.exec('UPDATE '..FW.vehicle_table..' SET in_garage = 0 WHERE in_garage = 1 AND plate = "'..plate..'";')
    if result and result.affectedRows == 1 then
        return false
    else
        return true
    end
end

-- will be moved to cd_bridge soon.
RegisterServerEvent('cd_garage:DeleteVehicleADV')
AddEventHandler('cd_garage:DeleteVehicleADV', function(net)
    TriggerClientEvent('cd_garage:DeleteVehicleADV', source, net)
end)