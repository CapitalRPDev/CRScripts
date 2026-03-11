RegisterNetEvent("electus_gangs:recruitMember", function(gangId)
	local src = source
	local identifier = GetIdentifier(src)

	MySQL.Sync.execute("INSERT INTO electus_gangs_members (gang_id, identifier) VALUES (@gang_id, @identifier)", {
		["@gang_id"] = gangId,
		["@identifier"] = identifier,
	})

	if CachedGangs[gangId] then
		CachedGangs[gangId].totalMembers = CachedGangs[gangId].totalMembers + 1
	end

	ChangeGangRep(gangId, Config.GangReputation.recruitMember)
	AdminLog(src, "info", L("recruited"), {
		["gangId"] = gangId,
		["player"] = identifier,
	})

	print("recruitMember")
	TriggerClientEvent("electus_gangs:fullUpdateCharacter", src)
end)

function GainXP(gangId, amount)
	local gang = GetGang(gangId)

	if gang and gang.xp + amount >= Config.XpNeededForNextLevel then
		LevelUp(gangId)
	else
		MySQL.Sync.execute("UPDATE electus_gangs SET xp = xp + @amount WHERE gang_id = @gang_id", {
			["@gang_id"] = gangId,
			["@amount"] = amount,
		})

		if CachedGangs[gangId] then
			CachedGangs[gangId].xp = CachedGangs[gangId].xp + amount
		end
	end
end

function LevelUp(gangId)
	MySQL.Sync.execute("UPDATE electus_gangs SET level = level + 1, xp = 0 WHERE gang_id = @gang_id", {
		["@gang_id"] = gangId,
	})

	if CachedGangs[gangId] then
		CachedGangs[gangId].level = CachedGangs[gangId].level + 1
		CachedGangs[gangId].xp = 0
	end
end

function SecurityCheck(source, checkGangId)
	local gangId = GetPlayerGangId(source)

	if not gangId then
		AdminLog(source, "error", L("tried_event_not_in_gang"))
	end

	if gangId ~= checkGangId then
		AdminLog(source, "error", L("tried_event_not_in_gang"))
	end

	return true
end

RegisterNetEvent("electus_gangs:startMission", function(gangId, missionId, members)
	for i = 1, #members do
		local player = GetPlayer(members[i])
		TriggerClientEvent("electus_gangs:missionStarted", player, gangId, missionId)
	end
end)

RegisterNetEvent("electus_gangs:createGang", function(name, safeHouseZoneId, owner)
	owner = tonumber(owner)
	local src = source
	local targetPlayer = GetPlayer(owner)
	local targetSource = GetPlayerSource(targetPlayer)

	if not owner then
		return debugprint("owner is nil")
	end

	if not IsAdmin(src) then
		return Notify(src, L("no_permissions"), "error")
	end

	local gangs = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs")
	local identifier = GetIdentifier(owner)

	for i = 1, #gangs do
		if gangs[i].owner == identifier then
			return Notify(src, L("manage_zones.already_in_gang"), "error")
		end

		if gangs[i].gang_name == name then
			return Notify(src, L("manage_zones.gang_name_already_exists"), "error")
		end

		if gangs[i].safe_house_zone_id == safeHouseZoneId and safeHouseZoneId ~= -1 then
			return Notify(src, L("manage_zones.safe_house_already_exists"), "error")
		end
	end

	MySQL.update.await(
		"INSERT INTO electus_gangs (name, owner, safe_house_zone) VALUES (@name, @owner, @safe_house_zone)",
		{
			["@name"] = name,
			["@owner"] = identifier,
			["@safe_house_zone"] = safeHouseZoneId,
		}
	)

	if targetSource then
		TriggerClientEvent("electus_gangs:fullUpdateCharacter", targetSource)
	end

	Notify(src, L("manage_zones.gang_created"), "success")
end)

RegisterNetEvent("electus_gangs:sendRecruitRequest", function(gangId, playerId)
	local src = source
	local targetPlayer = GetPlayer(tonumber(playerId))
	local permissions = GetPlayerPermissions(src)
	local isAlreadyInGang = GetPlayerGangId(targetPlayer)

	if Config.MaxMembers > 0 and #GetMembersFromGangId(gangId) >= Config.MaxMembers then
		Notify(src, L("menu.max_members_reached"), "error")
		return
	end

	if isAlreadyInGang then
		Notify(src, L("manage_zones.already_in_gang"), "error")
		return
	end

	if not permissions.recruit then
		Notify(src, L("no_permissions"), "error")
		return
	end

	if not targetPlayer then
		Notify(src, L("player_not_online"), "error")
		return
	end

	local gangName = MySQL.Sync.fetchScalar("SELECT name FROM electus_gangs WHERE gang_id = @gang_id", {
		["@gang_id"] = gangId,
	})

	TriggerClientEvent("electus_gangs:receiveRecruitRequest", playerId, gangId, gangName)
	Notify(src, L("recruit_request_sent"), "success")
end)

function GetGangName(gangId)
	if CachedGangs[gangId] then
		return CachedGangs[gangId].name
	end

	local gangName = MySQL.Sync.fetchAll("SELECT name FROM electus_gangs WHERE gang_id = @gang_id", {
		["@gang_id"] = gangId,
	})

	return gangName[1]?.name or "Gang not found"
end

lib.addCommand("manage_gangs", {
	help = "Manage gangs",
	restricted = "group.admin",
}, function(src, args)
	TriggerClientEvent("electus_gangs:manageGangs", src)
end)

lib.addCommand("manage_zones", {
	help = "Mangage zones",
	restricted = "group.admin",
}, function(src, args)
	TriggerClientEvent("electus_gangs:manageZones", src)
end)
