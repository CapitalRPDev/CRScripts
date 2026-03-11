local escortingTarget = false

if Config.EnableGangActions then
	if Config.TargetSystem == "qb-target" then
		exports[Config.TargetSystem]:AddGlobalPlayer({
			options = {
				{
					label = L("zip_tie"),
					action = function(entity)
						StartHandcuff(entity)
					end,
					item = Config.ActionItems.ziptie,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and not Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("remove_zip_tie"),
					action = function(entity)
						Untie(entity)
					end,
					item = Config.ActionItems.remove_ziptie,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("search"),
					action = function(entity)
						SearchPlayer(entity)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("escort"),
					action = function(entity)
						AwaitServerCallback(
							"electus_gangs:escortPlayer",
							GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
						)
						EscortPlayer(entity)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("place_head_bag"),
					action = function(entity)
						PlaceHeadbag(entity)
					end,
					item = Config.ActionItems.headbag,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and not Entity(entity).state.headbag
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("remove_head_bag"),
					action = function(entity)
						TriggerServerEvent(
							"electus_gangs:removeHeadBag",
							GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
						)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.headbag
							and not Entity(PlayerPedId()).state.tied
					end,
				},
			},
			debugPoly = Config.Debug,
			distance = 2.0,
		})
	else
		exports[Config.TargetSystem]:Player({
			options = {
				{
					label = L("zip_tie"),
					action = function(entity)
						StartHandcuff(entity)
					end,
					item = Config.ActionItems.ziptie,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and not Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("remove_zip_tie"),
					action = function(entity)
						Untie(entity)
					end,
					item = Config.ActionItems.remove_ziptie,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("search"),
					action = function(entity)
						SearchPlayer(entity)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("escort"),
					action = function(entity)
						AwaitServerCallback(
							"electus_gangs:escortPlayer",
							GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
						)

						EscortPlayer(entity)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("place_head_bag"),
					action = function(entity)
						PlaceHeadbag(entity)
					end,
					item = Config.ActionItems.headbag,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and not Entity(entity).state.headbag
							and Entity(entity).state.tied
							and not Entity(PlayerPedId()).state.tied
					end,
				},
				{
					label = L("remove_head_bag"),
					action = function(entity)
						TriggerServerEvent(
							"electus_gangs:removeHeadBag",
							GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
						)
					end,
					canInteract = function(entity)
						return GetPlayerGangId() ~= nil
							and Entity(entity).state.headbag
							and not Entity(PlayerPedId()).state.tied
					end,
				},
			},
			debugPoly = Config.Debug,
			distance = 2.0,
		})
	end

	exports[Config.TargetSystem]:AddTargetBone({ "seat_dside_f" }, {
		options = {
			{
				label = L("take_out_of_vehicle"),
				action = function(entity)
					TriggerServerEvent("electus_gangs:taskLeaveVehicle", VehToNet(entity), -1)
				end,
				canInteract = function(entity)
					local targetPed = GetPedInVehicleSeat(entity, -1)
					return GetPlayerGangId() ~= nil and Entity(targetPed).state.escortedIntoVehicle
				end,
			},
		},
		distance = 2,
	})

	exports[Config.TargetSystem]:AddTargetBone({ "seat_pside_f" }, {
		options = {
			{
				label = L("put_in_vehicle"),
				action = function(entity)
					TriggerServerEvent(
						"electus_gangs:warpPlayerIntoVehicle",
						VehToNet(entity),
						GetPlayerServerId(NetworkGetPlayerIndexFromPed(escortingTarget)),
						0
					)
					StopEscorting()
				end,
				canInteract = function(entity)
					return GetPlayerGangId() ~= nil and escortingTarget and Entity(escortingTarget).state.escorted
				end,
			},
			{
				label = L("take_out_of_vehicle"),
				action = function(entity)
					TriggerServerEvent("electus_gangs:taskLeaveVehicle", VehToNet(entity), 0)
				end,
				canInteract = function(entity)
					local targetPed = GetPedInVehicleSeat(entity, 0)
					return GetPlayerGangId() ~= nil and Entity(targetPed).state.escortedIntoVehicle
				end,
			},
		},
		distance = 2,
	})

	exports[Config.TargetSystem]:AddTargetBone({ "seat_pside_r" }, {
		options = {
			{
				label = L("put_in_vehicle"),
				action = function(entity)
					TriggerServerEvent(
						"electus_gangs:warpPlayerIntoVehicle",
						VehToNet(entity),
						GetPlayerServerId(NetworkGetPlayerIndexFromPed(escortingTarget)),
						2
					)
					StopEscorting()
				end,
				canInteract = function(entity)
					return GetPlayerGangId() ~= nil and escortingTarget and Entity(escortingTarget).state.escorted
				end,
			},
			{
				label = L("take_out_of_vehicle"),
				action = function(entity)
					TriggerServerEvent("electus_gangs:taskLeaveVehicle", VehToNet(entity), 2)
				end,
				canInteract = function(entity)
					local targetPed = GetPedInVehicleSeat(entity, 2)
					return GetPlayerGangId() ~= nil and Entity(targetPed).state.escortedIntoVehicle
				end,
			},
		},
		distance = 2,
	})

	exports[Config.TargetSystem]:AddTargetBone({ "seat_dside_r" }, {
		options = {
			{
				label = L("put_in_vehicle"),
				action = function(entity)
					TriggerServerEvent(
						"electus_gangs:warpPlayerIntoVehicle",
						VehToNet(entity),
						GetPlayerServerId(NetworkGetPlayerIndexFromPed(escortingTarget)),
						1
					)
					StopEscorting()
				end,
				canInteract = function(entity)
					return GetPlayerGangId() ~= nil and escortingTarget and Entity(escortingTarget).state.escorted
				end,
			},
			{
				label = L("take_out_of_vehicle"),
				action = function(entity)
					TriggerServerEvent("electus_gangs:taskLeaveVehicle", VehToNet(entity), 1)
				end,
				canInteract = function(entity)
					local targetPed = GetPedInVehicleSeat(entity, 1)
					return GetPlayerGangId() ~= nil and Entity(targetPed).state.escortedIntoVehicle
				end,
			},
		},
		distance = 2,
	})
