if Config.Garage.garageSystem ~= "qb-garages" then
	return
end

function GetGarages()
	return exports["qb-garages"].getAllGarages()
end

function UpdateGarage(parking, vehProps)
	MySQL.update(
		"UPDATE player_vehicles SET garage = ?, `mods` = ? WHERE plate = ?",
		{ parking, json.encode(vehProps), vehProps.plate }
	)

	return true
end

function GetVehicleInPark(player, parking)
	local identifier = GetIdentifier(src)

	local vehicle =
		MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND garage = @parking", {
			["@citizenid"] = identifier,
			["@parking"] = parking,
		})
	return vehicle
end
