function AddInventoryItem(src, item, count)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)
		xPlayer.addInventoryItem(item, count)
	elseif Config.Inventory == "qb" then
		local player = QBCore.Functions.GetPlayer(source)
		player.Functions.AddItem(item, count)
	elseif Config.Inventory == "core" then
		exports.core_inventory:addItem(src, item, count)
	elseif Config.Inventory == "qs" then
		exports["qs-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "tgiann" then
		exports["tgiann-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "ox_inventory" then
		exports.ox_inventory:AddItem(src, item, count)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:AddItem(src, item, count)
	elseif Config.Inventory == "codem" then
		exports["codem-inventory"]:AddItem(src, item, count)
	end
end

function RemoveInventoryItem(src, item, count)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)

		xPlayer.removeInventoryItem(item, count)
	elseif Config.Inventory == "qb" then
		local player = QBCore.Functions.GetPlayer(source)

		player.Functions.RemoveItem(item, count)
	elseif Config.Inventory == "core" then
		exports.core_inventory:removeItem(src, item, count)
	elseif Config.Inventory == "qs" then
		exports["qs-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "tgiann" then
		exports["tgiann-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "ox_inventory" then
		exports.ox_inventory:RemoveItem(src, item, count)
	elseif Config.Inventory == "qb-inventory" then
		exports["qb-inventory"]:RemoveItem(src, item, count)
	elseif Config.Inventory == "codem" then
		exports["codem-inventory"]:RemoveItem(src, item, count)
	end
end

function GetInventoryCount(src, item)
	if Config.Inventory == "esx" then
		local xPlayer = ESX.GetPlayerFromId(src)

		return xPlayer.getInventoryItem(item).count
	elseif Config.Inventory == "qb" then
		local player = QBCore.Functions.GetPlayer(src)

		return player.Functions.GetItemByName(item).amount
	elseif Config.Inventory == "core" then
		return exports.core_inventory:getItemCount(src, item)
	elseif Config.Inventory == "qs" then
		return exports["qs-inventory"]:GetItemTotalAmount(src, item)
	elseif Config.Inventory == "tgiann" then
		return exports["tgiann-inventory"]:GetItemCount(src, item)
	elseif Config.Inventory == "ox_inventory" then
		return exports.ox_inventory:GetItemCount(src, item)
	elseif Config.Inventory == "qb-inventory" then
		return exports["qb-inventory"]:GetItemCount(src, item)
	elseif Config.Inventory == "codem" then
		return exports["codem-inventory"]:GetItemsTotalAmount(src, item)
	end
end

function DecreaseDurability(src, item, amount)
	if Config.Inventory == "core" then
		local slot = exports.core_inventory:getFirstSlotByItem(src, item)

		if not slot then
			return false
		end

		local itemdata = exports.core_inventory:getItemBySlot(src, slot)
		exports.core_inventory:removeDurability(src, itemdata.id, amount)
		return true
	elseif Config.Inventory == "qs" then
		local inventory = exports["qs-inventory"]:GetInventory(src)

		for slot, itemData in pairs(inventory) do
			if itemData.name == item then
				itemData.info.quality = itemData.info.quality - amount

				exports["qs-inventory"]:SetItemMetadata(src, slot, itemData.info)

				return true
			end
		end
		-- elseif Config.Inventory == "ox" then
		-- 	local itemData = exports.ox_inventory:GetItem(src, item)

		-- 	if not itemData then
		-- 		return false
		-- 	end

		-- 	exports.ox_inventory:SetDurability(src, itemData.slot, itemData?.durability - amount)
		-- 	return true
	end

	return false
end
