if Config.TransferVehicle.ENABLE then

    if Config.TransferVehicle.chat_command then
        TriggerEvent('chat:addSuggestion', '/'..Config.TransferVehicle.chat_command, Locale('chatsuggestion_transferveh'), {{ name=Locale('chatsuggestion_playerid_1'), help=Locale('chatsuggestion_playerid_2')}})
        RegisterCommand(Config.TransferVehicle.chat_command, function(source, args)
            if args[1] then
                TransferVehicle(false, tonumber(args[1]))
            end
        end, false)
    end

    function TransferVehicle(fromui, targetID, plate, garage_type)
        if fromui then
            TriggerServerEvent('cd_garage:TransferVehicle', plate, targetID, garage_type, 'N/A', fromui)
        else
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsUsing(ped)
                local plate = GetPlate(vehicle)
                local hash = GetEntityModel(vehicle)

                if Config.TransferVehicle.Transfer_Blacklist[hash] == nil or Config.TransferVehicle.Transfer_Blacklist[hash] ~= true then
                    if not fromui then
                        garage_type = GetGarageType(vehicle)
                    end
                    local label = GetVehiclesData(hash).name
                    if garage_type then
                        TriggerServerEvent('cd_garage:TransferVehicle', plate, targetID, garage_type, label, fromui)
                    else
                        Notif(3, 'no_vehicle_found')
                    end
                else
                    Notif(3, 'transfer_blacklisted')
                end
            else
                Notif(3, 'get_inside_veh')
            end
        end
    end
end