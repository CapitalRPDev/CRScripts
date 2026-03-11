if (Config.Framework ~= "qbox") and (Config.Framework ~= "auto" or GetResourceState("qbx_core") ~= "started") then
	return
end

function ApplyVehicleMods(vehicleEnt, vehicle)
	if type(vehicle) == "string" then
		vehicle = json.decode(vehicle)
	end

	SetVehicleNumberPlateText(vehicleEnt, vehicle.plate)
	lib.setVehicleProperties(vehicleEnt, vehicle)

	TriggerEvent("vehiclekeys:client:SetOwner", qbx.getVehiclePlate(vehicleEnt))

	if GetResourceState("LegacyFuel") == "started" and vehicle.fuel then
		exports.LegacyFuel:SetFuel(vehicleEnt, vehicle.fuel)
	end
end

function GetVehicleMods(vehicleEnt)
	return lib.getVehicleProperties(vehicleEnt)
end
