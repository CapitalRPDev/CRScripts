if not Config.Debug then return end

RegisterCommand('cd_garage_takevehicleimages', function(source, args)
    local savedVehicleImages = {}
    local vehicleImagesToAdd = {}

    if source ~= 0 then
        print('^1Server Console Command Only.^0')
        return
    end

    local targetSource = tonumber(args[1])

    if not targetSource then
        print('^1Define the source to send data to. Usage: images <source>.^0')
        return
    end

    if not GetPlayerName(targetSource) then
        print('^1Player not found.^0')
        return
    end

    local imageFolder = exports['cd_bridge']:ReadDirectory(
        GetResourcePath('cd_garage')..'/html/images/vehicles',
        {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    )
    for _, rawFileName in pairs(imageFolder or {}) do
        local fileName = tostring(rawFileName):gsub('%..*$', ""):lower()
        savedVehicleImages[fileName] = {model = fileName, modelHash = GetHashKey(fileName)}
    end

    for modelHash, vehData in pairs(VehicleData) do
        local model = tostring(vehData.model):lower()
        if not savedVehicleImages[model] then
            vehicleImagesToAdd[#vehicleImagesToAdd + 1] = {model = model, modelHash = modelHash}
        end
    end

    local VehicleDatabase = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table)
    if VehicleDatabase then
        for _, cd in pairs(VehicleDatabase) do
            local props = json.decode(cd[FW.vehicle_props])
            local modelHash = props.model

            for _, d in pairs(savedVehicleImages) do
                if d.modelHash == modelHash then
                    modelHash = nil
                    break
                end
            end

            for _, d in pairs(vehicleImagesToAdd) do
                if d.modelHash == modelHash then
                    modelHash = nil
                    break
                end
            end

            if modelHash then
                vehicleImagesToAdd[#vehicleImagesToAdd + 1] = {modelHash = modelHash}
            end
        end
    end

    TriggerClientEvent('cd_garage:GetVehicleImageFileNames', targetSource, vehicleImagesToAdd)

end, false)