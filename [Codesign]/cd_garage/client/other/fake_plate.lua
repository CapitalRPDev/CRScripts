if Config.FakePlates.ENABLE then

    if Config.FakePlates.RemovePlate.chat_command then
        TriggerEvent('chat:addSuggestion', '/'..Config.FakePlates.RemovePlate.chat_command, Locale('chatsuggestion_fakeplate'))
        RegisterCommand(Config.FakePlates.RemovePlate.chat_command, function()
            TriggerEvent('cd_garage:FakePlate', 'remove')
        end, false)
    end

    RegisterNetEvent('cd_garage:FakePlate')
    AddEventHandler('cd_garage:FakePlate', function(action, generatedFakePlate)
        local ped = PlayerPedId()
        if not InVehicle() then
            local vehicle = GetClosestVehicleToPlayer(5)
            if vehicle then
                local current_plate = GetPlate(vehicle)
                if action == 'add' then
                    TaskTurnPedToFaceEntity(ped, vehicle, 1000)
                    Wait(1000)
                    TriggerServerEvent('cd_garage:FakePlate', action, current_plate, vehicle, generatedFakePlate)

                elseif action == 'remove' then
                    TriggerServerEvent('cd_garage:FakePlate', action, current_plate, vehicle)
                end
                ClearPedTasks(ped)
            else
                Notif(3, 'no_vehicle_found')
            end
        else
            Notif(3, 'get_out_veh')
        end
    end)

    RegisterNetEvent('cd_garage:FakePlate_change')
    AddEventHandler('cd_garage:FakePlate_change', function(action, vehicle, plate)
        SetVehicleNumberPlateText(vehicle, plate)
        if action == 'add' then
            GiveVehicleKeys(plate, vehicle)
        end
    end)
    
end
