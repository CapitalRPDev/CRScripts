if not Config.VehicleKeys.ENABLE or not Config.VehicleKeys.Lock.ENABLE then return end

RegisterKeyMapping(Config.VehicleKeys.Lock.command, Locale('chatsuggestion_vehiclelock'), 'keyboard', Config.VehicleKeys.Lock.key)
TriggerEvent('chat:addSuggestion', '/'..Config.VehicleKeys.Lock.command, Locale('chatsuggestion_vehiclelock'))
RegisterCommand(Config.VehicleKeys.Lock.command, function()
    TriggerEvent('cd_garage:ToggleVehicleLock')
end, false)

function LockVehicle(vehicle, play_animation, notify, lights)
    if not InVehicle() and play_animation then
        PlayAnimation('mp_common', 'givetake1_a', 1000)
    end
    if notify then
        Notif(3, 'vehicle_locked')
    end
    if lights then
        LockLights(2, vehicle)
    end
    TriggerServerEvent('cd_garage:SetVehicleLockState', NetworkGetNetworkIdFromEntity(vehicle), 2)
end

function UnLockVehicle(vehicle, play_animation, notify, lights)
    if not InVehicle() and play_animation then
        PlayAnimation('mp_common', 'givetake1_a', 1000)
    end
    if notify then
        Notif(1, 'vehicle_unlocked')
    end
    if lights then
        LockLights(1, vehicle)
    end
    TriggerServerEvent('cd_garage:SetVehicleLockState', NetworkGetNetworkIdFromEntity(vehicle), 0)
end

RegisterNetEvent('cd_garage:SetVehicleLocked', function(vehicle)
    LockVehicle(vehicle, false, false, false)
end)

RegisterNetEvent('cd_garage:SetVehicleUnlocked', function(vehicle)
    UnLockVehicle(vehicle, false, false, false)
end)

if Config.VehicleKeys.Lock.lock_from_inside then
    CreateThread(function()
        while true do
            Wait(500)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if InVehicle() and (GetVehicleDoorLockStatus(vehicle) == 2) then
                SetVehicleDoorsLocked(vehicle, 4)
            end
        end
    end)
end

local cooldown = false
RegisterNetEvent('cd_garage:ToggleVehicleLock', function()
    if not cooldown then
        local vehicle = GetClosestVehicleToPlayer(5)
        if vehicle then
            local plate = GetPlate(vehicle)
            CacheVehicle(plate, vehicle)
            if KeysTable[plate].has_key then
                local lock = GetVehicleDoorLockStatus(vehicle)
                cooldown = true
                if lock == 0 or lock == 1 then
                    LockVehicle(vehicle, true, true, true)
                elseif lock == 2 or lock == 4 then
                    UnLockVehicle(vehicle, true, true, true)
                end
                Wait(500)
                cooldown = false
            else
                Notif(3, 'no_keys')
            end
        else
            Notif(3, 'no_vehicle_found')
        end
    else
        Notif(3, 'lock_cooldown')
    end
end)

function LockLights(state, vehicle)
    CreateThread(function()
        LockDoorSound()
        if state == 2 then
            SetVehicleInteriorlight(vehicle, false)
            SetVehicleLights(vehicle, 2)
            Wait(500)
            SetVehicleLights(vehicle, 0)
            Wait(500)
            SetVehicleLights(vehicle, 2)
            Wait(2000)
            SetVehicleLights(vehicle, 0)
        elseif state == 1 then
            SetVehicleInteriorlight(vehicle, true)
            SetVehicleLights(vehicle, 2)
            Wait(500)
            SetVehicleLights(vehicle, 0)
            Wait(500)
            SetVehicleLights(vehicle, 2)
            Wait(500)
            SetVehicleLights(vehicle, 0)
        end
    end)
end