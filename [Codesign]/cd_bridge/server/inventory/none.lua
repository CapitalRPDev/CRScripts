if Cfg.Inventory ~= 'none' then return end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    return true
end

-- Add item to a player's inventory
function RemoveItem(source, item_name, amount)

end

-- Remove item from a player's inventory
function GetItemCount(source, item_name)
    return 10000
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return true
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)

end

-- Check if a player can carry a specific item and amount
function GetItemList()
    return {}
end

-- Get inventory images
function GetInventoryImages()
    return {}
end

-- Returns the first item containing the item name
function ReturnFirstItem(source, item_name)
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil
function AddQualityToItem(source, item_name, hp, slot)
    return nil
end

-- Returns the first item quality it finds
function GetItemQuality(source, item_name, slot)
    return 100
end

-- Sets quality to the first item thats not nil and is > 0
function SetItemQuality(source, item_name, hp, slot)
    return nil
end