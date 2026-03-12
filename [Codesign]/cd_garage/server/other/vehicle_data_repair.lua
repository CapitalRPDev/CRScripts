local function isBlankString(v)
    return type(v) ~= 'string' or v:match('^%s*$') ~= nil
end

local function decodeJsonTable(raw)
    if type(raw) ~= 'string' then
        return false, nil, 'not a string'
    end

    if raw:match('^%s*$') then
        return false, nil, 'empty string'
    end

    local ok, decoded = pcall(json.decode, raw)
    if not ok then
        return false, nil, 'decode failed'
    end

    if type(decoded) ~= 'table' then
        return false, decoded, ('decoded type is %s'):format(type(decoded))
    end

    return true, decoded, nil
end

local function pushErr(errorsFound, index, identifier, plate, reason, on_startup, veh)
    table.insert(errorsFound, {
        player_identifier = on_startup and veh and veh[FW.vehicle_identifier] or identifier,
        plate = plate or 'nil',
        reason = reason,
        index = index
    })
end

local function QB_to_ESX_props(Result)
    for cd = 1, #Result do
        Result[cd].vehicle = Result[cd].mods
        Result[cd].mods = nil
    end
    return Result
end

function ValidateAndRepairVehicleData(vehicles, identifier, on_startup)
    local errorsFound = {}
    local vehDataErrorsFound = 0

    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        vehicles = QB_to_ESX_props(vehicles)
    end

    for index, veh in pairs(vehicles) do
        veh = veh or {}

        -- plate normalization
        if isBlankString(veh.plate) then
            veh.plate = nil
        else
            veh.plate = veh.plate:upper()
        end
        local plate = veh.plate

        -- props decoding: must be JSON string that decodes to table
        do
            local ok, props, why = decodeJsonTable(veh.vehicle)
            if not ok then
                pushErr(errorsFound, index, identifier, plate, ('vehicle/mods invalid (%s)'):format(why), on_startup, veh)
                veh.vehicle = nil
            else
                -- unwrap jg_dealerships: { props = <realProps> }
                if type(props) == 'table' and props.props ~= nil then
                    veh.vehicle = props.props
                else
                    veh.vehicle = props
                end
            end
        end
        local props = veh.vehicle

        -- If plate column missing, attempt recover from props.plate
        if not plate then
            if props and type(props) == 'table' and type(props.plate) == 'string' and not props.plate:match('^%s*$') then
                veh.plate = props.plate
                plate = props.plate

                local sql = ([[
                    UPDATE %s
                    SET plate = @plate
                    WHERE %s = @identifier
                    AND (plate IS NULL OR plate = '')
                    AND %s IS NOT NULL
                    AND %s <> ''
                    AND JSON_UNQUOTE(JSON_EXTRACT(%s, '$.plate')) = @plate
                ]]):format(
                    FW.vehicle_table,
                    FW.vehicle_identifier,
                    FW.vehicle_props,
                    FW.vehicle_props,
                    FW.vehicle_props
                )

                local params = {
                    ['@plate'] = plate,
                    ['@identifier'] = on_startup and veh[FW.vehicle_identifier] or identifier
                }

                if type(props.model) == 'number' then
                    sql = sql .. " AND JSON_EXTRACT("..FW.vehicle_props..", '$.model') = @model"
                    params['@model'] = props.model
                end

                DB.exec(sql, params)

            else
                table.insert(errorsFound, {
                    player_identifier = on_startup and veh[FW.vehicle_identifier] or identifier,
                    plate = 'nil',
                    reason = props and 'vehicle plate is nil and props.plate missing/invalid' or 'vehicle plate is nil and vehicle/mods column is empty',
                    index = index
                })
            end
        end

        -- If props are missing but we have a plate, attempt rebuild for qb/qbox
        if not props and plate then
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                local temp = DB.single('SELECT hash FROM player_vehicles WHERE plate=?', { plate })
                if temp and temp.hash and not isBlankString(temp.hash) then
                    veh.vehicle = {
                        plate = plate,
                        model = tonumber(temp.hash),
                        engineHealth = 100.0,
                        bodyHealth = 100.0,
                        fuelLevel = 100.0,
                        wheelHealth = 100.0
                    }

                    DB.exec('UPDATE '..FW.vehicle_table..' SET '..FW.vehicle_props..'=@props WHERE plate=@plate', {
                        ['@props'] = json.encode(veh.vehicle),
                        ['@plate'] = plate
                    })

                    props = veh.vehicle
                else
                    pushErr(errorsFound, index, identifier, plate, 'mods column is empty and hash column is empty', on_startup, veh)
                end
            else
                pushErr(errorsFound, index, identifier, plate, 'vehicle column is empty', on_startup, veh)
            end
        end

        -- If props exist, validate required fields
        if props and plate then
            -- props.plate must be string
            if isBlankString(props.plate) then
                props.plate = plate

                DB.exec('UPDATE '..FW.vehicle_table..' SET '..FW.vehicle_props..'=@props WHERE plate=@plate', {
                    ['@props'] = json.encode(props),
                    ['@plate'] = plate
                })
            end

            -- props.model must be number (hash)
            if type(props.model) ~= 'number' then
                if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                    local temp = DB.single('SELECT hash FROM player_vehicles WHERE plate=?', { plate })
                    if temp and temp.hash and not isBlankString(temp.hash) then
                        props.model = tonumber(temp.hash)

                        DB.exec('UPDATE '..FW.vehicle_table..' SET '..FW.vehicle_props..'=@props WHERE plate=@plate', {
                            ['@props'] = json.encode(props),
                            ['@plate'] = plate
                        })
                    else
                        pushErr(errorsFound, index, identifier, plate, 'mods model is nil/invalid and hash column is empty', on_startup, veh)
                    end
                else
                    pushErr(errorsFound, index, identifier, plate, 'vehicle/mods model is nil/invalid', on_startup, veh)
                end
            end
        end

        -- Fakeplate application
        if not on_startup and plate and type(veh.fakeplate) == 'string' and veh.fakeplate ~= '' then
            if not FakePlateTable[veh.fakeplate] then
                FakePlateTable[veh.fakeplate] = {
                    fakeplate = veh.fakeplate,
                    originalplate = plate
                }
            end

            veh.original_plate = plate

            if props then
                props.plate = veh.fakeplate
            end

            veh.plate = veh.fakeplate
        end

        -- Impound timer attach
        if not on_startup and Config.Impound.ENABLE and plate then
            local isImpounded, impoundTimer = IsVehicleInImpound(plate)
            if isImpounded then
                veh.impound_timer = impoundTimer
            end
        end

        -- adv_stats fixing
        if Config.Mileage.ENABLE and plate then
            do
                local ok, adv, why = decodeJsonTable(veh.adv_stats)
                veh.adv_stats = ok and adv or nil
            end
            if not veh.adv_stats then
                veh.adv_stats = {
                    plate = plate,
                    mileage = 0,
                    maxhealth = 1000.0,
                }
                DB.exec('UPDATE '..FW.vehicle_table..' SET adv_stats=@adv_stats WHERE plate=@plate', {
                    ['@adv_stats'] = json.encode(veh.adv_stats),
                    ['@plate'] = plate
                })
            end
        end

        -- Vehicle model exists in data table
        if VehicleData and props and props.model and not VehicleData[props.model] then
            vehDataErrorsFound = vehDataErrorsFound + 1
            if Config.VehicleDataDebugPrints then
                Citizen.Trace(([[
                    ^5===============================================================
                    ^3[cd_garage] Vehicle Data Issue
                    ^5===============================================================
                    ^7Player Identifier: ^3%s
                    ^7Vehicle Plate:     ^3%s
                    ^7Reason:            ^1%s
                    ^5===============================================================^0
                ]] .. '^0\n'):format(
                    on_startup and veh[FW.vehicle_identifier] or identifier or 'unknown',
                    plate or 'nil',
                    ('vehicle model %s not found in vehicle data table'):format(tostring(props.model))
                ))
            end
        end

        -- garage_id
        if isBlankString(veh.garage_id) then
            veh.garage_id = Config.Locations[1].Garage_ID
            DB.exec('UPDATE '..FW.vehicle_table..' SET garage_id=? WHERE plate=?', { veh.garage_id, plate })
        end

        -- garage_type
        if isBlankString(veh.garage_type) then
            veh.garage_type = 'car'
            DB.exec('UPDATE '..FW.vehicle_table..' SET garage_type=? WHERE plate=?', { veh.garage_type, plate })
        end

        -- impound
        if type(veh.impound) ~= 'number' then
            veh.impound = 0
            DB.exec('UPDATE '..FW.vehicle_table..' SET impound=0, impound_data="" WHERE plate=?', { plate })
        end

        -- in_garage
        if type(veh.in_garage) ~= 'boolean' then
            veh.in_garage = true
            DB.exec('UPDATE '..FW.vehicle_table..' SET in_garage=1 WHERE plate=?', { plate })
        end

        if on_startup and veh.fakeplate ~= nil and (type(veh.fakeplate) ~= 'string' or veh.fakeplate == '') then
            DB.exec('UPDATE '..FW.vehicle_table..' SET fakeplate=NULL WHERE plate=?', { plate })
        end
    end

    table.sort(errorsFound, function(a, b)
        return a.index > b.index
    end)

    for _, err in ipairs(errorsFound) do
        if vehicles[err.index] then
            table.remove(vehicles, err.index)
        end

        Citizen.Trace(([[
            ^5===============================================================
            ^3[cd_garage] Vehicle Database Issue
            ^5===============================================================
            ^7Player Identifier: ^3%s
            ^7Vehicle Plate:     ^3%s
            ^7Reason:            ^1%s
            ^7Resolution:        ^2%s
            ^5===============================================================^0
        ]] .. '^0\n'):format(
            err.player_identifier or 'unknown',
            err.plate or 'nil',
            err.reason or 'unspecified',
            'vehicle unavailable in garage until manually fixed'
        ))
    end

    if (Config.Debug or Config.VehicleDataDebugPrints) and vehDataErrorsFound > 0 then
        Citizen.Trace(('^3[cd_garage] ^1%d^0 vehicle data issues were found. Enable Config.VehicleDataDebugPrints to view.\n'):format(vehDataErrorsFound))
    end

    return vehicles
end