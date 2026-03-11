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

--- @param source number
--- @return table
function GetPlayer(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	return xPlayer
end

function IsAdmin(source)
	source = tonumber(source)
	local xPlayer = GetPlayer(source)

	if xPlayer.getGroup() == Config.AdminGroupName or IsPlayerAceAllowed(tostring(source), "command") then
		return true
	end

	return false
end

function GetPlayerFromIdentifier(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	return xPlayer
end

function GetPlayerSource(player)
	return tonumber(player.source)
end

function RemoveBankMoney(player, amount)
	player.removeAccountMoney("bank", amount)
end

function RemoveCashMoney(player, amount)
	player.removeAccountMoney("money", amount)
end

function RemoveDirtyMoney(player, amount)
	player.removeAccountMoney("black_money", amount)
end

function AddCashMoney(player, amount)
	player.addAccountMoney("money", amount)
end

function AddBankMoney(player, amount)
	player.addAccountMoney("bank", amount)
end

function AddDirtyMoney(player, amount)
	player.addAccountMoney("black_money", amount)
end

function GetBankMoney(player)
	return player.getAccount("bank").money
end

function GetCashMoney(player)
	return player.getAccount("money").money
end

function GetDirtyMoney(player)
	return player.getAccount("black_money").money
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

function GetAllVehicles(player, parking)
	local identifier = GetIdentifier(player)

	local vehicles = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner", {
		["@owner"] = identifier,
		-- ['@parking'] = parking
	})

	return vehicles
end

function IsVehiclePersonal(player, plate)
	local identifier = GetIdentifier(player)

	local result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
		["@owner"] = identifier,
		["@plate"] = plate,
	})

	if result[1] then
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
			["@vehicle"] = json.encode(vehProps),
			["@plate"] = vehProps.plate,
			["@gangId"] = gangId,
		}
	)
	return saved
end

function GeneratePlate()
	local format = "cccsnnn"
	local plate = ""

	for i = 1, #format do
		local plateFormatter = format:sub(i, i)
		if plateFormatter == "n" then
			plate = plate .. math.random(0, 9)
		elseif plateFormatter == "c" then
			plate = plate .. string.char(math.random(65, 90))
		elseif plateFormatter == "s" then
			plate = plate .. " "
		end
	end

	local result =
		MySQL.Sync.fetchAll("SELECT plate FROM owned_vehicles WHERE plate = @plate", { { ["@plate"] = plate } })
	local gangResult =
		MySQL.Sync.fetchAll("SELECT plate FROM electus_gangs_vehicles WHERE plate = @plate", { { ["@plate"] = plate } })

	if result[1] or gangResult[1] then
		return GeneratePlate()
	else
		return plate:upper()
	end
end

if Config.TabletItem then
	ESX.RegisterUsableItem(Config.TabletItem, function(src)
		local xPlayer = GetPlayer(src)
		if xPlayer then
			TriggerClientEvent("electus_gangs:openGangTablet", src)
		end
	end)
end

ESX.RegisterUsableItem(Config.Items.weedSeed, function(src)
	TriggerClientEvent("electus_gangs:placeWeed", src)
end)

function FrameworkSaveOverrideSpawnCoords(identifier, coords)
	local saved = MySQL.Async.execute("UPDATE users SET `position` = @position WHERE `identifier` = @identifier", {
		["@position"] = json.encode(coords),
		["@identifier"] = identifier,
	})

	return saved
end

function GetPoliceJobCount()
	local count = 0
	local xPlayers = ESX.GetExtendedPlayers()

	for _, xPlayer in pairs(xPlayers) do
		if xPlayer then
			for j = 1, #Config.PoliceJobs do
				if xPlayer.getJob()?.name == Config.PoliceJobs[j] then
					count = count + 1
				end
			end
		end
	end

	return count
end
