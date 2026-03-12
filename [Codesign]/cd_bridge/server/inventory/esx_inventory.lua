if Cfg.Inventory ~= 'esx_inventory' then return end

local ItemList = {}

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    local has_item = Player.hasItem(item_name)
    if has_item and has_item.count >= amount then
        return true
    end
    return false
end

-- Add item to a player's inventory
function AddItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    Player.addInventoryItem(item_name, amount)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    Player.removeInventoryItem(item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local Player = GetPlayer(source)
    if not Player then return 0 end

    local item = Player.hasItem(item_name)
    if item then
        return item.count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.canCarryItem(item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    local Player = GetPlayer(source)
    if not Player then return false end

    Player.addWeapon(weapon_name, ammo)
end

-- Get the list of all items in the database
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end
    local DB_items = DB.fetch('SELECT name, label FROM items')
    if DB_items then
        for _, row in pairs(DB_items) do
            ItemList[row.name] = {
                name = row.name,
                label = row.label
            }
        end
    end
    return ItemList
end

-- Get inventory images (not supported in ESX Inventory)
function GetInventoryImages()
    return {}
end

-- Returns the first item containing the item name (esx doesn't have a slot system)
function ReturnFirstItem(source, item_name)
    local Player = GetPlayer(source)
    if not Player then return end

    local inventory = Player.inventory
    for _, item in pairs(inventory) do
        if item.count > 0 and item.name == item_name then
            return item.name, 1
        end
    end
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil (esx doesn't support quality/durability of items)
function AddQualityToItem(source, item_name, hp, slot)
    return nil
end

-- Returns the first item quality it finds (esx doesn't support quality/durability of items)
function GetItemQuality(source, item_name, slot)
    return 100
end

-- Sets quality to the first item thats not nil and is > 0  (esx doesn't support quality/durability of items)
function SetItemQuality(source, item_name, hp, slot)
    return nil
end