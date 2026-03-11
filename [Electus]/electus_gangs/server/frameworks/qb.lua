if (Config.Framework ~= "qbcore") and (Config.Framework ~= "auto" or GetResourceState("qbcore") ~= "started") then
	return
end

QBCore = exports["qb-core"]:GetCoreObject()

function GetPlayer(source)
	if type(source) == "string" then
		source = tonumber(source)
	end

	local player = QBCore.Functions.GetPlayer(source)
	return player
end

function IsAdmin(source)
	if type(source) == "string" then
		source = tonumber(source)
	end

	local hasPerms = QBCore.Functions.HasPermission(source, Config.AdminGroupName)

	return hasPerms or IsPlayerAceAllowed(tostring(source), "command")
end

function GetPlayerFromIdentifier(identifier)
	local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
	return player
end

function GetPlayerSource(player)
	return tonumber(player.PlayerData.source)
end

function RemoveBankMoney(player, amount)
	player.Functions.RemoveMoney("bank", amount)
end

function RemoveCashMoney(player, amount)
	player.Functions.RemoveMoney("cash", amount)
end

function AddCashMoney(player, amount)
	player.Functions.AddMoney("cash", amount)
end

function AddBankMoney(player, amount)
	player.Functions.AddMoney("bank", amount)
end

function AddDirtyMoney(player, amount)
	AddItemTemp(player.PlayerData.source, Config.DirtyCashItem, amount)
end

function RemoveDirtyMoney(player, amount)
	RemoveItemTemp(player.PlayerData.source, Config.DirtyCashItem, amount)
end

function GetBankMoney(player)
	return player.Functions.GetMoney("bank")
end

function GetCashMoney(player)
	return player.Functions.GetMoney("cash")
end

function GetDirtyMoney(player)
	return GetItemCountTemp(GetPlayerSource(player), Config.DirtyCashItem)
end

function GetCharacterName(player)
	return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
end

function GetIdentifierName(identifier)
	local result = MySQL.Sync.fetchAll("SELECT charinfo FROM players WHERE citizenid = @citizenid", {
		["@citizenid"] = identifier,
	})

	if result[1] then
		local char = json.decode(result[1].charinfo)
		return char.firstname .. " " .. char.lastname
	end
end

function GetAllVehicles(player)
	local identifier = GetIdentifier(player)

	local vehicles = MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid", {
		["@citizenid"] = identifier,
	})

	return vehicles
end

function IsVehiclePersonal(player, plate)
	local identifier = GetIdentifier(player)

	local vehicle =
		MySQL.Sync.fetchAll("SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND plate = @plate", {
			["@citizenid"] = identifier,
			["@plate"] = plate,
		})

	if vehicle[1] then
		return true
	end

	return false
end

function SaveVehicleToPersonalGarage(player, vehProps, garage)
	return UpdateGarage(garage, vehProps)
end

function SaveVehicleToGangGarage(gangId, vehProps)
	local saved = MySQL.Async.execute(
		"UPDATE electus_gangs_vehicles SET `vehicle` = @vehicle WHERE `plate` = @plate AND `gang_id` = @gangId",
		{
			["@stored"] = 1,
			["@vehicle"] = json.encode(vehProps),
			["@plate"] = vehProps.plate,
			["@gangId"] = gangId,
		}
	)
	return saved
end

function GeneratePlate()
	local plate = QBCore.Shared.RandomInt(1)
		.. QBCore.Shared.RandomStr(2)
		.. QBCore.Shared.RandomInt(3)
		.. QBCore.Shared.RandomStr(2)
	local result = MySQL.scalar.await("SELECT plate FROM player_vehicles WHERE plate = ?", { plate })
	if result then
		return GeneratePlate()
	else
		return plate:upper()
	end
end

QBCore.Functions.CreateUseableItem(Config.Items.weedSeed, function(src, item)
	TriggerClientEvent("electus_gangs:placeWeed", src)
end)

if Config.TabletItem then
	QBCore.Functions.CreateUseableItem(Config.TabletItem, function(src)
		local player = GetPlayer(src)
		if player then
			TriggerClientEvent("electus_gangs:openGangTablet", src)
		end
	end)
end

function FrameworkSaveOverrideSpawnCoords(identifier, position)
	local result = MySQL.Async.execute("UPDATE players SET `position` = @position WHERE `citizenid` = @citizenid", {
		["@position"] = json.encode(position),
		["@citizenid"] = identifier,
	})
	return result
end

function GetPoliceJobCount()
	local players = QBCore.Functions.GetPlayers()
	local count = 0

	for i = 1, #players do
		local player = QBCore.Functions.GetPlayer(players[i])

		for j = 1, #Config.PoliceJobs do
			if player.PlayerData.job.name == Config.PoliceJobs[j] then
				count = count + 1
			end
		end
	end

	return count
end
