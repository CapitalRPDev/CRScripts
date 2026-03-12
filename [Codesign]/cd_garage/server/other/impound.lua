if not Config.Impound.ENABLE then return end

function GetImpoundData(source, impoundId)
    local myImpoundedVehicles = {}
    local myIdentifier = GetIdentifier(source)
    for c, d in pairs(ImpoundData) do
        if d.impound == impoundId and d.identifier == myIdentifier then
            myImpoundedVehicles[#myImpoundedVehicles+1] = d
        end
    end
    return myImpoundedVehicles
end

function GetAllImpoundData(impoundId)
    local myImpoundedVehicles = {}
    for c, d in pairs(ImpoundData) do
        if d.impound == impoundId then
            myImpoundedVehicles[#myImpoundedVehicles+1] = d
        end
    end
    return myImpoundedVehicles
end

function CanCivRetriveVehicle(source, plate, price)
    if not CheckVehicleOwner(source, plate) then
        return false, Locale('dont_own_vehicle')
    end

    if price <= 0 then
        return false, 'price_is_zero'
    end

    local playerMoney = GetPlayerMoney(source, 'bank')
    if playerMoney > price then
        RemovePlayerMoney(source, price, 'bank', 'civ_unimpound')
        return true
    else
        return false, Locale('not_enough_money')
    end
end

function IsVehicleInImpound(plate)
    for c, d in pairs(ImpoundData) do
        if d.plate == plate then
            return true, d.release_time
        end
    end
    return false
end

RegisterServerEvent('cd_garage:ImpoundVehicle', function(plate, impound, label, props, adv_stats, release_time, description, canretrive)
    local _source = source
    local location
    for c, d in pairs (Config.ImpoundLocations) do
        if d.ImpoundID ~= nil and d.ImpoundID == impound then
            location = d.blip.name
            break
        end
    end

    local fakeData = FakePlateTable and FakePlateTable[plate]
    if fakeData and fakeData.originalplate then
        plate = fakeData.originalplate
    end

    local result = DB.fetch('SELECT plate, '..FW.vehicle_identifier..' FROM '..FW.vehicle_table..' WHERE plate="'..plate..'"')
    if result and result[1] then
        ImpoundVehicleLogs(_source, 'impound', label, plate, location)
        local targetIdentifier = result[1][FW.vehicle_identifier]
        local char_name = GetCharacterName(_source)

        local charjob = GetJobName(_source)
        local price = Config.Impound.Impound_Fee.default_price
        if Config.Impound.Impound_Fee.method == 'vehicles_data' then
            price = Round(VehicleData[props.model].price*0.01*Config.Impound.Impound_Fee.vehiclesdata_price_multiplier)
        end

        if Config.Mileage.ENABLE and adv_stats then
            if not TypeCheck(adv_stats, 'table', '3870') then
                adv_stats = nil
            end
        end
        table.insert(ImpoundData, {
            plate = plate,
            impound = impound,
            props = props,
            adv_stats = adv_stats,
            label = label,
            description = description,
            canretrive = canretrive,
            charname = char_name,
            charjob = charjob,
            price = price,
            impound_label = location,
            identifier = targetIdentifier,
            release_time = release_time,
        })
        local temp = {
            label = label,
            description = description,
            canretrive = canretrive,
            charname = char_name,
            charjob = charjob,
            price = price,
            impound_label = location,
            identifier = targetIdentifier,
            release_time = release_time

        }
        DB.exec('UPDATE '..FW.vehicle_table..' SET impound=@impound, impound_data=@impound_data WHERE plate=@plate',{
            ['@impound'] = impound,
            ['@impound_data'] = json.encode(temp),
            ['@plate'] = plate
        })
    end
end)

RegisterServerEvent('cd_garage:UnImpoundVehicle')
AddEventHandler('cd_garage:UnImpoundVehicle', function(plate, label)
    local _source = source
    if ImpoundData == nil then return end
    for c, d in pairs(ImpoundData) do
        if d.plate == plate then
            table.remove(ImpoundData, c)
            break
        end
    end
    Notif(_source, 1, 'unimpounded_vehicle', plate)
    ImpoundVehicleLogs(_source, 'unimpound', label, plate)
    DB.exec('UPDATE '..FW.vehicle_table..' SET impound=0, impound_data="", in_garage=1 WHERE plate="'..plate..'"')
end)

RegisterServerEvent('cd_garage:SaveImpoundTimers')
AddEventHandler('cd_garage:SaveImpoundTimers', function()
    for c, d in pairs(ImpoundData) do
        local temp_table = {
            label = d.label,
            description = d.description,
            canretrive = d.canretrive,
            charname = d.charname,
            charjob = d.charjob,
            price = d.price,
            impound_label = d.impound_label,
            identifier = d.identifier,
            release_time = d.release_time
        }
        DB.exec('UPDATE '..FW.vehicle_table..' SET impound_data=@impound_data WHERE plate=@plate',{
            ['@impound_data'] = json.encode(temp_table),
            ['@plate'] = d.plate
        })
    end
end)