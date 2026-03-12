function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local props = {}
        if Config.Framework == 'esx' then
            props = ESX.Game.GetVehicleProperties(vehicle)
        elseif Config.Framework == 'qbcore' then
            props = QBCore.Functions.GetVehicleProperties(vehicle)
        elseif Config.Framework == 'qbox' then
            props = exports.ox_lib:getVehicleProperties(vehicle)
        end

        props.plate = GetPlate(vehicle)
        props.wheelHealth = GetWheelHealth(vehicle)

        if not props.bodyHealth then
            props.bodyHealth = Round(GetVehicleBodyHealth(vehicle))
        end
        if not props.engineHealth then
            props.engineHealth = Round(GetVehicleEngineHealth(vehicle))
        end
        if not props.fuelLevel then
            props.fuelLevel = Round(GetVehicleFuelLevel(vehicle))
        end

        if not Config.SaveAdvancedVehicleDamage then
            return props
        end

        props.tyres = GetTyres(vehicle)
        props.doors = GetDoors(vehicle)
        props.windows = GetWindows(vehicle)

        return props
    end
end

function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'qbcore' then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'qbox' then
        exports.ox_lib:setVehicleProperties(vehicle, props)
    end

    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth+0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth+0.0) end
    if props.wheelhealth then SetWheelHealth(vehicle, props.wheelHealth) end

    if Config.SaveAdvancedVehicleDamage then
        SetTyres(vehicle, props.tyres)
        SetDoors(vehicle, props.doors)
        SetWindows(vehicle, props.windows)
    end
end

function GetVehiclesData(model)
    local default = {
       name = GetDefaultVehicleLabel(model),
       price = 0,
       category = GetGarageType(model) or 'Unknown',
       model = 'Unknown'
    }
    if not VehicleData[model] then
        return default
    end
    local self = {}
    self.name = VehicleData[model].name or default.name
    self.price = VehicleData[model].price or default.price
    self.category = VehicleData[model].category or default.category
    self.model = VehicleData[model].model or default.model
    return self
end

function GetReturnVehiclePrice(model)
    if Config.Return_Vehicle.method == 'vehicles_data' and VehicleData and VehicleData[model] and VehicleData[model].price then
        return Round(VehicleData[model].price*0.01*Config.Return_Vehicle.vehiclesdata_price_multiplier)
    else
        return Config.Return_Vehicle.default_price
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

function GetAllPlateFormats(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local data = {
        trimmed = Trim(plate),
        with_spaces = plate,
        mixed = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    }
    return data
end

function GetWheelHealth(vehicle)
    local wheelHealth = {}
    local wheels = GetVehicleNumberOfWheels(vehicle)
    for index = 0, wheels - 1 do
        wheelHealth[index] = GetVehicleWheelHealth(vehicle, index)
    end
    return wheelHealth
end

function SetWheelHealth(vehicle, wheels)
    if wheels then
        for index, health in pairs(wheels) do
            SetVehicleWheelHealth(vehicle, index, health)
        end
    end
end

function GetTyres(vehicle)
    local tyres = {}
    for cd = 1, 7 do
        local tyre1 = IsVehicleTyreBurst(vehicle, cd, true)
        local tyre2 = IsVehicleTyreBurst(vehicle, cd, false)
        if tyre1 or tyre2 then
            tyres[cd] = true
        else
            tyres[cd] = false
        end
    end
    return tyres
end

function SetTyres(vehicle, tyres)
    if tyres then
        for cd = 1, 7 do
            if tyres[cd] then
                SetVehicleTyreBurst(vehicle, cd, true, 1000)
            end
        end
    end
end

function GetDoors(vehicle)
    local doors = {}
    for cd = 1, 6 do
        local door = IsVehicleDoorDamaged(vehicle, cd-1)
        if door then
            doors[cd] = true
        else
            doors[cd] = false
        end
    end
    return doors
end

function SetDoors(vehicle, doors)
    if doors then
        for cd = 1, 6 do
            if doors[cd]then
                SetVehicleDoorBroken(vehicle, cd-1, true)
            end
        end
    end
end

function GetWindows(vehicle)
    local windows = {}
    local aids = {[5] = GetEntityBoneIndexByName(vehicle, 'windscreen'), [6] = GetEntityBoneIndexByName(vehicle, 'windscreen_r')}
    for cd = 1, 6 do
        local window
        if cd < 5 then
            window = IsVehicleWindowIntact(vehicle, cd-1)
        else
            window = IsVehicleWindowIntact(vehicle, aids[cd-1])
        end
        if not window then
            windows[cd] = true
        else
            windows[cd] = false
        end
    end
    return windows
end

function SetWindows(vehicle, windows)
    if windows then
        for cd = 1, 4 do
            if windows[cd] then
                SmashVehicleWindow(vehicle, cd-1)
            end
        end
    end
end

function GetUpgradeStats(props)
    local stats = {}
    if type(props.modEngine) ~= 'number' then props.modEngine = -1 end
    if type(props.modBrakes) ~= 'number' then props.modBrakes = -1 end
    if type(props.modTransmission) ~= 'number' then props.modTransmission = -1 end
    if type(props.modSuspension) ~= 'number' then props.modSuspension = -1 end
    if (type(props.modTurbo) ~= 'number' and type(props.modTurbo) ~= 'boolean') then props.modTurbo = false end

    stats.engine = props.modEngine+1
    stats.brakes = props.modBrakes+1
    stats.transmission = props.modTransmission+1
    stats.suspension = props.modSuspension+1
    if props.modTurbo == 1 then
        stats.turbo = 1
    elseif props.modTurbo == false then
        stats.turbo = 0
    end
    return stats
end

local function CalculateHandling(handling1, handling2, handling3)
    local calc = (handling1+handling2)
    return (calc*handling3)
end

local function CalculateTopSpeed(topspeed1, topspeed2)
    local calc
    if topspeed2 >= 1.5 then
        calc = 0.9
    elseif topspeed2 >= 1.0 then
        calc = 1.0 
    elseif topspeed2 >= 0.5 then
        calc = 1.1 
    elseif topspeed2 >= 0 then
        calc = 1.2
    end
    return ((topspeed1*calc)*1.1)
end

function GetPerformanceStats(vehicle)
    local data = {}
    data.acceleration = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveForce')
    data.brakes = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce')
    local topspeed1 = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    local topspeed2 = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDragCoeff')
    data.topspeed = math.ceil(CalculateTopSpeed(topspeed1, topspeed2))
    local handling1 = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionBiasFront')
    local handling2 = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax')
    local handling3 = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin')
    data.handling = CalculateHandling(handling1, handling2, handling3)
    return data
end

function GetHealthStats(props)
    local data = {}
    data.engine_health = props.engineHealth and math.ceil(props.engineHealth) or 1000.0
    data.body_health = props.bodyHealth and math.ceil(props.bodyHealth) or 1000.0
    data.fuel_level = props.fuelLevel and math.ceil(props.fuelLevel) or 100.0
    return data
end