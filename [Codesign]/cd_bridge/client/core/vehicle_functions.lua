-- Spawns a networked vehicle.
function SpawnNetworkedVehicle(props, coords, playerInVehicle, giveKeys)
    local model = props.model
    if not LoadModel(model) then return end

    local plate = props.plate
    local heading = coords.w or coords.h or 0.0

    local vehicle
    if Cfg.Framework == 'esx' and #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z)) > 424 then
        vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    else
        vehicle = FrameworkCreateVehicle(model, coords)
    end

    if not DoesEntityExist(vehicle) then
        SetModelAsNoLongerNeeded(model)
        return
    end

    -- Networking setup
    EnsureNetworkControl(vehicle)
    RequestEntityCollision(vehicle)
    SetModelAsNoLongerNeeded(model)

    -- Vehicle setup
    SetVehicleOnGroundProperly(vehicle)
    SetEntityHeading(vehicle, heading)
    SetVehicleProperties(vehicle, props)
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleEngineOn(vehicle, true, true, false)

    -- Other setups
    SetVehicleDirtLevel(vehicle, 0.0)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    NetworkFadeInEntity(vehicle, true)

    if playerInVehicle then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end

    if giveKeys then
        GiveVehicleKeys(plate, vehicle)
    end

    return vehicle
end

-- Gets vehicle properties.
function GetVehicleProperties(vehicle)
    if Config.Framework == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'other' then
        -- Add your frameworks getvehicleproperties code here.
    else
        return {
            plate = GetVehiclePlate(vehicle),
            model = GetEntityModel(vehicle),
            bodyHealth = RoundDecimals(GetVehicleBodyHealth(vehicle), 1),
            engineHealth = RoundDecimals(GetVehicleEngineHealth(vehicle), 1),
            fuelLevel = GetFuel(vehicle, GetVehiclePlate(vehicle)),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modSuspension = GetVehicleMod(vehicle, 15),
            modTurbo = IsToggleModOn(vehicle, 18),
            modArmor = GetVehicleMod(vehicle, 16),
        }
    end
end

-- Sets vehicle properties.
function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'qbcore' then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'other' then
        -- Add your frameworks setvehicleproperties code here.
    else
        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
        if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
        if props.fuelLevel then
            SetFuel(vehicle, GetVehiclePlate(vehicle), props.fuelLevel + 0.0)
        end
        if props.modEngine then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        if props.modTransmission then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        if props.modBrakes then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        if props.modSuspension then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        if props.modTurbo ~= nil then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        if props.modArmor then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
    end
end

-- Checks if player is in any vehicle.
function InVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

-- Gets vehicle model hash.
function GetVehicleModelHash(value)
    if not value or value == 0 then return nil end

    if type(value) == 'string' then
        local hash = joaat(value)
        if IsModelValid(hash) and IsModelAVehicle(hash) then
            return hash
        end
        return nil
    end

    if type(value) ~= 'number' then
        return nil
    end

    if IsModelValid(value) and IsModelAVehicle(value) then
        return value
    end

    local entityType = GetEntityType(value)
    if entityType == 2 then
        local model = GetEntityModel(value)
        if model and model ~= 0 and IsModelValid(model) and IsModelAVehicle(model) then
            return model
        end
    end
    return nil
end

-- Gets closest vehicle.
function GetClosestVehicleToPlayer(maxDistance)
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

