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

function GetPlayer(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	return xPlayer
end

function GetIdentifier(player)
	if player then
		return player.getIdentifier()
	end
end

function IsAdmin(source)
	local xPlayer = GetPlayer(source)
	if xPlayer.getGroup() == Config.AdminGroupName then
		return true
	end

	return false
end

function GetPlayerFromIdentifier(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	return xPlayer
end

function RemoveBankMoney(player, amount)
	player.removeAccountMoney("bank", amount)
end

function RemoveCashMoney(player, amount)
	player.removeAccountMoney("money", amount)
end

function AddCashMoney(player, amount)
	player.addAccountMoney("money", amount)
end

function AddBankMoney(player, amount)
	player.addAccountMoney("bank", amount)
end

function GetBankMoney(player)
	return player.getAccount("bank").money
end

function GetCashMoney(player)
	return player.getAccount("money").money
end

function GetCharacterName(player)
	return player.getName()
end

function GetIdentifierName(identifier)
	local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {
		["@identifier"] = identifier,
	})

	if result[1] then
		return result[1].firstname .. " " .. result[1].lastname
	end

	return "Unknown"
end

ESX.RegisterUsableItem(Config.Items.spraycan, function(src)
	TriggerClientEvent("electus_gangs:placeSpraycan", src)
end)
