function CheckVehicleOnStreets(plate, in_garage, model)
    local onStreetsServerCheck = exports.cd_bridge:Callback('cd_garage:onstreetscheck', {plate = plate, shell_coords = shell_coords})
    if onStreetsServerCheck then
        SetNewWaypoint(onStreetsServerCheck.coords.x, onStreetsServerCheck.coords.y)
        return onStreetsServerCheck
    else
        if not in_garage then
            if Config.Return_Vehicle.ENABLE then
                local return_price = GetReturnVehiclePrice(model)
                return {result = 'outbutnotonstreets', message = Locale('return_vehicle')..''..return_price, return_price = return_price}
            else
                return {result = 'outbutnotonstreets', message = Locale('return_vehicle_disabled'), return_price = ''}
            end
        end
    end
    return {result = 'canspawn'}
end

function GetClosestVehicleData(coords, distance)
    local t = {}
    t.dist = distance
    t.state = false
    local vehicle = GetGamePool('CVehicle')
    local smallest_distance = 1000
    for cd = 1, #vehicle, 1 do
        local vehcoords = GetEntityCoords(vehicle[cd])
        local dist = #(coords-vehcoords)
        if dist < t.dist and dist < smallest_distance then
            smallest_distance = dist
            t.dist = dist
            t.vehicle = vehicle[cd]
            t.coords = vehcoords
            t.state = true
        end
    end
    t.dist = nil
    return t
end

function FindVehicleInArea(coords, distance, plate)
    local result = false
    local vehicle = GetGamePool('CVehicle')
    for cd = 1, #vehicle, 1 do
        local veh_coords = GetEntityCoords(vehicle[cd])
        local veh_plate = GetCorrectPlateFormat(GetVehicleNumberPlateText(vehicle[cd]))
        local dist = #(coords-veh_coords)
        if dist < distance and plate == veh_plate then
            result = true
        end
    end
    return result
end

-- will be moved to cd_bridge soon.
function GetPlayersInVehicle(vehicle)
    local temp_table = {}
    local vehicle_coords = GetEntityCoords(vehicle)
    for c, d in pairs(GetActivePlayers()) do
        local targetped = GetPlayerPed(d)
        local dist = #(vehicle_coords-GetEntityCoords(vehicle))
        if dist < 10 then
            local ped_vehicle = GetVehiclePedIsIn(targetped)
            if ped_vehicle == vehicle then
                table.insert(temp_table, GetPlayerServerId(d))  
            end
        end
    end
    return temp_table
end

-- will be moved to cd_bridge soon.
function GetClosestVehicle_pileupcheck(coords, distance, myveh)
    local vehicles = GetGamePool('CVehicle')
    for cd = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[cd])
        local dist = #(coords-vehicleCoords)
        if dist < distance and vehicles[cd] ~= myveh then
            return true
        end
    end
    return false
end

-- will be moved to cd_bridge soon.
function CheckSpawnArea(veh, coords)
    local new_coords = coords
    local forward = GetEntityForwardVector(veh)

    for cd = 1, 4 do
        local vehicle = GetClosestVehicle_pileupcheck(new_coords, 3, veh)
        if vehicle then
            new_coords = new_coords + forward * 6.0
            SetEntityCoords(veh, new_coords.x, new_coords.y, new_coords.z)
        else
            return
        end
    end
end

-- will be moved to cd_bridge soon.
function CD_DeleteVehicle(vehicle)
    if vehicle ~= nil then
        if not DoesEntityExist(vehicle) then
            Notif(3, 'entity_doesnot_exist')
            return
        end
        RemovePersistentVehicle(vehicle, GetPlate(vehicle))
        RequestNetworkControl(vehicle)
        RequestNetworkId(vehicle)
        if NetworkHasControlOfEntity(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            Wait(100)
            Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
            SetEntityAsNoLongerNeeded(vehicle)
            DeleteEntity(vehicle)
            DeleteVehicle(vehicle)
        else
            TriggerServerEvent('cd_garage:DeleteVehicleADV', NetworkGetNetworkIdFromEntity(vehicle))
        end
    end
end

-- will be moved to cd_bridge soon.
RegisterNetEvent('cd_garage:DeleteVehicleADV')
AddEventHandler('cd_garage:DeleteVehicleADV', function(net)
    local entity = NetworkGetEntityFromNetworkId(net)
    if NetworkHasControlOfEntity(entity) then
        SetEntityAsNoLongerNeeded(entity)
        Wait(100)
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
        DeleteEntity(entity)
        DeleteVehicle(entity)
    else
        Notif(3, 'no_control_netid')
    end
end)

-- will be moved to cd_bridge soon.
function GetClosestVehicle(maxDistance)
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end

    local pedCoords = GetEntityCoords(ped)
    local closestVeh, closestDist = nil, maxDistance or 1000

    local vehicles = GetGamePool('CVehicle')

    for cd = 1, #vehicles do
        local veh = vehicles[cd]

        if DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            local dist = #(pedCoords - vehCoords)

            if dist < closestDist then
                closestDist = dist
                closestVeh = veh
            end
        end
    end
    return closestVeh or false
end