function GetMaxHealth(plate)
    if AdvStatsTable and AdvStatsTable[plate] and AdvStatsTable[plate].maxhealth then
        return AdvStatsTable[plate].maxhealth
    else
        return 1000.0
    end
end

function GetVehicleMileage(plate)
    if AdvStatsTable and AdvStatsTable[plate] and AdvStatsTable[plate].mileage then
        return AdvStatsTable[plate].mileage
    else
        return nil
    end
end

function GetAdvStats(plate)
    if AdvStatsTable and AdvStatsTable[plate] then
        return {plate = AdvStatsTable[plate].plate, mileage = AdvStatsTable[plate].mileage, maxhealth = AdvStatsTable[plate].maxhealth}
    else
        local Result = DB.fetch('SELECT adv_stats FROM '..FW.vehicle_table..' WHERE plate="'..GetCorrectPlateFormat(plate)..'"')
        if Result and Result[1] and Result[1].adv_stats then
            return json.decode(Result[1].adv_stats)
        end
    end
    return false
end

function GetGarageCount(source, garage_type)
    if garage_type == nil then garage_type = 'car' end
    local Result = DB.fetch('SELECT '..FW.vehicle_identifier..' FROM '..FW.vehicle_table..' WHERE '..FW.vehicle_identifier..'="'..GetIdentifier(source)..'" and garage_type="'..garage_type..'"')
    if Result then
        return #Result
    end
    return 0
end

function GetGarageLimit(source)
    if Config.GarageSpace.ENABLE then
        local Result = DB.fetch('SELECT garage_limit FROM '..FW.users_table..' WHERE '..FW.users_identifier..'="'..GetIdentifier(source)..'"')
        if Result and Result[1] and Result[1].garage_limit then
            return tonumber(Result[1].garage_limit)
        end
    end
    return 1000
end

function CheckVehicleOwner(source, plate)
    local Result = DB.fetch('SELECT '..FW.vehicle_identifier..' FROM '..FW.vehicle_table..' WHERE plate="'..GetCorrectPlateFormat(plate)..'"')
    if Result and Result[1]then
        local data = Result[1][FW.vehicle_identifier]
        if data then
            if data == GetIdentifier(source) then
                return true
            end
        end
    end
    return false
end

function GetPlate(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return nil end
    if Config.VehiclePlateFormats.format == 'trimmed' then
        return Trim(plate)

    elseif Config.VehiclePlateFormats.format == 'with_spaces' then
        return plate

    elseif Config.VehiclePlateFormats.format == 'mixed' then
        return string.gsub(plate, "^%s*(.-)%s*$", "%1")

    end
end

function IsVehicleImpounded(plate)
    local Result = DB.fetch('SELECT impound FROM '..FW.vehicle_table..' WHERE plate="'..GetCorrectPlateFormat(plate)..'"')
    if Result and Result[1] and Result[1].impounded then
        if tonumber(Result[1].impounded) == 1 then
            return true
        end
    end
    return false
end

function GetVehicleImpoundData(plate)
    local Result = DB.fetch('SELECT impound, impound_time, impound_reason FROM '..FW.vehicle_table..' WHERE plate="'..GetCorrectPlateFormat(plate)..'"')
    if Result and Result[1] then
        return {impound = Result[1].impound, impound_time = Result[1].impound_time, impound_reason = Result[1].impound_reason}
    end
    return nil
end

function GetGarageVehicleIsIn(plate)
    local Result = DB.fetch('SELECT garage_id FROM '..FW.vehicle_table..' WHERE plate="'..GetCorrectPlateFormat(plate)..'"')
    if Result and Result[1] and Result[1].garage_id then
        return Result[1].garage_id
    end
    return nil
end

function GetVehiclesData()
    return VehicleData
end

function GetConfig()
    return Config
end

function GetCorrectPlateFormat(plate)
    if Config.VehiclePlateFormats.format == 'trimmed' then
        return Trim(plate)

    elseif Config.VehiclePlateFormats.format == 'with_spaces' then
        return plate

    elseif Config.VehiclePlateFormats.format == 'mixed' then
        return string.gsub(plate, "^%s*(.-)%s*$", "%1")
    end
end