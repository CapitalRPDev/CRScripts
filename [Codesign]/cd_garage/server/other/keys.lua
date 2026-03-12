if not Config.VehicleKeys.ENABLE then return end

local JobKeysTable = {}

local function LoadSharedJobKeys(source, identifier)
    if Config.JobVehicles.ENABLE and Config.JobVehicles.share_job_keys then
        local job = GetJobName(source)
        if JobKeysTable[job] == nil then
            JobKeysTable[job] = {}
            JobKeysTable[job].player_info = {}
            JobKeysTable[job].plates = {}
        end
        local playerHasRejoined = false
        for c, d in pairs(JobKeysTable[job].player_info) do
            if identifier == d.identifier then
                d.source = source
                playerHasRejoined = true
                break
            end
        end
        if not playerHasRejoined then
            table.insert(JobKeysTable[job].player_info, {source = source, identifier = identifier})

            for c, d in pairs(JobKeysTable[job].plates) do
                table.insert(AllKeysTable, {
                    plate = d.plate,
                    owner_identifier = d.owner_identifier,
                    owner_name = d.owner_name,
                    reciever_identifier = identifier,
                    reciever_source = source,
                    type = 'temp',
                    model = d.modelString,
                    name = d.label,
                    job = job
                })
            end
        end
    end
end

local function LoadPertsistentVehicleKeys(source)
    if not Config.PersistentVehicles.ENABLE then return end
    local identifier = GetIdentifier(source)

    for c, d in pairs(PersistentVehiclesTable) do
        if d.identifier == identifier then
            TriggerClientEvent('cd_garage:AddKeys', source, d.plate)
        end
    end
end

local function DuplicateKeyFound(plate, owner_identifier, reciever_identifier)
    for _, cd in pairs(AllKeysTable) do
        if cd.plate == plate and cd.owner_identifier == owner_identifier and cd.reciever_identifier == reciever_identifier then
            return true
        end
    end
    return false
end

function IsPlayerOnline(source)
    if GetPlayerName(source) then
        return true
    else
        return false
    end
end

function GetSharedVehiclesOwner(identifier, plate)
    for c, d in pairs(AllKeysTable) do
        if d.reciever_identifier == identifier and d.plate == plate and d.type == 'saved' and d.job == nil then
            return d.owner_identifier
        end
    end
end

local function CacheJobVehicleKeys(source, job, plate, identifier, vehicleData, owner_name)
    if Config.JobVehicles.share_job_keys then
        table.insert(JobKeysTable[job].plates, {plate = plate, vehicle_data = vehicleData, owner_identifier = identifier, owner_name = owner_name})
        for c, d in pairs(JobKeysTable[job].player_info) do
            if IsPlayerOnline(d.source) and d.source ~= source and not DuplicateKeyFound(plate, identifier, d.identifier)then
                table.insert(AllKeysTable, {
                    plate = plate,
                    owner_identifier = identifier,
                    owner_name = owner_name,
                    reciever_identifier = d.identifier,
                    reciever_name = GetCharacterName(d.source),
                    reciever_source = d.source,
                    type = 'temp',
                    model = vehicleData and vehicleData.model_string or nil,
                    name = vehicleData and vehicleData.label or nil,
                    job = job
                })
                TriggerClientEvent('cd_garage:AddKeys', d.source, plate)
            end
        end
    end
end

function Keys_FakePlate(current_plate, new_plate)
    local database_updated = false
    for c, d in pairs(AllKeysTable) do
        if d.plate == current_plate then
            d.plate = new_plate
            if not d.reciever_source then
                d.reciever_source = GetSourceFromIdentifier(d.reciever_identifier)
            end
            if d.reciever_source then
                TriggerClientEvent('cd_garage:AddKeys', d.reciever_source, new_plate)
            end
            if d.type == 'saved' and not database_updated then
                database_updated = true
                DB.exec('UPDATE cd_garage_keys SET plate = @new_plate WHERE plate = @current_plate', {
                    ['@new_plate'] = new_plate,
                    ['@current_plate'] = current_plate
                })
            end
        end
    end

    for c, d in pairs(JobKeysTable) do
        for e, f in pairs(d.plates) do
            if f.plate == current_plate then
                f.plate = new_plate
            end
        end
    end
end