end

function PlaceHeadbag(entity)
	if Entity(entity).state.headbag then
		return
	end

	AwaitServerCallback("electus_gangs:placeHeadbag", GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
end

function EscortPlayer(entity)
	CreateThread(function()
		local playerIdx = NetworkGetPlayerIndexFromPed(entity)
		local serverId = GetPlayerServerId(playerIdx)
		TriggerServerEvent("electus_gangs:escortPlayer", serverId)

		lib.requestAnimDict("amb@world_human_drinking@coffee@male@base")

		TaskPlayAnim(
			PlayerPedId(),
			"amb@world_human_drinking@coffee@male@base",
			"base",
			8.0,
			-8.0,
			-1,
			49,
			0.0,
			false,
			false,
			false
		)

		escortingTarget = entity

		EnableHelpText(L("press_to_stop_escorting", { ["key"] = Config.KeyActions.stopEscorting }))
	end)
end

function StopEscorting()
	if Entity(PlayerPedId()).state.escorting then
		ClearPedTasks(PlayerPedId())
		DisableHelpText()
	end

	if escortingTarget then
		AwaitServerCallback("electus_gangs:stopEscortPlayer", NetworkGetNetworkIdFromEntity(escortingTarget))
		escortingTarget = false
	end
end

lib.addKeybind({
	name = "stop_escorting",
	description = L("stop_escort"),
	defaultKey = Config.KeyActions.stopEscorting,
	onPressed = function(self)
		StopEscorting()
	end,
})
-- DetachEntity(PlayerPedId(), false, true)

-- RegisterNetEvent("electus_gangs:stopBeingEscorted", function()
-- 	DetachEntity(PlayerPedId(), false, true)
-- end)

function StartHandcuff(entity)
	CreateThread(function()
		local playerIdx = NetworkGetPlayerIndexFromPed(entity)
		local serverId = GetPlayerServerId(playerIdx)

		TriggerServerEvent("electus_gangs:cuffPlayer", serverId)
		-- GetCuffedAnimation(entity)
	end)
	HandTieAnimation()
end

function Untie(entity)
	CreateThread(function()
		local playerIdx = NetworkGetPlayerIndexFromPed(entity)
		local serverId = GetPlayerServerId(playerIdx)

		TriggerServerEvent("electus_gangs:uncuffPlayer", serverId)
	end)
	-- HandTieAnimation()
end

function HandTieAnimation()
	local ped = PlayerPedId()

	lib.requestAnimDict("mp_arrest_paired")
	Wait(100)
	TaskPlayAnim(ped, "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, false, false, false)
	TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
	Wait(3500)
	TaskPlayAnim(ped, "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, false, false, false)
end

local escorted = false
local escorter = nil

RegisterNetEvent("electus_gangs:getEscorted", function(playerId)
	local playerPed = PlayerPedId()
	escorter = GetPlayerPed(GetPlayerFromServerId(playerId))

	AttachEntityToEntity(playerPed, escorter, 11816, 0.275, 0.45, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end)

RegisterNetEvent("electus_gangs:getCuffed", function(cuffer)
	GetTiedAnimation(cuffer)
end)

-- RegisterNetEvent("electus_gangs:getUncuffed", function()
-- 	local ped = PlayerPedId()
-- 	ClearPedSecondaryTask(ped)
-- 	ClearPedTasksImmediately(ped)
-- end)

function GetTiedAnimation(playerId)
	local ped = PlayerPedId()
	local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
	local heading = GetEntityHeading(cuffer)
	lib.requestAnimDict("mp_arrest_paired")

	SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))

	Wait(100)
	SetEntityHeading(ped, heading)
	TaskPlayAnim(ped, "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, false, false, false)
end

local tied = Entity(PlayerPedId()).state.tied or false

AddStateBagChangeHandler("tied", nil, function(bagName, key, value)
	local entity = GetEntityFromStateBagName(bagName)
	if entity == 0 or entity ~= PlayerPedId() then
		return
	end

	if tied and not value then
		ClearPedSecondaryTask(entity)
		ClearPedTasksImmediately(entity)
	end

	tied = value
end)

AddStateBagChangeHandler("escorted", nil, function(bagName, key, value)
	local entity = GetEntityFromStateBagName(bagName)
	if entity == 0 or entity ~= PlayerPedId() then
		return
	end

	if escorted and not value then
		DetachEntity(PlayerPedId(), false, true)
	end

	escorted = value
end)

local headbag = Entity(PlayerPedId()).state.headbag or false
local headbagEntity = nil

function CreateHeadbagObject()
	local headbagModel = GetHashKey("prop_money_bag_01")
	lib.requestModel(headbagModel)

	local bagNet = AwaitServerCallback("electus_gangs:createHeadBag")

	while not NetworkDoesNetworkIdExist(bagNet) do
		Wait(0)
	end

	headbagEntity = NetToObj(bagNet)

	AttachEntityToEntity(
		headbagEntity,
		PlayerPedId(),
		GetPedBoneIndex(PlayerPedId(), 12844),
		0.2,
		0.04,
		0,
		0,
		270.0,
		60.0,
		true,
		true,
		false,
		true,
		1,
		true
	)
end

function SearchPlayer(entity)
	local playerIdx = NetworkGetPlayerIndexFromPed(entity)
	local serverId = GetPlayerServerId(playerIdx)

	local clientOpen = AwaitServerCallback("electus_gangs:searchPlayer", serverId)

	if clientOpen then
		if Config.Inventory == "qs-inventory" then
			TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", serverId)
		end
	end
end

function RemoveHeadbagObject()
	if not headbagEntity then
		return
	end

	TriggerServerEvent("electus_gangs:removeHeadbagObject", ObjToNet(headbagEntity))
	headbagEntity = nil
end

AddStateBagChangeHandler("headbag", nil, function(bagName, key, value)
	local entity = GetEntityFromStateBagName(bagName)
	if entity == 0 or entity ~= PlayerPedId() then
		return
	end

	if headbag and not value then
		ToggleNuiFrame(true)

		SendReactMessage("closeHeadBag")
		RemoveHeadbagObject()
	end

	headbag = value

	if not headbagEntity and headbag then
		SendReactMessage("openHeadBag")
		CreateHeadbagObject()
	end
end)

CreateThread(function()
	Wait(2500)

	if Entity(PlayerPedId()).state.escorting then
		StopEscorting()
	end

	if Entity(PlayerPedId()).state.escorted then
		DetachEntity(PlayerPedId(), false, true)
	end
end)

CreateThread(function()
	while true do
		Wait(0)

		if tied then
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 19, true) -- ALT

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288, true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			EnableControlAction(0, 249, true) -- Added for talking while cuffed
			EnableControlAction(0, 46, true) -- Added for talking while cuffed

			if
				not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3)
				and not IsEntityPlayingAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3)
			then
				lib.requestAnimDict("mp_arresting")
				TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
			end
		end

		if escorted and escorter then
			if IsPedWalking(escorter) then
				ForcePedMotionState(PlayerPedId(), -668482597, true, 0, true)
			elseif IsPedSprinting(escorter) then
				ForcePedMotionState(PlayerPedId(), -1115154469, true, 0, true)
			elseif IsPedRunning(escorter) then
				ForcePedMotionState(PlayerPedId(), -530524, true, 0, true)
			end
		end
	end
end)
