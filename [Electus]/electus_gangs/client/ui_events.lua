RegisterNUICallback("get_roles", function(data, cb)
	local roles = AwaitServerCallback("electus_gangs:getRoles", data.gangId)
	cb(roles)
end)

RegisterNUICallback("get_members", function(data, cb)
	local members = AwaitServerCallback("electus_gangs:getMembers", data.gangId, data.page)
	cb(members)
end)

RegisterNUICallback("get_captured_zones", function(data, cb)
	local zones = AwaitServerCallback("electus_gangs:getCapturedZones")
	cb(zones)
end)

RegisterNUICallback("get_gangs", function(data, cb)
	local gangs = AwaitServerCallback("electus_gangs:getGangs")
	cb(gangs)
end)

RegisterNUICallback("calling_cops", function(data, cb)
	local coords = GetEntityCoords(PlayerPedId())
	TriggerServerEvent("electus_gangs:callCops", coords)
	cb({})
end)

RegisterNUICallback("alerting_gang", function(data, cb)
	local myGang = GetPlayerGangId()
	local currentZone = GetPlayerZone()

	if not currentZone then
		return cb({})
	end

	local zoneGang = AwaitServerCallback("electus_gangs:getZoneGangOwner", currentZone.id)

	if not zoneGang or not zoneGang.gangId then
		return cb({})
	end

	if myGang == zoneGang?.gangId then
		return cb({})
	end

	TriggerServerEvent(
		"electus_gangs:alertGang",
		zoneGang.gangId,
		GetEntityCoords(PlayerPedId()),
		L("attempted_drug_sell")
	)

	TriggerServerEvent("electus_gangs:notifyGangMembers", zoneGang.gangId, L("someone_called_in_drug_sell"), "warning")

	cb({})
end)

RegisterNUICallback("get_money_laundering_load", function(data, cb)
	local moneyLaundery = AwaitServerCallback("electus_gang:getMoneyLaundering", EnteredZoneId)
	cb(moneyLaundery)
end)

RegisterNUICallback("create_new_role", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:createRole", data.gangId, data.roleData)
	cb({})
end)

RegisterNUICallback("fire_member", function(data, cb)
	local resp = AwaitServerCallback("electus_gangs:fireMember", data.gangId, data.identifier)
	cb(resp)
end)

RegisterNUICallback("save_role", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:updateRole", data.gangId, data.roleId, data.roleData)
	cb({})
end)

RegisterNUICallback("delete_role", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:deleteRole", data.gangId, data.roleId)
	cb({})
end)

RegisterNUICallback("get_online_players", function(data, cb)
	local players = AwaitServerCallback("electus_gangs:getOnlinePlayers")
	cb(players)
end)

RegisterNUICallback("get_upgrades", function(data, cb)
	local upgrades = AwaitServerCallback("electus_gangs:getUpgrades", data.gangId)

	cb(upgrades)
end)

RegisterNUICallback("load_utils", function(data, cb)
	while not AwaitMainEscrow do
		Wait(1000)
	end
	cb({ locale = GetAllLocales(), config = Config, theme = Config.Ui.theme })
end)

RegisterNUICallback("upgrade_item", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:upgradeItem", data.gangId, data.item)
	UpdateGangMenuUI()
	cb(await)
end)

RegisterNUICallback("purchase_vehicle", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:purchaseVehicle", data.gangId, data.model)
	UpdateGangMenuUI()
	cb(await)
end)

RegisterNUICallback("get_daily_data", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:getDailyStatistics", data.gangId)
	cb(await)
end)

RegisterNUICallback("get_monthly_data", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:getMonthlyStatistics", data.gangId)
	cb(await)
end)

RegisterNUICallback("get_weekly_data", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:getWeeklyStatistics", data.gangId)
	cb(await)
end)

RegisterNUICallback("get_config", function(data, cb)
	cb(Config)
end)

RegisterNUICallback("create_gang", function(data, cb)
	TriggerServerEvent("electus_gangs:createGang", data.name, data.safeHouseZoneId, data.owner)
	ReloadAndCloseUI()
	cb({})
end)

RegisterNUICallback("get_my_grade", function(data, cb)
	local grade = AwaitServerCallback("electus_gangs:getMyGrade", data.gangId)
	cb(grade)
end)

RegisterNUICallback("get_zone_weed_amount", function(data, cb)
	local plants = AwaitServerCallback("electus_gangs:getZoneWeedAmount", data.zoneId)
	cb(plants)
end)

RegisterNUICallback("recruit_player", function(data, cb)
	print(data.gangId, data.playerId)
	TriggerServerEvent("electus_gangs:sendRecruitRequest", data.gangId, data.playerId)
	cb({})
end)

RegisterNUICallback("get_transactions_homepage", function(data, cb)
	local transactions = AwaitServerCallback("electus_gangs:getTransactionsHomepage", data.gangId)
	cb(transactions)
end)