RegisterServerEvent('cd_garage:LoadCachedkeys')
AddEventHandler('cd_garage:LoadCachedkeys', function()
    local _source = source

    if not GetPlayer(_source) then return end
    local waited = 0
    while not CachedAllData and waited < 5000 do
        Wait(100)
        waited = waited + 100
    end
    if not GetPlayer(_source) then return end

    local identifier = GetIdentifier(_source)
    local owner_name = GetCharacterName(_source)
    local job = GetJobName(_source)
    local temp_table = {}

    LoadSharedJobKeys(_source, identifier)
    LoadPertsistentVehicleKeys(_source)

    local Result = DB.fetch('SELECT plate, custom_label, job_personalowned, fakeplate, '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE '..FW.vehicle_identifier..'=@identifier', {
        ['@identifier'] = identifier
    })
    if Result and #Result > 0 then
        for c, d in ipairs(Result) do

            local props = json.decode(d[FW.vehicle_props])
            if not props then
                ERROR('9254', 'Failed to decode vehicle props for plate '..tostring(d.plate))
                return
            end

            if Config.FakePlates.ENABLE and d.fakeplate then
                props.plate = d.fakeplate
                d.plate = d.fakeplate
            end

            local vehicleData = GetVehicleData(_source, d.plate, props.model)

            if not DuplicateKeyFound(d.plate, identifier, nil) then
                table.insert(AllKeysTable, {
                    plate = d.plate,
                    owner_identifier = identifier,
                    type = 'owned',
                    model = vehicleData and vehicleData.model_string or nil,
                    name = d.custom_label or vehicleData and vehicleData.label or nil
                })
            end

            if d.job_personalowned ~= nil and d.job_personalowned ~= '' then
                CacheJobVehicleKeys(_source, job, d.plate, identifier, vehicleData, owner_name)
                AllKeysTable[#AllKeysTable].job = job
            end
        end
    end
    for c, d in ipairs(AllKeysTable) do
        if (identifier == d.reciever_identifier) or (identifier == d.owner_identifier and d.type == 'owned') then
            table.insert(temp_table, d.plate)
        end
    end
    TriggerClientEvent('cd_garage:AddKeys_playerload', _source, temp_table)
end)

RegisterServerEvent('cd_garage:GiveKeys')
AddEventHandler('cd_garage:GiveKeys', function(action, plate, targetSource)
    local _source = source
    local owner_identifier = GetIdentifier(_source)
    local reciever_identifier = GetIdentifier(targetSource)
    local char_name = GetCharacterName(_source)

    if DuplicateKeyFound(plate, owner_identifier, reciever_identifier) then
        return
    end

    local vehicleData = GetVehicleData(_source, plate)

    if action == 'save' then
        local originalPlate = nil
        if Config.FakePlates.ENABLE then
            originalPlate = GetOriginalPlateFromFakePlate(plate)
        end
        if CheckVehicleOwner(_source, originalPlate) then
            DB.exec('INSERT INTO cd_garage_keys (plate, owner_identifier, reciever_identifier, owner_name, reciever_name, model) VALUES (@plate, @owner_identifier, @reciever_identifier, @owner_name, @reciever_name, @model)',{
                ['@plate'] = plate,
                ['@owner_identifier'] = owner_identifier,
                ['@reciever_identifier'] = reciever_identifier,
                ['@owner_name'] = GetCharacterName(_source),
                ['@reciever_name'] = GetCharacterName(targetSource),
                ['@model'] = vehicleData and vehicleData.model_string or nil
            })
            table.insert(AllKeysTable, {
                plate = plate,
                owner_identifier = owner_identifier,
                owner_name = GetCharacterName(_source),
                reciever_identifier = reciever_identifier,
                reciever_name = GetCharacterName(targetSource),
                reciever_source = targetSource,
                type = 'saved',
                model = vehicleData and vehicleData.model_string or nil,
                name = vehicleData and vehicleData.label or nil,
                char_name = char_name
            })
            Notif(_source, 2, 'gave_keys_saved', char_name, plate)
            Notif(targetSource, 2, 'recieve_keys_saved', plate)
        else
            Notif(_source, 3, 'dont_own_vehicle')
            return
        end
    elseif action == 'temp' then
        table.insert(AllKeysTable, {
            plate = plate,
            owner_identifier = owner_identifier,
            owner_name = GetCharacterName(_source),
            reciever_identifier = reciever_identifier,
            reciever_name = GetCharacterName(targetSource),
            reciever_source = targetSource,
            type = 'temp',
            model = vehicleData and vehicleData.model_string or nil,
            name = vehicleData and vehicleData.label or nil,
            char_name = char_name
        })
        Notif(_source, 2, 'gave_keys_temp', char_name, plate)
        Notif(targetSource, 2, 'recieve_keys_temp', plate)
    end
    TriggerClientEvent('cd_garage:AddKeys', targetSource, plate)
end)

