CachedGangs = {}
RegisterServerCallback("electus_gangs:getGangData", function(src, gangId)
	local identifier = GetIdentifier(src)
	local playerName = GetIdentifierName(identifier)

	if CachedGangs[gangId] then
		CachedGangs[gangId].playerName = playerName
		CachedGangs[gangId].isOwner = CachedGangs[gangId].owner == identifier
		return CachedGangs[gangId]
	end

	local gang = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs WHERE gang_id = @gang_id", {
		["@gang_id"] = gangId,
	})

	local retGang = {}

	if not gang[1] then
		return false
	end

	retGang.gangId = gang[1].gang_id
	retGang.gangRep = gang[1].gang_rep
	retGang.name = gang[1].name
	retGang.level = gang[1].level
	retGang.color = gang[1].color
	retGang.dirtyCash = gang[1].dirty_cash
	retGang.cash = gang[1].cash
	retGang.owner = gang[1].owner
	retGang.xp = gang[1].xp
	retGang.safeHouseZoneId = gang[1].safe_house_zone
	retGang.logo = gang[1]?.logo
	retGang.totalMembers =
		MySQL.Sync.fetchScalar("SELECT COUNT(*) FROM electus_gangs_members WHERE gang_id = @gang_id", {
			["@gang_id"] = gangId,
		})
	retGang.nbrZones =
		MySQL.Sync.fetchScalar("SELECT COUNT(*) FROM electus_gangs_zones WHERE controlling_gang_id = @gang_id", {
			["@gang_id"] = gangId,
		})
	retGang.gangRep = gang[1].gang_rep
	retGang.playerName = playerName
	retGang.isOwner = gang[1].owner == identifier

	CachedGangs[gangId] = retGang

	return retGang
end)

RegisterServerCallback("electus_gangs:getOnlinePlayers", function(src)
	local players = {}
	local playerPed = GetPlayerPed(src)

	if Config.SelectPlayerDist ~= -1 then
		local playerCoords = GetEntityCoords(playerPed)

		for _, player in ipairs(GetPlayers()) do
			local targetPed = GetPlayerPed(player)
			local targetCoords = GetEntityCoords(targetPed)

			if #(playerCoords - targetCoords) <= Config.SelectPlayerDist then
				players[#players + 1] = {
					id = player,
					name = GetIdentifierName(GetIdentifier(tonumber(player))),
				}
			end
		end
	else
		for _, player in ipairs(GetPlayers()) do
			players[#players + 1] = {
				id = player,
				name = GetIdentifierName(GetIdentifier(tonumber(player))),
			}
		end
	end

	return players
end)

RegisterServerCallback("electus_gangs:getPlayerGang", function(src)
	local identifier = GetIdentifier(src)

	local isOwner = MySQL.Sync.fetchAll("SELECT name, gang_id FROM electus_gangs WHERE owner = @identifier", {
		["@identifier"] = identifier,
	})

	if isOwner[1] then
		return { gangId = isOwner[1].gang_id, owner = true }
	end

	local gang = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs_members WHERE identifier = @identifier", {
		["@identifier"] = identifier,
	})

	if gang[1] then
		return { gangId = gang[1].gang_id, owner = false }
	end

	return false
end)

RegisterServerCallback("electus_gangs:getIdentifier", function(src, id)
	local player = GetPlayer(tonumber(id))

	if not player then
		return nil
	end

	local identifier = GetIdentifier(tonumber(id))

	return identifier
end)

RegisterServerCallback("electus_gangs:getIdentifierName", function(src, identifier)
	local playerName = GetIdentifierName(identifier)

	return playerName
end)

RegisterServerCallback("electus_gangs:getGangs", function(src)
	local gangs = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs")

	return gangs
end)

