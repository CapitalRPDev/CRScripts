PlayerData = {}
if Config.Framework ~= "esx" and (Config.Framework ~= "auto" or GetResourceState("es_extended") ~= "started") then
	return
end

export, ESX = pcall(function()
	return exports.es_extended:getSharedObject()
end)

if not export then
	TriggerEvent("esx:getSharedObject", function(obj)
		ESX = obj
	end)
end

RegisterNetEvent("esx:onPlayerLogout", function()
	ESX.PlayerLoaded = false

	while not ESX.PlayerLoaded do
		Wait(500)
	end

	FrameworkLoaded = true

	-- TriggerEvent("electus_gangs:updateZones")
	TriggerEvent("electus_gangs:updateNextCaptureZones")

	TriggerEvent("electus_gangs:playerLoaded")
	OnPlayerLoad()
end)

function ApplyVehicleMods(vehicleEnt, vehicle)
	if type(vehicle) == "string" then
		vehicle = json.decode(vehicle)
	end

	SetVehicleOnGroundProperly(vehicleEnt)
	SetVehicleNumberPlateText(vehicleEnt, vehicle.plate)

	ESX.Game.SetVehicleProperties(vehicleEnt, vehicle)

	if vehicle.damages then
		SetVehicleEngineHealth(vehicleEnt, vehicle.damages.engineHealth)
		SetVehicleBodyHealth(vehicleEnt, vehicle.damages.bodyHealth)
	end

	if vehicle.fuel then
		SetVehicleFuelLevel(vehicleEnt, vehicle.fuel)
	end
end

function GetVehicleMods(vehicleEnt)
	local mods = ESX.Game.GetVehicleProperties(vehicleEnt)
	return mods
end
