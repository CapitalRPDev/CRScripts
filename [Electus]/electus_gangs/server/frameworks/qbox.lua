if (Config.Framework ~= "qbox") and (Config.Framework ~= "auto" or GetResourceState("qbx_core") ~= "started") then
	return
end

function GetPlayer(source)
	local player = exports.qbx_core:GetPlayer(source)
	return player
end

function IsAdmin(source)
	return IsPlayerAceAllowed(source, Config.AdminGroupName) or IsPlayerAceAllowed(tostring(source), "command")
end

function GetPlayerFromIdentifier(identifier)
	local player = exports.qbx_core:GetPlayerByCitizenId(identifier)
	return player
end

function GetPlayerSource(player)
	return tonumber(player.PlayerData.source)
end

function RemoveBankMoney(player, amount)
	exports.qbx_core:RemoveMoney(player.PlayerData.citizenid, "bank", amount, "Unknown")
end

function RemoveCashMoney(player, amount)
	exports.qbx_core:RemoveMoney(player.PlayerData.citizenid, "cash", amount, "Unknown")
end

function AddCashMoney(player, amount)
	exports.qbx_core:AddMoney(player.PlayerData.citizenid, "cash", amount, "Unknown")
end

function AddBankMoney(player, amount)
	exports.qbx_core:AddMoney(player.PlayerData.citizenid, "bank", amount, "Unknown")
end

function AddDirtyMoney(player, amount)
	AddItemTemp(player.PlayerData.source, Config.DirtyCashItem, amount)
end

function RemoveDirtyMoney(player, amount)
	RemoveItemTemp(player.PlayerData.source, Config.DirtyCashItem, amount)
end

function GetBankMoney(player)
	return exports.qbx_core:GetMoney(player.PlayerData.citizenid, "bank")
end

function GetCashMoney(player)
	return exports.qbx_core:GetMoney(player.PlayerData.citizenid, "cash")
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
	local plate = exports.qbx_core:generateRandomPlate("1AAA111")
	local result = MySQL.scalar.await("SELECT plate FROM player_vehicles WHERE plate = ?", { plate })
	if result then
		return GeneratePlate()
	else
		return plate:upper()
	end
end

exports.qbx_core:CreateUseableItem(Config.Items.weedSeed, function(source, item)
	TriggerClientEvent("electus_gangs:placeWeed", source)
end)

if Config.TabletItem then
	exports.qbx_core:CreateUseableItem(Config.TabletItem, function(src)
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
	local count = 0
	for i = 1, #Config.PoliceJobs do
		local job = Config.PoliceJobs[i]
		local jobCount = exports.qbx_core:GetDutyCountJob(job)
		count = count + jobCount
	end
	return count
end