RegisterServerCallback("electus_gangs:getLogs", function(src, gangId, page)
	local logs = MySQL.Sync.fetchAll(
		"SELECT * FROM electus_gangs_logs WHERE gang_id = @gang_id ORDER BY id DESC LIMIT @page, @perPage",
		{
			["@gang_id"] = gangId,
			["@page"] = (page - 1) * 12,
			["@perPage"] = 12,
		}
	)

	return logs
end)

RegisterServerCallback("electus_gangs:setGangName", function(src, gangId, name)
	local myGrade = GetPlayerMemberGrade(src)

	if myGrade > 0 then
		Notify(src, L("no_permissions"), "error")
		return
	end

	MySQL.Sync.execute("UPDATE electus_gangs SET name = @name WHERE gang_id = @gang_id", {
		["@name"] = name,
		["@gang_id"] = gangId,
	})

	CachedGangs[gangId] = nil
	Notify(src, L("menu.name_changed"))
end)

RegisterServerCallback("electus_gangs:setGangOwner", function(src, gangId, identifier)
	local myGrade = GetPlayerMemberGrade(src)

	if myGrade > 0 then
		Notify(src, L("no_permissions"), "error")
		return
	end

	MySQL.Sync.execute("UPDATE electus_gangs SET owner = @identifier WHERE gang_id = @gang_id", {
		["@identifier"] = identifier,
		["@gang_id"] = gangId,
	})

	TriggerClientEvent("electus_gangs:playerFired", src)
	TriggerClientEvent("electus_gangs:fullUpdateCharacter", src)

	local newOwner = GetPlayerFromIdentifier(identifier)

	if newOwner then
		local newOwnerSrc = GetPlayerSource(newOwner)
		if newOwnerSrc then
			TriggerClientEvent("electus_gangs:fullUpdateCharacter", newOwnerSrc)
			TriggerClientEvent("electus_gangs:refreshGang", newOwnerSrc)
		end
	end

	CachedGangs[gangId] = nil
	Notify(src, L("menu.owner_changed"))
end)

RegisterServerCallback("electus_gangs:setGangColor", function(src, gangId, color)
	local myGrade = GetPlayerMemberGrade(src)

	if myGrade > 0 then
		Notify(src, L("no_permissions"), "error")
		return false
	end

	MySQL.Sync.execute("UPDATE electus_gangs SET color = @color WHERE gang_id = @gang_id", {
		["@color"] = color,
		["@gang_id"] = gangId,
	})

	CachedGangs[gangId] = nil
	Notify(src, L("menu.color_changed"))
	return true
end)

RegisterServerCallback("electus_gangs:getScoreboard", function(src)
	local gangs = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs ORDER BY gang_rep DESC")

	return gangs
end)

RegisterServerCallback("electus_gangs:updateGang", function(src, gang)
	if not IsAdmin(src) then
		return Notify(src, L("no_permissions"), "error")
	end

	local gangs = MySQL.Sync.fetchAll("SELECT * FROM electus_gangs")

	for i = 1, #gangs do
		if gangs[i].gang_id ~= gang.gang_id then
			if gangs[i].name == gang.name then
				Notify(src, L("manage_zones.gang_name_already_exists"), "error")
				return
			end
			if gangs[i].safe_house_zone == tonumber(gang.safe_house_zone) and not gang.safe_house_zone == -1 then
				Notify(src, L("manage_zones.safe_house_already_exists"), "error")
				return
			end

			if gangs[i].owner == gang.owner then
				Notify(src, L("manage_zones.already_in_gang"), "error")
				return
			end
		end
	end

	MySQL.Sync.execute(
		"UPDATE electus_gangs SET owner = @owner, name = @name, color = @color, safe_house_zone = @safe_house_zone, cash = @cash, dirty_cash = @dirty_cash, gang_rep = @gang_rep, level = @level, logo = @logo WHERE gang_id = @gang_id",
		{
			["@owner"] = gang.owner,
			["@name"] = gang.name,
			["@color"] = gang.color,
			["@gang_id"] = tonumber(gang.gang_id),
			["@safe_house_zone"] = tonumber(gang.safe_house_zone),
			["@cash"] = tonumber(gang.cash),
			["@dirty_cash"] = tonumber(gang.dirty_cash),
			["@gang_rep"] = tonumber(gang.gang_rep),
			["@level"] = tonumber(gang.level),
			["@logo"] = gang.logo,
		}
	)

	CachedGangs[gang.gang_id] = nil
	Notify(src, L("gang_updated"))

	local members = GetMembersFromGangId(gang.gang_id)

	for i = 1, #members do
		local player = GetPlayerFromIdentifier(members[i].identifier)

		if player then
			TriggerClientEvent("electus_gangs:fullUpdateCharacter", GetPlayerSource(player))
		end
	end

	return true
end)

