if Cfg.Inventory ~= 'ox_inventory' then return end

local ItemList = {}
local InventoryImages = {}

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    local has_item = exports['ox_inventory']:GetItem(source, item_name, nil, false)
    if has_item.count >= amount then
        return true
    end
    return false
end

-- Add item to a player's inventory
function AddItem(source, item_name, amount)
    exports['ox_inventory']:AddItem(source, item_name, amount)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount)
    exports['ox_inventory']:RemoveItem(source, item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item = exports['ox_inventory']:GetItem(source, item_name, nil, false)
    if item then
        return item.count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports['ox_inventory']:CanCarryItem(source, item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    AddItem(source, weapon_name, 1)
end

-- Check if a player can carry a specific item and amount
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end
    local ox_items = exports['ox_inventory']:Items()
    if ox_items then
        for item_name, row in pairs(ox_items) do
            ItemList[item_name] = {
                name = item_name,
                label = row.label
            }
        end
    end
    return ItemList
end

-- Get inventory images
function GetInventoryImages()
    if next(InventoryImages) ~= nil then
        return InventoryImages
    end
    local images = exports['cd_bridge']:ReadNUIDirectory(
        GetResourcePath('ox_inventory')..'/web/images',
        'ox_inventory/web/images/',
        {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    )
    if images then
        InventoryImages = images
    end
    return InventoryImages
end

-- Returns the first item containing the item name
function ReturnFirstItem(source, item_name)
    local playerItems = exports.ox_inventory:GetInventoryItems(source)
    for _, item in pairs(playerItems) do
        if string.find(item.name, item_name) then
            return item.name, item.slot
        end
    end
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil
function AddQualityToItem(source, item_name, hp, slot)
    local playerItems = exports.ox_inventory:GetInventoryItems(source)
    if slot ~= nil and playerItems[slot].durability == nil then
        playerItems[slot].durability = hp
        return
    end
    AddItem(source, item_name, 1)
    for _, item in pairs(playerItems) do
        if item.name == item_name and item.duribility == nil then
            item.durability = hp
            return
        end
    end
end

-- Returns the first item quality it finds
function GetItemQuality(source, item_name, slot)
    local playerItems = exports.ox_inventory:GetInventoryItems(source)
    if slot ~= nil then
        return playerItems[slot].metadata.durability
    end
    for _, item in pairs(playerItems) do
        if item.name == item_name then
            return item.metadata.durability
        end
    end
    return nil
end

-- Sets quality to the first item thats not nil and is > 0 
function SetItemQuality(source, item_name, hp, slot)
    local playerItems = exports.ox_inventory:GetInventoryItems(source)
    if slot ~= nil then
        exports['ox_inventory']:SetDurability(source, slot, hp)
        return
    end
    for _, item in pairs(playerItems) do
        if item.name == item_name then
            exports['ox_inventory']:SetDurability(source, item.slot, hp)
            return
        end
    end
    return nil
end