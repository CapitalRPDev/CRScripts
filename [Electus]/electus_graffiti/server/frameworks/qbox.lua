if (Config.Framework ~= "qbx") and (Config.Framework ~= "auto" or GetResourceState("qbx_core") ~= "started") then
	return
end

function GetPlayer(source)
	local player = exports.qbx_core:GetPlayer(source)
	return player
end

function GetIdentifier(player)
	if player then
		return player.PlayerData.citizenid
	end
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

function GetBankMoney(player)
	return exports.qbx_core:GetMoney(player.PlayerData.citizenid, "bank")
end

function GetCashMoney(player)
	return exports.qbx_core:GetMoney(player.PlayerData.citizenid, "cash")
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

exports.qbx_core:CreateUseableItem(Config.Items.spraycan, function(src, item)
	TriggerClientEvent("electus_gangs:placeSpraycan", src)
end)
