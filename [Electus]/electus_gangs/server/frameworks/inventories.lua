function AddItemTemp(src, item, count)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)
		xPlayer.addInventoryItem(item, count)
	elseif Config.Inventory == "qb-core" then
		local player = QBCore.Functions.GetPlayer(source)
		player.Functions.AddItem(item, count)
	elseif Config.Inventory == "core" then
		exports.core_inventory:addItem(src, item, count)
	elseif Config.Inventory == "qs-inventory" then
		exports["qs-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "tgiann" then
		exports["tgiann-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "ox_inventory" then
		exports.ox_inventory:AddItem(src, item, count)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "ps-inventory" then
		return exports["ps-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "codem" then
		exports["codem-inventory"]:AddItem(src, item, count)
	end
end

function RemoveItemTemp(src, item, count)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)

		xPlayer.removeInventoryItem(item, count)
	elseif Config.Inventory == "qb-core" then
		local player = QBCore.Functions.GetPlayer(source)

		player.Functions.RemoveItem(item, count)
	elseif Config.Inventory == "core" then
		exports.core_inventory:removeItem(src, item, count)
	elseif Config.Inventory == "qs-inventory" then
		exports["qs-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "tgiann" then
		exports["tgiann-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "ox_inventory" then
		exports.ox_inventory:RemoveItem(src, item, count)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "ps-inventory" then
		return exports["ps-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "codem" then
		exports["codem-inventory"]:RemoveItem(src, item, count)
	end
end

function GetItemCountTemp(src, item)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)

		return xPlayer.getInventoryItem(item).count
	elseif Config.Inventory == "qb-core" then
		local player = QBCore.Functions.GetPlayer(source)

		return player.Functions.GetItemByName(item).amount
	elseif Config.Inventory == "core" then
		return exports.core_inventory:getItemCount(src, item)
	elseif Config.Inventory == "qs-inventory" then
		return exports["qs-inventory"]:GetItemTotalAmount(src, item)
	elseif Config.Inventory == "tgiann" then
		return exports["tgiann-inventory"]:GetItemCount(src, item)
	elseif Config.Inventory == "ox_inventory" then
		return exports.ox_inventory:GetItemCount(src, item)
	elseif Config.Inventory == "qb-inventory" then
		return exports["qb-inventory"]:GetItemCount(src, item)
	elseif Config.Inventory == "ps-inventory" then
		return exports["ps-inventory"]:GetItemCount(src, item)
	elseif Config.Inventory == "codem" then
		return exports["codem-inventory"]:GetItemsTotalAmount(src, item)
	end

	return 0
end

RegisterNetEvent("electus_gangs:openStash", function(crateId, zoneId)
	local src = source
	local player = GetPlayer(src)

	local stashId = zoneId .. ":" .. crateId

	if Config.Inventory == "ox_inventory" then
		exports.ox_inventory:RegisterStash(
			stashId,
			L("warehouse.crate"),
			Config.Warehouse.slots,
			Config.Warehouse.weight
		)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:OpenInventory(
			src,
			stashId,
			{ label = L("warehouse.crate"), maxweight = Config.Warehouse.weight, slots = Config.Warehouse.slots }
		)
	elseif Config.Inventory == "ps-inventory" then
		exports["ps-inventory"]:OpenInventory(
			src,
			stashId,
			{ label = L("warehouse.crate"), maxweight = Config.Warehouse.weight, slots = Config.Warehouse.slots }
		)
	elseif Config.Inventory == "core" then
		stashId = zoneId .. "-" .. crateId
		exports.core_inventory:openInventory(nil, stashId, "stash", nil, nil, false, nil, false)

		exports.core_inventory:openInventory(src, stashId, L("warehouse.crate"), "stash", nil, nil, true, nil, false)
	end
end)

function SearchPlayer(src, playerId)
	if Config.Inventory == "ox_inventory" then
		exports.ox_inventory:forceOpenInventory(src, "player", playerId)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:OpenInventoryById(src, playerId)
	elseif Config.Inventory == "ps-inventory" then
		exports["ps-inventory"]:OpenInventoryById(src, playerId)
	elseif Config.Inventory == "core" then
		exports.core_inventory:openInventory(src, playerId, "inventory", nil, nil, false, nil, false)
	elseif Config.Inventory == "tgiann-inventory" then
		exports["tgiann-inventory"]:OpenInventory(src, playerId)
	elseif Config.Inventory == "qs-inventory" then
		return true
	end

	return false
end