RegisterServerCallback("electus_gangs:removeGang", function(src, gangId)
	if not IsAdmin(src) then
		return Notify(src, L("no_permissions"), "error")
	end

	local members = GetMembersFromGangId(gangId)

	MySQL.Sync.execute("DELETE FROM electus_gangs WHERE gang_id = @gang_id", {
		["@gang_id"] = gangId,
	})

	AdminLog(src, "info", L("gang_removed"), {
		["GangId"] = gangId,
	})

	for i = 1, #members do
		local player = GetPlayerFromIdentifier(members[i].identifier)

		if player then
			local targetSource = GetPlayerSource(player)

			if targetSource then
				TriggerClientEvent("electus_gangs:fullUpdateCharacter", src)
			end
		end
	end
end)

RegisterServerCallback("electus_gangs:changeRole", function(src, gangId, identifier, roleId)
	local player = GetPlayer(src)
	local playerIdentifier = GetIdentifier(src)

	if playerIdentifier == identifier then
		Notify(src, L("cant_change_own_role"))
		return false
	end

	local myRoleId = GetPlayerMemberRoleId(src)
	local permission = GetPermissionsFromRole(myRoleId)

	if not permission.edit then
		Notify(src, L("no_permissions"), "error")
		return false
	end

	local myGrade = GetPlayerMemberGrade(src)
	local gradeFromRoleId = MySQL.Sync.fetchScalar("SELECT grade FROM electus_gangs_roles WHERE role_id = @role_id", {
		["@role_id"] = roleId,
	})

	if roleId == 0 then
		Notify(src, L("cant_change_owner_role"), "error")
		return false
	end

	if gradeFromRoleId <= myGrade then
		Notify(src, L("no_permissions"), "error")
		return false
	end

	local succ = MySQL.Sync.execute(
		"UPDATE electus_gangs_members SET role_id = @role_id WHERE identifier = @identifier AND gang_id = @gang_id",
		{
			["@role_id"] = roleId,
			["@identifier"] = identifier,
			["@gang_id"] = gangId,
		}
	)
	return succ
end)

RegisterServerCallback("electus_gangs:getMyRoleId", function(src)
	local identifier = GetIdentifier(src)

	local roleId = MySQL.Sync.fetchScalar("SELECT role_id FROM electus_gangs_members WHERE identifier = @identifier", {
		["@identifier"] = identifier,
	})

	local owner = MySQL.Sync.fetchScalar("SELECT gang_id FROM electus_gangs WHERE owner = @identifier", {
		["@identifier"] = identifier,
	})

	if owner then
		return 0
	end

	return roleId
end)

RegisterServerCallback("electus_gangs:getGangOwnedZones", function(src, gangId)
	return GetGangOwnedZones(gangId)
end)

RegisterServerCallback("electus_gangs:getGangFromZoneId", function(src, zoneId)
	return GetGangFromZoneId(zoneId) or false
end)

RegisterServerCallback("electus_gangs:hasItem", function(src, item)
	-- print(json.encode(GetItemCount(src, item)))

	return GetItemCountTemp(src, item) > 0
end)
