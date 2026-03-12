if not Config.VehicleKeys.ENABLE then return end

TriggerEvent('chat:addSuggestion', '/'..Config.VehicleKeys.command, Locale('chatsuggestion_showkey'))
RegisterCommand(Config.VehicleKeys.command, function()
    ShowKeysUI()
end, false)

TriggerEvent('chat:addSuggestion', '/'..Config.VehicleKeys.give_key_command, Locale('chatsuggestion_givekey'))
RegisterCommand(Config.VehicleKeys.give_key_command, function()
    local closestVehicle = GetClosestVehicleToPlayer(5.0)
    local closestPlayer = GetClosestPlayer(3.0, 'serverid')
    if not closestVehicle then
        Notif(3, 'no_vehicle_found')
        return
    end
    if not closestPlayer then
        Notif(3, 'no_player_found')
        return
    end
    local plate = GetPlate(closestVehicle)
    TriggerServerEvent('cd_garage:GiveKeys', 'temp', plate, closestPlayer)
end, false)


KeysTable = {}

function CacheVehicle(plate, vehicle)
    if KeysTable[plate] == nil then
        KeysTable[plate] = {}
        KeysTable[plate].vehicle = vehicle
    end
end

function AddKey(plate)
    if KeysTable[plate] ~= nil then
        KeysTable[plate].has_key = true
    else
        KeysTable[plate] = {}
        KeysTable[plate].has_key = true
    end
end

function RemoveKey(plate)
    if KeysTable[plate] ~= nil then
        KeysTable[plate].has_key = false
    else
        KeysTable[plate] = {}
        KeysTable[plate].has_key = false
    end
end

function ShowKeysUI()
    TriggerServerEvent('cd_garage:ShowKeysUI')
end

RegisterNetEvent('cd_garage:ShowKeysUI', function(keys, allPlayers)
    for c, d in pairs(keys.owned) do
        if not d.name then
            d.name = GetVehiclesData(d.model).name
        end
    end

    EnableNuiFocus()
    SendNUIMessage({
        action = 'showkeys',
        keys = keys,
        players = allPlayers,
        use_charname = Config.PlayerListMethod == 'charname' or Config.PlayerListMethod == 'both',
        use_source = Config.PlayerListMethod == 'source' or Config.PlayerListMethod == 'both'
    })
end)


RegisterNetEvent('cd_garage:AddKeys')
AddEventHandler('cd_garage:AddKeys', function(plate)
    if not plate then return end
    AddKey(GetCorrectPlateFormat(plate))
end)

RegisterNetEvent('cd_garage:AddKeys_playerload')
AddEventHandler('cd_garage:AddKeys_playerload', function(data)
    if type(data) ~= 'table' then return end
    for c, d in pairs(data) do
        AddKey(GetCorrectPlateFormat(d))
    end
end)

RegisterNetEvent('cd_garage:RemoveKeys')
AddEventHandler('cd_garage:RemoveKeys', function(plate)
    if not plate then return end
    RemoveKey(GetCorrectPlateFormat(plate))
end)

RegisterNetEvent('cd_garage:GiveVehicleKeys')
AddEventHandler('cd_garage:GiveVehicleKeys', function(plate, vehicle)
    GiveVehicleKeys(plate, vehicle)
end)

RegisterNetEvent('cd_garage:ShowKeys')
AddEventHandler('cd_garage:ShowKeys', function()
    ShowKeysUI()
end)

RegisterNUICallback('addkey_temp', function(data)
    TriggerServerEvent('cd_garage:GiveKeys', 'temp', data.plate, data.target_source)
end)

RegisterNUICallback('addkey_save', function(data)
    TriggerServerEvent('cd_garage:GiveKeys', 'save', data.plate, data.target_source)
end)

RegisterNUICallback('removekey', function(data)
    TriggerServerEvent('cd_garage:RemoveKeys', data.value)
end)

function GetKeysData()
    return KeysTable
end

function DoesPlayerHaveKeys(plate)
    local plate_formatted = GetCorrectPlateFormat(plate)
    if type(plate) == 'string' then
        if KeysTable and KeysTable[plate_formatted] and KeysTable[plate_formatted].has_key then
            return true
        end
    end
    return false
end

RegisterNetEvent('cd_garage:SaveAllVehicleDamage')
AddEventHandler('cd_garage:SaveAllVehicleDamage', function()
    local data = {}
    for c, d in pairs(KeysTable) do
        if d.vehicle then
            data[#data+1] = GetVehicleProperties(d.vehicle)
        end
    end
    TriggerServerEvent('cd_garage:SaveAllVehicleDamage', data)
end)

CreateThread(function()
    local show_notif = false
    local wait = 500
    while true do
        wait = 500
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(vehicle, -1) == ped then
            local plate = GetPlate(vehicle)
            CacheVehicle(plate, vehicle)
            if Config.VehicleKeys.Hotwire.ENABLE then
                local data = KeysTable[plate]
                if data then
                    if data.vehicle == nil then KeysTable[plate].vehicle = vehicle end
                    if data.has_key then
                        if not data.engine_enabled then
                            SetVehicleEngineOn(vehicle, true, false, false)
                            KeysTable[plate].engine_enabled = true
                        end
                    else
                        if not show_notif then
                            Notif(2, 'hotwire_info')
                            show_notif = true
                        end
                        wait = 5
                        SetVehicleEngineOn(vehicle, false, false, true)
                    end
                else
                    SetVehicleEngineOn(vehicle, false, false, true)
                end
            end
        end
        Wait(wait)
    end
end)

RegisterNetEvent('vehiclekeys:client:SetOwner')
AddEventHandler('vehiclekeys:client:SetOwner', function(plate)
    AddKey(GetCorrectPlateFormat(plate))
end)

RegisterNetEvent('qb-vehiclekeys:client:AddKeys')
AddEventHandler('qb-vehiclekeys:client:AddKeys', function(plate)
    AddKey(GetCorrectPlateFormat(plate))
end)