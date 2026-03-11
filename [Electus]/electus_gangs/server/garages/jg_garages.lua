if Config.Garage.garageSystem ~= "jg-advancedgarages" then
	return
end

function GetGarages()
	return exports["jg-advancedgarages"]:getAllGarages()
end

function UpdateGarage(parking, vehProps)
	if Config.Framework == "esx" then
		MySQL.update(
			"UPDATE owned_vehicles SET garage_id = ?, `vehicle` = ? WHERE `plate` = ?",
			{ parking, json.encode(vehProps), vehProps.plate }
		)

		return true
	elseif Config.Framework == "qbcore" or Config.Framework == "qbox" then
		MySQL.update(
			"UPDATE player_vehicles SET garage_id = ?, `mods` = ? WHERE plate = ?",
			{ parking, json.encode(vehProps), vehProps.plate }
		)

		return true
	end
end

function GetVehicleInPark(player, parking)
	local identifier = GetIdentifier(src)

	if Config.Framework == "esx" then
		local vehicle =
			MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = @citizenid AND garage_id = @parking", {
				["@citizenid"] = identifier,
				["@parking"] = parking,
			})
		return vehicle
	elseif Config.Framework == "qbcore" or Config.Framework == "qbox" then
		local vehicle =
			MySQL.query.await("SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND garage_id = @parking", {
				["@citizenid"] = identifier,
				["@parking"] = parking,
			})
		return vehicle
	end
end