RegisterServerEvent('cd_garage:AddKeysOwnedVehicle', function(plate, model, src)
    local _source = (source ~= nil and source ~= '') and source or src
    local identifier = GetIdentifier(_source)
    local vehicleData = GetVehicleData(_source, plate, model)

    if DuplicateKeyFound(plate, identifier, nil) then
        return
    end

    table.insert(AllKeysTable, {
        plate = plate,
        owner_identifier = identifier,
        type = 'owned',
        model = vehicleData and vehicleData.model_string or nil,
        name = vehicleData and vehicleData.label
    })
    TriggerClientEvent('cd_garage:AddKeys', _source, plate)
end)

RegisterServerEvent('cd_garage:JobVehicleCacheKeys')
AddEventHandler('cd_garage:JobVehicleCacheKeys', function(plate, vehicleData)
    local _source = source
    local identifier = GetIdentifier(_source)
    local job = GetJobName(_source)
    local owner_name = GetCharacterName(_source)

    if not DuplicateKeyFound(plate, identifier) then
        table.insert(AllKeysTable, {
            plate = plate,
            owner_identifier = identifier,
            owner_name = owner_name,
            type = 'owned',
            model = vehicleData and vehicleData.model_string or nil,
            name = vehicleData.label,
            job = job
        })
    end

    if JobKeysTable[job] == nil then
        JobKeysTable[job] = {}
        JobKeysTable[job].player_info = {}
        JobKeysTable[job].plates = {}
    end

    CacheJobVehicleKeys(_source, job, plate, identifier, vehicleData, owner_name)
end)

RegisterServerEvent('cd_garage:ShowKeysUI')
AddEventHandler('cd_garage:ShowKeysUI', function()
    local _source = source
    local identifier = GetIdentifier(_source)
    local keys = {owned = {}, given = {}, recieved = {}}
    for c, d in pairs(AllKeysTable) do
        if d.owner_identifier == identifier and d.type == 'owned' then
            table.insert(keys.owned, d)
        elseif d.reciever_identifier == identifier and d.job == nil then
            table.insert(keys.recieved, d)
        elseif d.owner_identifier == identifier and d.job == nil then
            table.insert(keys.given, d)
        end
    end
    TriggerClientEvent('cd_garage:ShowKeysUI', _source, keys, GetAllPlayers(_source))
end)

RegisterServerEvent('cd_garage:RemoveKeys')
AddEventHandler('cd_garage:RemoveKeys', function(data)
    for c, d in pairs(AllKeysTable) do
        if d.plate == data.plate and d.reciever_identifier == data.reciever_identifier then
            table.remove(AllKeysTable, c)
            if data.type == 'saved' then
                DB.exec('DELETE FROM cd_garage_keys WHERE plate = @plate and reciever_identifier = @reciever_identifier', {
                    ['@plate'] = data.plate,
                    ['@reciever_identifier'] = data.reciever_identifier
                })
            end
            break
        end
    end
    local target_source = GetSourceFromIdentifier(data.reciever_identifier)
    if target_source then
        TriggerClientEvent('cd_garage:RemoveKeys', target_source, data.plate)
    end
end)

RegisterServerEvent('cd_garage:SetVehicleLockState')
AddEventHandler('cd_garage:SetVehicleLockState', function(netid, lock_state)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    SetVehicleDoorsLocked(vehicle, lock_state)
end)

RegisterServerEvent('cd_garage:SaveAllVehicleDamage')
AddEventHandler('cd_garage:SaveAllVehicleDamage', function(data)
    for c, d in pairs(data) do
        DB.exec('UPDATE '..FW.vehicle_table..' SET '..FW.vehicle_props..'=@props WHERE plate=@plate', {
            ['@props'] = json.encode(d),
            ['@plate'] = d.plate
        })
    end
end)


if Config.VehicleKeys.Lockpick.usable_item.ENABLE then

    RegisterUsableItem(Config.VehicleKeys.Lockpick.usable_item.item_name, function(source)
        TriggerClientEvent('cd_garage:LockpickVehicle', source, true)
    end)

    RegisterServerEvent('cd_garage:LockpickVehicle:RemoveItem')
    AddEventHandler('cd_garage:LockpickVehicle:RemoveItem', function()
        local _source = source
        RemoveItem(_source, Config.VehicleKeys.Lockpick.usable_item.item_name, 1)
    end)

end