RegisterNUICallback("get_transactions", function(data, cb)
	local transactions = AwaitServerCallback("electus_gangs:getTransactions", data.gangId, data.page)
	cb(transactions)
end)

RegisterNUICallback("get_safe_data", function(data, cb)
	local data = AwaitServerCallback("electus_gangs:getSafeData", data.gangId)
	cb(data)
end)

local antiSpam = false

RegisterNUICallback("deposit_dirty", function(data, cb)
	if antiSpam then
		return cb({})
	end

	antiSpam = true

	local await = AwaitServerCallback("electus_gangs:depositDirty", data.gangId, data.amount)
	if await then
		UpdateGangMenuUI()
	end
	antiSpam = false
	cb(await)
end)

RegisterNUICallback("withdraw_dirty", function(data, cb)
	if antiSpam then
		return cb({})
	end

	antiSpam = true

	local await = AwaitServerCallback("electus_gangs:withdrawDirty", data.gangId, data.amount)
	if await then
		UpdateGangMenuUI()
	end
	antiSpam = false
	cb(await)
end)

RegisterNUICallback("deposit", function(data, cb)
	if antiSpam then
		return cb({})
	end

	antiSpam = true
	local await = AwaitServerCallback("electus_gangs:deposit", data.gangId, data.amount)

	if await then
		UpdateGangMenuUI()
	end

	antiSpam = false
	cb(await)
end)

RegisterNUICallback("withdraw", function(data, cb)
	if antiSpam then
		return cb({})
	end

	antiSpam = true

	local await = AwaitServerCallback("electus_gangs:withdraw", data.gangId, data.amount)

	if await then
		UpdateGangMenuUI()
	end

	antiSpam = false
	cb(await)
end)

RegisterNUICallback("promote_role", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:promoteRole", data.gangId, data.roleId)
	cb(await)
end)

RegisterNUICallback("demote_role", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:demoteRole", data.gangId, data.roleId)
	cb(await)
end)

RegisterNUICallback("get_logs", function(data, cb)
	local logs = AwaitServerCallback("electus_gangs:getLogs", data.gangId, data.page)
	cb(logs)
end)

RegisterNUICallback("set_gang_owner", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:setGangOwner", data.gangId, data.identifier)
	cb(await)
end)
RegisterNUICallback("set_gang_color", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:setGangColor", data.gangId, data.color)
	cb(await)
end)

RegisterNUICallback("set_gang_name", function(data, cb)
	local await = AwaitServerCallback("electus_gangs:setGangName", data.gangId, data.name)
	cb(await)
end)

RegisterNUICallback("get_scoreboard", function(data, cb)
	local scoreboard = AwaitServerCallback("electus_gangs:getScoreboard")
	cb(scoreboard)
end)

RegisterNUICallback("get_identifier", function(data, cb)
	local name = AwaitServerCallback("electus_gangs:getIdentifier", data.id)
	cb(name)
end)

RegisterNUICallback("get_identifier_name", function(data, cb)
	local name = AwaitServerCallback("electus_gangs:getIdentifierName", data.identifier)
	cb(name)
end)

RegisterNUICallback("remove_gang", function(data, cb)
	ReloadAndCloseUI()
	local await = AwaitServerCallback("electus_gangs:removeGang", data.gangId)
	cb(await)
end)

RegisterNUICallback("update_gang", function(data, cb)
	ReloadAndCloseUI()
	local await = AwaitServerCallback("electus_gangs:updateGang", data.gang)
	cb(await)
end)

RegisterNUICallback("get_my_role_id", function(data, cb)
	local gang = AwaitServerCallback("electus_gangs:getMyRoleId")
	cb(gang)
end)

RegisterNUICallback("set_gps_marker", function(data, cb)
	SetNewWaypoint(data.pos.x, data.pos.y)
	cb({})
end)

RegisterNUICallback("change_role", function(data, cb)
	local hasChanged = AwaitServerCallback("electus_gangs:changeRole", data.gangId, data.identifier, data.roleId)
	cb(hasChanged)
end)

RegisterNUICallback("set_event_waypoint", function(data, cb)
	local event = data.event
	local coords = nil

	if event == "harbourContainers" then
		coords = Config.Events.harbourContainers.containers[1].coords
	elseif event == "boatCrates" then
		coords = Config.Events.boatCrates.ladders[1].coords
	end

	if coords then
		SetNewWaypoint(coords.x, coords.y)
	end
end)

RegisterNUICallback("admin_transfer_zone", function(data, cb)
	local success = AwaitServerCallback("electus_gangs:adminTransferZone", data.zoneId, data.transferGangId)
	cb(success)
end)

RegisterNUICallback("transfer_zone", function(data, cb)
	local success = AwaitServerCallback("electus_gangs:transferZone", data.zoneId, data.transferGangId, data?.admin)
	cb(success)
end)
