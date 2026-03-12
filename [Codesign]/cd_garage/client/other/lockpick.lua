if not Config.VehicleKeys.ENABLE or not Config.VehicleKeys.Lockpick.ENABLE then return end

if Config.VehicleKeys.Lockpick.command.ENABLE then
    TriggerEvent('chat:addSuggestion', '/'..Config.VehicleKeys.Lockpick.command.chat_command, Locale('chatsuggestion_lockpick'))
    RegisterCommand(Config.VehicleKeys.Lockpick.command.chat_command, function()
        TriggerEvent('cd_garage:LockpickVehicle', false)
    end, false)
end

local doing_animation = false
local function LockpickAnimation(vehicle)
    doing_animation = true
    CreateThread(function()
        local ped = PlayerPedId()
        TaskTurnPedToFaceEntity(ped, vehicle, 1000)
        RequestAnimDict('veh@break_in@0h@p_m_one@')
        while not HasAnimDictLoaded('veh@break_in@0h@p_m_one@') do Wait(0) end
        FreezeEntityPosition(ped, true)
        while doing_animation do
            TaskPlayAnim(ped, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 2.0, -2.0, -1, 1, 0, 0, 0, 0 )
            Wait(1000)
            ClearPedTasks(ped)
        end
        FreezeEntityPosition(ped, false)
        RemoveAnimDict('veh@break_in@0h@p_m_one@')
    end)
end

local function startCarAlarm(vehicle)
    CreateThread(function()
        StartVehicleAlarm(vehicle)
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, 1*60*1000) --2 mins
        SetVehicleIndicatorLights(vehicle, 1, true)
        SetVehicleIndicatorLights(vehicle, 0, true)
        for cd = 1, 60 do
            SetVehicleLights(vehicle, 2)
            Wait(500)
            SetVehicleLights(vehicle, 0)
            Wait(500)
        end
        SetVehicleIndicatorLights(vehicle, 1, false)
        SetVehicleIndicatorLights(vehicle, 0, false)
    end)
end

RegisterNetEvent('cd_garage:LockpickVehicle')
AddEventHandler('cd_garage:LockpickVehicle', function(used_usable_item)
    local vehicle = GetClosestVehicleToPlayer(5)
    if vehicle then
        local plate = GetPlate(vehicle)
        CacheVehicle(plate, vehicle)
        if not KeysTable[plate].has_key then
            local lock = GetVehicleDoorLockStatus(vehicle)
            if lock > 1 then
                if used_usable_item then
                    TriggerServerEvent('cd_garage:LockpickVehicle:RemoveItem')
                end
                LockpickAnimation(vehicle)
                startCarAlarm(vehicle)
                local hacking = exports['cd_keymaster']:StartKeyMaster()
                if hacking then
                    UnLockVehicle(vehicle, false, false, true)
                else
                    Notif(3, 'lockpicking_failed')
                end
                ClearPedTasks(PlayerPedId())
                doing_animation = false
            else
                Notif(3, 'vehicle_not_locked')
            end
        else
            Notif(3, 'cant_lockpick_have_keys')
        end
    else
        Notif(3, 'no_vehicle_found')
    end
end)