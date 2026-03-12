-- Get all possible plate variations for a given plate.
function GetAllPossiblePlates(plate)
    local results = {}
    local seen = {}

    local function add(p)
        if p and p ~= '' and not seen[p] then
            seen[p] = true
            table.insert(results, p)
        end
    end

    add(plate)

    local trimmed = plate:match('^%s*(.-)%s*$')
    add(trimmed)

    if #trimmed < 8 then
        add(GenerateSpacesInPlate(trimmed))
    end

    return results
end

-- Check if a vehicle exists in the database.
function IsVehicleOwned(plate)
    local exists = DB.exists('SELECT 1 FROM '..FW.vehicle_table..' WHERE plate = ? LIMIT 1', { plate })
    if exists then
        return true
    else
        return false
    end
end

-- Check if a player owns a vehicle.
function DoesPlayerOwnVehicle(source, plate)
    if type(plate) ~= 'string' or plate == '' then
        return false
    end
    local identifier = GetIdentifier(source)

    return DB.exists(('SELECT 1 FROM '..FW.vehicle_table..' WHERE plate = ? AND '..FW.vehicle_identifier..' = ? LIMIT 1'), { plate, identifier }) == true
end

-- Generate a random vehicle plate.
function GenerateRandomVehiclePlate(plateFormat)
    local plate = ''
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local numbers = '0123456789'

    for cd = 1, #Config.NewPlateFormat do
        local char = string.sub(Config.NewPlateFormat, cd, cd)
        if char == 'A' then
            local random_index = math.random(1, #letters)
            local random_char = string.sub(letters, random_index, random_index)
            plate = plate..random_char
        elseif char == '1' then
            local random_index = math.random(1, #numbers)
            local random_char = string.sub(numbers, random_index, random_index)
            plate = plate..random_char
        else
            plate = plate..char
        end
    end

    local Result = DB.fetch('SELECT plate FROM '..FW.vehicle_table..' WHERE plate=?', {plate})
    if Result and Result[1] == nil then
        return plate
    else
        return GenerateRandomVehiclePlate()
    end
end

-- Fetch vehicle properties from the database.
function GetVehiclePropertiesFromDatabase(plate)
    local vehicle = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE plate=?', {plate})
    if vehicle and vehicle[1] and vehicle[1][FW.vehicle_props] then
        return json.decode(vehicle[1][FW.vehicle_props] or '{}')
    end
    return {}
end

-- Gets vehicles license plate.
function GetVehiclePlate(vehicle)
    if not vehicle then
        return
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end