-- Gets all vehicles in area.
function GetVehiclesInArea(maxDistance)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehiclesInArea = {}

    local maxDistSq = (maxDistance or 1000)^2

    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            local distSq = #(pedCoords - GetEntityCoords(veh))^2

            if distSq <= maxDistSq then
                vehiclesInArea[#vehiclesInArea + 1] = veh
            end
        end
    end
    return vehiclesInArea
end

-- Gets vehicle from license plate.
function GetVehicleFromPlate(plate)
    if type(plate) ~= 'string' or plate == '' then
        return nil
    end

    local vehicles = GetGamePool('CVehicle')

    for cd = 1, #vehicles do
        local veh = vehicles[cd]
        if GetVehiclePlate(veh) == plate then
            return veh
        end
    end
    return nil
end

-- Gets the default vehicle label.
function GetDefaultVehicleLabel(value)
    local model = GetVehicleModelHash(value)

    if not model then
        return Locale('vehicle')
    end

    local label = GetDisplayNameFromVehicleModel(model)
    if not label or label == 'NULL' then
        return Locale('vehicle')
    end

    label = label:lower()
    if label == 'null' or label == 'carnotfound' then
        return Locale('vehicle')
    end

    local text = GetLabelText(label)
    if text and text ~= 'NULL' and text ~= label then
        return CapitalizeFirstLetter(text)
    end
    return CapitalizeFirstLetter(label)
end

-- Checks if vehicle is empty.
function IsVehicleEmpty(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return false
    end
    return GetVehicleNumberOfPassengers(vehicle) == 0 and IsVehicleSeatFree(vehicle, -1)
end

-- Gets vehicles license plate.
function GetVehiclePlate(vehicle)
    if not vehicle then
        if InVehicle() then
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        else
            return
        end
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

-- Gets players in vehicle, returning server id's.
function GetPlayersInVehicle(vehicle, includeSelf)
    local temp_table = {}
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    local vehicle_coords = GetEntityCoords(vehicle)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetped = GetPlayerPed(playerId)
        if targetped and targetped ~= 0 then
            if includeSelf or playerId ~= PlayerId() then
                local pcoords = GetEntityCoords(targetped)
                local dist = #(vehicle_coords - pcoords)

                if dist < 10.0 then
                    local ped_vehicle = GetVehiclePedIsIn(targetped, false)
                    if ped_vehicle == vehicle then
                        temp_table[#temp_table + 1] = GetPlayerServerId(playerId)
                    end
                end
            end
        end
    end
    if next(temp_table) == nil then
        return nil
    else
        return temp_table
    end
end

-- Kicks players out of vehicle.
function KickPlayersOutOfVehicle(vehicle, forceKickout)
    local playersInVehicle = GetPlayersInVehicle(vehicle, true)
    if playersInVehicle then
        exports.cd_bridge:Callback('cd_bridge:KickOutPlayersInVehicle', playersInVehicle,  forceKickout, NetworkGetNetworkIdFromEntity(vehicle))
    end
    return playersInVehicle
end

-- Despawns a networked vehicle.
function DespawnNetworkedVehicle(vehicle, forceKickout)
    if not DoesEntityExist(vehicle) then return end
    local plate = GetVehiclePlate(vehicle)

    UnRegisterPersistentVehicle(vehicle, plate)
    KickPlayersOutOfVehicle(vehicle, forceKickout)
    EnsureNetworkControl(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
        SetEntityAsNoLongerNeeded(vehicle)
    end
end

-- Gets closest vehicle at coords.
function GetClosestVehicleAtCoords(coords, distance)
    local closestVehicle = false
    local closestDistance = distance

    local vehicles = GetGamePool('CVehicle')
    for cd = 1, #vehicles do
        local veh = vehicles[cd]
        local vehCoords = GetEntityCoords(veh)
        local dist = #(coords - vehCoords)

        if dist < closestDistance then
            closestDistance = dist
            closestVehicle = veh
        end
    end

    return closestVehicle
end

-- Checks if spawn area is blocked.
function IsSpawnAreaBlocked(coords, radius, myveh)
    local vehicles = GetGamePool('CVehicle')
    local closestDist = nil
    for cd = 1, #vehicles do
        local veh = vehicles[cd]
        if veh ~= myveh then
            local dist = #(coords - GetEntityCoords(veh))
            if dist < radius then
                if not closestDist or dist < closestDist then
                    closestDist = dist
                end
            end
        end
    end
    return closestDist ~= nil
end

-- Teleports vehicle to safe coords.
function TeleportVehicleToSafeCoords(veh, coords)
    if not veh or veh == 0 or not DoesEntityExist(veh) then
        return false
    end

    local attempts = 4
    local radius = 3.0
    local step = 6.0

    local newCoords = coords
    local forward = GetEntityForwardVector(veh)

    for _ = 1, attempts do
        local blocked = IsSpawnAreaBlocked(newCoords, radius, veh)
        if not blocked then
            SetEntityCoords(veh, newCoords.x, newCoords.y, newCoords.z, false, false, false, false)
            return true
        end

        newCoords = newCoords + (forward * step)
        SetEntityCoords(veh, newCoords.x, newCoords.y, newCoords.z, false, false, false, false)
        Wait(0)
    end
    return false
end