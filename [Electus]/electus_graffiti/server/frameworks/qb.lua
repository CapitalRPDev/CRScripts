if (Config.Framework ~= "qb") and (Config.Framework ~= "auto" or GetResourceState("qb-core") ~= "started") then
	return
end

QBCore = exports["qb-core"]:GetCoreObject()

function GetPlayer(source)
	local player = QBCore.Functions.GetPlayer(source)
	return player
end

function GetIdentifier(player)
	if player then
		return player.PlayerData.citizenid
	end
end

function GetPlayerFromIdentifier(identifier)
	local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
	return player
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

function GetBankMoney(player)
	return player.Functions.GetMoney("bank")
end

function GetCashMoney(player)
	return player.Functions.GetMoney("cash")
end

function GetCharacterName(player)
	return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
end

function GetIdentifierName(identifier)
	local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM players WHERE citizenid = @citizenid", {
		["@citizenid"] = identifier,
	})

	if result[1] then
		return result[1].firstname .. " " .. result[1].lastname
	end
end

QBCore.Functions.CreateUseableItem(Config.Items.spraycan, function(src, item)
	TriggerClientEvent("electus_gangs:placeSpraycan", src)
end)
