if not Config.GarageRaid.ENABLE then return end

function SearchVehicleInGarage(garageId, plate)
    local result = DB.fetch('SELECT plate, '..FW.vehicle_props..', in_garage, impound, garage_id, adv_stats, property, custom_label FROM '..FW.vehicle_table..' WHERE plate=@plate and garage_id=@garage_id', {
        ['@plate'] = plate,
        ['@garage_id'] = garageId
    })
    if result and #result > 0 then
        local vehicle = result[1]
        return {
            plate = vehicle.plate,
            vehicle = json.decode(vehicle[FW.vehicle_props]),
            in_garage = vehicle.in_garage,
            impound = vehicle.impound,
            garage_id = vehicle.garage_id,
            adv_stats = json.decode(vehicle.adv_stats),
            property = vehicle.property,
            label = vehicle.custom_label,
        }
    end
    return nil
end