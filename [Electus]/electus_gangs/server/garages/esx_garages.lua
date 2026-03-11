if Config.Garage.garageSystem ~= "esx_garage" then
	return
end

function GetGarages()
	local esxGarages = exports["esx_garage"].getGarages()
	local garages = {}

	for k, v in pairs(esxGarages) do
		garages[#garages + 1] = {
			name = k,
			label = k,
		}
	end

	return garages
end

function UpdateGarage(parking, vehProps)
	MySQL.update("UPDATE owned_vehicles SET `parking` = @parking, `vehicle` = @vehicle WHERE `plate` = @plate", {
		["@plate"] = vehProps.plate,
		["@parking"] = parking,
		["@vehicle"] = json.encode(vehProps),
	})

	return true
end

function GetVehicleInPark(player, parking)
	local identifier = GetIdentifier(src)

	local vehicle = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = @owner AND `parking` = @parking", {
		["@owner"] = identifier,
		["@parking"] = parking,
	})

	return vehicle
end
