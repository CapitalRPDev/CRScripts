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

function GetVehicleMileage(plate)
    if AdvStatsTable and AdvStatsTable[plate] and AdvStatsTable[plate].mileage then
        return AdvStatsTable[plate].mileage
    else
        return nil
    end
end