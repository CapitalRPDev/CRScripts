if (Config.Framework ~= "qbcore") and (Config.Framework ~= "auto" or GetResourceState("qbcore") ~= "started") then
	return
end

QBCore = exports["qb-core"]:GetCoreObject()

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	PlayerData = {}
end)

function ApplyVehicleMods(vehicleEnt, vehicle)
	if type(vehicle) == "string" then
		vehicle = json.decode(vehicle)
	end

	SetVehicleNumberPlateText(vehicleEnt, vehicle.plate)

	QBCore.Functions.SetVehicleProperties(vehicleEnt, vehicle or {})
	TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicleEnt))

	if GetResourceState("LegacyFuel") == "started" and vehicle.fuel then
		exports.LegacyFuel:SetFuel(vehicleEnt, vehicle.fuel)
	end
end

function GetVehicleMods(vehicleEnt)
	local mods = QBCore.Functions.GetVehicleProperties(vehicleEnt)
	return mods
end
