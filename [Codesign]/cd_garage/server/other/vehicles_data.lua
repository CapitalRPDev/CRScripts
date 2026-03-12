function Get_VEHICLEDATA()
    VehicleData = GetSharedVehicles()
end

RegisterServerEvent('cd_garage:VehicleData', function()
    local src = source
    if not GetPlayer(src) then return end

    local waited = 0
    while not CachedAllData and waited < 5000 do
        Wait(100)
        waited = waited + 100
    end

    if not GetPlayer(src) then return end

    TriggerClientEvent('cd_garage:VehicleData', src, VehicleData)
end)

function GetVehicleModelString(source, plate, model)
    if model then
        return Callback(source, 'getmodelstring', model)
    end

    local allVehicles = GetAllVehicles()
    local vehicleModelString = nil
    for cd = 1, #allVehicles, 1 do
        local vehicle = allVehicles[cd]
        if DoesEntityExist(vehicle) then
            local plate2 = GetCorrectPlateFormat(GetVehicleNumberPlateText(vehicle))
            if plate == plate2 then
                local model = GetEntityModel(vehicle)
                vehicleModelString = Callback(source, 'getmodelstring', model)
            end
        end
    end

    if not vehicleModelString then
        local Result = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE plate="'..plate..'"')
        if Result and Result[1] then
            local props = json.decode(Result[1][FW.vehicle_props])
            local model = props.model
            if model then
                vehicleModelString = Callback(source, 'getmodelstring', model)
            end
        end
    end
    return vehicleModelString
end

function GetVehicleLabel(source, plate, model)
    if model then
        return Callback(source, 'getvehiclelabel', model)
    end

    local allVehicles = GetAllVehicles()
    local vehicleLabel = nil
    for cd = 1, #allVehicles, 1 do
        local vehicle = allVehicles[cd]
        if DoesEntityExist(vehicle) then
            local plate2 = GetCorrectPlateFormat(GetVehicleNumberPlateText(vehicle))
            if plate == plate2 then
                local model = GetEntityModel(vehicle)
                vehicleLabel = Callback(source, 'getvehiclelabel', model)
            end
        end
    end

    if not vehicleLabel then
        local Result = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE plate="'..plate..'"')
        if Result and Result[1] then
            local props = json.decode(Result[1][FW.vehicle_props])
            local model = props.model
            if model then
                vehicleLabel = Callback(source, 'getvehiclelabel', model)
            end
        end
    end
    return vehicleLabel
end

function GetVehicleData(source, plate, model)
    if model then
        return Callback(source, 'getvehicledata', model)
    end

    local allVehicles = GetAllVehicles()
    local vehicleData = nil
    for cd = 1, #allVehicles, 1 do
        local vehicle = allVehicles[cd]
        if DoesEntityExist(vehicle) then
            local plate2 = GetCorrectPlateFormat(GetVehicleNumberPlateText(vehicle))
            if plate == plate2 then
                local model = GetEntityModel(vehicle)
                vehicleData = Callback(source, 'getvehicledata', model)
            end
        end
    end

    if not vehicleData then
        if Config.FakePlates.ENABLE then
            plate = GetOriginalPlateFromFakePlate(plate)
        end
        local Result = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE plate="'..plate..'"')
        if Result and Result[1] then
            local props = json.decode(Result[1][FW.vehicle_props])
            local model = props.model
            if model then
                vehicleData = Callback(source, 'getvehicledata', model)
            end
        end
    end
    return vehicleData
end

function GetReturnVehiclePrice(model)
    if Config.Return_Vehicle.method == 'vehicles_data' and VehicleData and VehicleData[model] and VehicleData[model].price then
        return Round(VehicleData[model].price*0.01*Config.Return_Vehicle.vehiclesdata_price_multiplier)
    else
        return Config.Return_Vehicle.default_price
    end
end