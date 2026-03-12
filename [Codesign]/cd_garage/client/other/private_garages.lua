if not Config.PrivateGarages.ENABLE then return end

local BlipTable = {}

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/'..Config.PrivateGarages.create_chat_command, Locale('chatsuggestion_privategarage_1'), {{ name=Locale('chatsuggestion_playerid_1'), help=Locale('chatsuggestion_playerid_2')}, {name=Locale('chatsuggestion_garagename_1'), help=Locale('chatsuggestion_garagename_2')}, {name=Locale('chatsuggestion_privategarage_2'), help=Locale('chatsuggestion_privategarage_3')} })
    RegisterCommand(Config.PrivateGarages.create_chat_command, function(source, args)
        if Config.PrivateGarages.Authorized_Jobs[GetJobName()] then
            if args[1] and args[2]and args[3] then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local target_source = tonumber(args[1])
                local garage_id = args[2]
                local garage_type = args[3]
                local data = {
                    Garage_ID = garage_id:lower(),
                    Type = garage_type,
                    Dist = 10,
                    x_1 = RoundDecimals(coords.x), y_1 = RoundDecimals(coords.y), z_1 = RoundDecimals(coords.z),
                    x_2 = RoundDecimals(coords.x), y_2 = RoundDecimals(coords.y), z_2 = RoundDecimals(coords.z), h_2 = RoundDecimals(GetEntityHeading(ped)),
                    EventName1 = 'cd_garage:PrivateGarage',
                    Name = '<b>'..Locale('garage')..'</b></p>'..Locale('open_garage_1')..' </p>'..Locale('notif_storevehicle'),
                    EnableBlip = false,
                }
                TriggerServerEvent('cd_garage:SavePrivateGarage', target_source, data)
            else
                Notif(3, 'invalid_format')
            end
        else
            Notif(3, 'no_permissions')
        end
    end, false)

    TriggerEvent('chat:addSuggestion', '/'..Config.PrivateGarages.delete_chat_command, Locale('chatsuggestion_privategarage_4'), {{ name=Locale('chatsuggestion_privategarage_5'), help=Locale('chatsuggestion_privategarage_6')}})
    RegisterCommand(Config.PrivateGarages.delete_chat_command, function(source, args)
        if Config.PrivateGarages.Authorized_Jobs[GetJobName()] then
            if args[1] then
                TriggerServerEvent('cd_garage:DeletePrivateGarage', args[1])
            else
                Notif(3, 'invalid_format')
            end
        else
            Notif(3, 'no_permissions')
        end
    end, false)
end)

RegisterNetEvent('cd_garage:LoadPrivateGarages')
AddEventHandler('cd_garage:LoadPrivateGarages', function(data)
    for index, d in pairs(data) do
        table.insert(Config.Locations, d)
        PrivateGarageBlips(d)
        if UsingTarget() then
            CreatePrivateGarageTargetZone(d)
        end
    end
    if Config.SpawnGaragePeds then
        LoadGaragePeds()
    end
end)

RegisterNetEvent('cd_garage:DeletePrivateGarage')
AddEventHandler('cd_garage:DeletePrivateGarage', function(garage_id)
    for c, d in pairs(Config.Locations) do
        if d.Garage_ID == garage_id then
            table.remove(Config.Locations, c)
            local blip = BlipTable[d.Garage_ID]
            if DoesBlipExist(blip) then RemoveBlip(blip) BlipTable[d.Garage_ID] = nil end
            if UsingTarget() then
                DeleteGarageTargetZone('garage_'..garage_id)
            end
            break
        end
    end
end)

function PrivateGarageBlips(data)
    local blip = AddBlipForCoord(data.x_1, data.y_1, data.z_1)
    BlipTable[data.Garage_ID] = blip
    if not Config.Blip[data.Type] then
        ERROR('3422', 'cd_garage: There is no blip configuration for the garage type: '..data.Type)
    end
    SetBlipSprite(blip, Config.Blip[data.Type].sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip[data.Type].scale)
    SetBlipColour(blip, Config.Blip[data.Type].colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip[data.Type].name:sub(1, -2)..': '..data.Garage_ID)
    EndTextCommandSetBlipName(blip)
end