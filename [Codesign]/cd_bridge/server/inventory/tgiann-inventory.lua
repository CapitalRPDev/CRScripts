if Cfg.Inventory ~= 'tgiann-inventory' then return end

local ItemList = {}

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    return exports["tgiann-inventory"]:HasItem(source, item_name, amount)
end

-- Add item to a player's inventory
function AddItem(source, item_name, amount)
    exports["tgiann-inventory"]:AddItem(source, item_name, amount)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount)
    exports["tgiann-inventory"]:RemoveItem(source, item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local Player = GetPlayer(source)
    if not Player then return 0 end

    local item_count = exports["tgiann-inventory"]:GetItem(source, item_name, nil, true)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports["tgiann-inventory"]:CanCarryItem(source, item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    AddItem(source, weapon_name, 1)
end

-- Get the list of all items in the database
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end
    for _, row in pairs(exports["tgiann-inventory"]:GetItemList()) do
        ItemList[row.name] = {
            name = row.name,
            label = row.label
        }
    end
    return ItemList
end

-- Get inventory images
function GetInventoryImages()
    if next(InventoryImages) ~= nil then
        return InventoryImages
    end
    local images = exports['cd_bridge']:ReadNUIDirectory(
        GetResourcePath('tgiann-inventory')..'/inventory_images/images',
        'tgiann-inventory/inventory_images/images/',
        {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    )
    if images then
        InventoryImages = images
    end
    return InventoryImages
end

-- Returns the first item containing the item name
function ReturnFirstItem(source, item_name)
    local inventory = exports["tgiann-inventory"]:GetInventory(source)
    for _, item in pairs(inventory) do
        if string.find(item.name, item_name) then
            return item.name, item.slot
        end
    end
    return nil
end

-- Adds quality to first item that matches item_name and has quality nil
function AddQualityToItem(source, item_name, hp, slot)
    local inventory = exports["tgiann-inventory"]:GetInventory(source)
    if slot ~= nil then
        inventory[slot].durability = hp
    end
    for _, item in pairs(inventory) do
        if item.name == item_name and item.durability == nil then
            item.durability = hp
            return
        end
    end
    return nil
end

-- Returns the first item quality it finds
function GetItemQuality(source, item_name, slot)
    local inventory = exports["tgiann-inventory"]:GetInventory(source)
    if slot ~= nil then
        return inventory[slot].durability
    end
    for _, items in pairs(inventory) do
        if item.name == item_name then
            return item.durability
        end
    end
    return nil
end

-- Sets quality to the first item thats not nil and is > 0 
function SetItemQuality(source, item_name, hp, slot)
    local inventory = exports["tgiann-inventory"]:GetInventory(source)
    if slot ~= nil then
        inventory[slot].durability = hp
    end
    for _, item in pairs(PlayerItems) do
        if item.name == item_name and item.durability ~= nil and item.durability > 0 then
            item.durability = hp
            return
        end
    end
    return nil
end