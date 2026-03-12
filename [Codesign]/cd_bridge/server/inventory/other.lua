if Cfg.Inventory ~= 'other' then return end

-- Check if a player has a specific item and amount
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param amount      number   The required amount.
--- @return boolean    --True if the player has at least `amount` of `item_name`, false otherwise.
function HasItem(source, item_name, amount)
    return true
end

-- Add item to a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to add.
--- @param amount      number   The amount to add.
function AddItem(source, item_name, amount)

end

-- Remove item from a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to remove.
--- @param amount      number   The amount remove.
function RemoveItem(source, item_name, amount)

end

-- Get the count of a specific item in a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @return number              --The amount of `item_name` the player has.
function GetItemCount(source, item_name)
    return 0
end

-- Check if a player can carry a specific item and amount
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param amount      number   The amount to check for.
--- @return boolean             --True if the player can carry `amount` of `item_name`, false otherwise.
function CanCarryItem(source, item_name, amount)
    return true
end

-- Add weapon to a player's inventory
--- @param source      number   The player's server ID.
--- @param weapon_name string   The weapon to add.
--- @param ammo        number   The amount of ammo to add.
function AddWeapon(source, weapon_name, ammo)

end

-- Check if a player can carry a specific item and amount
--- @return table   --A table of all items in the inventory system.
---                 The returned table must follow this structure:
---                 items['item_label'] = {
---                     name  = 'item_name',
---                     label = 'item_label'
---                 }
function GetItemList()
    return {}
end

-- Get inventory images
--- @return table   --A table of all inventory item images.
---                 The returned table must follow this structure:
---                 images[1] = 'water.png'
function GetInventoryImages()
    return {}
end

-- Returns the first item containing the item name
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @return item.name, item.slot or nil if item not found 
function ReturnFirstItem(source, item_name)
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param hp          number   The amount of quality to add.
--- @param slot        number   The item slot to add quality to (not supported in ESX Inventory).
--- @return string|nil          --The name of the item that had quality added, or nil if no item was found.
function AddQualityToItem(source, item_name, hp, slot)
    return nil
end

-- Returns the first item quality it finds
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param slot        number   The item slot to check quality of (not supported in ESX Inventory).
--- @return number              --The quality of the item, or 100 if no item was found.
function GetItemQuality(source, item_name, slot)
    return 100
end

-- Sets quality to the first item thats not nil and is > 0  
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param hp          number   The amount of quality to set.
--- @param slot        number   The item slot to set quality of (not supported in ESX Inventory).
--- @return string|nil          --The name of the item that had quality set, or nil if no item was found.
function SetItemQuality(source, item_name, hp, slot)
    return nil
end