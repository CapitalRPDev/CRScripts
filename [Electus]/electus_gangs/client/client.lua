function ToggleNuiFrame(shouldShow)
	DisableIdleCamera(shouldShow)
	SetNuiFocus(shouldShow, shouldShow)

	SendReactMessage("setVisible", shouldShow)

	if not shouldShow then
		InGangMenu = false
		StopAnim()
	end
end

function ToggleVisibility(shouldShow)
	SendReactMessage("setVisible", shouldShow)
end

RegisterCommand("show-nui", function()
	ToggleNuiFrame(true)
end, false)

RegisterNUICallback("hideFrame", function(_, cb)
	if InsideNPCDialog then
		EndDrugSellScene()
	end
	ToggleNuiFrame(false)
	InsidePasswordChange = false
	InGangMenu = false
	cb({})
end)

RegisterCommand("close", function()
	ToggleNuiFrame(false)
end, false)

RegisterNetEvent("electus_gangs:manageGangs", function()
	SendReactMessage("updateComponent", {
		component = "gangCreator",
	})
	ToggleNuiFrame(true)
end)

function SpawnVehicle(vehicle, coords, gangVehicle)
	local netVeh = AwaitServerCallback("electus_gangs:spawnVehicle", vehicle, coords, gangVehicle)

	while not NetworkDoesNetworkIdExist(netVeh) do
		Wait(0)
	end

	local vehicleEnt = NetToVeh(netVeh)

	TaskWarpPedIntoVehicle(PlayerPedId(), vehicleEnt, -1)
	ApplyVehicleMods(vehicleEnt, vehicle)

	if GetResourceState("qs-vehiclekeys") == "started" then
		local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEnt))
		local plate = GetVehicleNumberPlateText(vehicleEnt)

		exports["qs-vehiclekeys"]:GiveKeys(plate, model, true)
	end
end

function StoreVehicle(zone)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	if not DoesEntityExist(vehicle) then
		return
	end

	local vehProps = GetVehicleMods(vehicle)
	local removed = AwaitServerCallback("electus_gangs:storeVehicle", zone, vehProps)

	if removed?.jgSaveOnClient then
		TriggerEvent("jg-advancedgarages:client:store-vehicle", "gang:" .. GetPlayerGangId(), "car")
	elseif removed?.remove then
		DeleteEntity(vehicle)
	end
end

function OpenCrate(zoneId, crateId)
	if Config.Inventory == "ox_inventory" then
		if not exports["ox_inventory"]:openInventory("stash", zoneId .. ":" .. crateId) then
			TriggerServerEvent("electus_gangs:openStash", crateId, zoneId)
			exports["ox_inventory"]:openInventory("stash", zoneId .. ":" .. crateId)
		end
	elseif Config.Inventory == "qs" or Config.Inventory == "tgiann" or Config.Inventory == "codem" then
		local other = {}
		other.maxweight = Config.Warehouse.weight
		other.slots = Config.Warehouse.slots
		TriggerServerEvent("inventory:server:OpenInventory", "stash", zoneId .. ":" .. crateId, other)
		TriggerEvent("inventory:client:SetCurrentStash", zoneId .. ":" .. crateId)
	elseif Config.Inventory == "core" or Config.Inventory == "qb-inventory" then
		TriggerServerEvent("electus_gangs:openStash", crateId, zoneId)
	else
		local other = {}
		other.maxweight = Config.Warehouse.weight
		other.slots = Config.Warehouse.slots
		TriggerServerEvent("inventory:server:OpenInventory", "stash", zoneId .. ":" .. crateId, other)
		TriggerEvent("inventory:client:SetCurrentStash", zoneId .. ":" .. crateId)
	end
end

if Config.Ui.enterZone.currentZoneCommand and Config.Ui.enterZone.enablePopup then
	RegisterCommand(Config.Ui.enterZone.currentZoneCommand, function(source, args, raw)
		local zoneId = GetPlayerZone()?.id

		local owner = AwaitServerCallback("electus_gangs:getGangFromZoneId", zoneId)

		if owner then
			SendReactMessage("enteredZone", {
				color = owner.color,
				name = owner.name,
			})
		end
	end)
end

function IsDead()
	local playerPed = PlayerPedId()
	return GetEntityHealth(playerPed) <= 0
		or IsPedDeadOrDying(playerPed, true)
		or IsPlayerDead(playerPed)
		or LocalPlayer.state.dead
		or LocalPlayer.state.isDead
	-- add more if you are using custom ambulance job etc
end
