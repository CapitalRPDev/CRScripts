function GetCustomSharedVehicles()
    if GetResourceState('okokVehicleShop') == 'started' then
        local SharedVehicles = {}
        local data = DB.fetch('SELECT vehicle_name, vehicle_id, category, min_price, max_price FROM okokvehicleshop_vehicles')
        if data then
            for _, vehicle in pairs(data) do
                if vehicle.vehicle_id ~= nil then
                    local hash = GetHashKey(vehicle.vehicle_id)
                    SharedVehicles[hash] = {
                        name = vehicle.vehicle_name,
                        model = vehicle.vehicle_id,
                        hash = hash,
                        price = math.floor(((vehicle.min_price + vehicle.max_price) / 2) + 0.5),
                        category = vehicle.category
                    }
                end
            end
        end
        return SharedVehicles
    end
end