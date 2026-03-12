if Cfg.Inventory ~= 'qb-inventory' then return end

local ItemList = {}
local InventoryImages = {}

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    local has_item = exports['qb-inventory']:HasItem(source, item_name, amount)
    if has_item  then
        return true
    end
    return false
end

-- Add item to a player's inventory
function AddItem(source, item_name, amount)
    exports['qb-inventory']:AddItem(source, item_name, amount)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount)
    exports['qb-inventory']:RemoveItem(source, item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports['qb-inventory']:GetItemCount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    local canAdd, reason = exports['qb-inventory']:CanAddItem(source, item_name, amount)
    return canAdd
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
    local qb_items = QBCore.Shared.Items
    if qb_items then
        for name, row in pairs(qb_items) do
            ItemList[name or row.name] = {
                name = name or row.name,
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
        GetResourcePath('qb-inventory')..'/html/images',
        'qb-inventory/html/images/',
        {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    )
    if images then
        InventoryImages = images
    end
    return InventoryImages
end

-- Returns the first item containing the item name
function ReturnFirstItem(source, item_name)
    local Player = GetPlayer(source)
    if not Player then return end

    local PlayerItems = Player.PlayerData.items
    for _, item in pairs(PlayerItems) do
        if string.find(item.name, item_name) then
            return item.name, item.slot
        end
    end
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil
function AddQualityToItem(source, item_name, hp, slot)
    local Player = GetPlayer(source)
    if not Player then return end

    local PlayerItems = Player.PlayerData.items
    if slot ~= nil then
        PlayerItems[slot].info.quality = hp
    end
    for _, item in pairs(PlayerItems) do
        if item.name == item_name and item.info.quality == nil then
            item.info.quality = hp
            Player.Functions.SetInventory(Player.PlayerData.items, true)
            return
        end
    end
    return nil
end

-- Returns the first item quality it finds
function GetItemQuality(source, item_name, slot)
    local Player = GetPlayer(source)
    if not Player then return end

    local PlayerItems = Player.PlayerData.items
    if slot ~= nil then
        return PlayerItems[slot].info.quality
    end
    for _, item in pairs(PlayerItems) do
        if item.name == item_name then
            return item.info.quality
        end
    end
    return nil
end

-- Sets quality to the first item thats not nil and is > 0 
function SetItemQuality(source, item_name, hp, slot)
    local Player = GetPlayer(source)
    if not Player then return end

    local PlayerItems = Player.PlayerData.items
    if slot ~= nil then
        PlayerItems[slot].info.quality = hp
    end
    for _, item in pairs(PlayerItems) do
        if item.name == item_name and item.info.quality ~= nil and item.info.quality > 0 then
            item.info.quality = hp
            Player.Functions.SetInventory(Player.PlayerData.items, true)
            return
        end
    end
end