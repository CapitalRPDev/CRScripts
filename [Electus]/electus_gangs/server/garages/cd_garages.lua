if Config.Garage.garageSystem ~= "cd_garage" then
	return
end

function GetGarages()
	local cfg = exports["cd_garage"]:GetConfig()
	local garages = {}

	for k, v in pairs(cfg.Locations) do
		garages[#garages + 1] = {
			name = v.Garage_ID,
			label = v.Garage_ID,
		}
	end

	return garages
end

function UpdateGarage(parking, vehProps)
	if Config.Framework == "esx" then
		MySQL.update.await(
			"UPDATE owned_vehicles SET garage_id = ?, `vehicle` = ? WHERE `plate` = ?",
			{ parking, json.encode(vehProps), vehProps.plate }
		)
	elseif Config.Framework == "qbcore" or Config.Framework == "qbox" then
		MySQL.update.await(
			"UPDATE player_vehicles SET garage_id = ?, `mods` = ? WHERE plate = ?",
			{ parking, json.encode(vehProps), vehProps.plate }
		)
	end

	return true
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
