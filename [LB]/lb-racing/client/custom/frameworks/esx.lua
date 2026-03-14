if Config.Framework ~= "esx" then
    return
end

local ESX = exports.es_extended:getSharedObject()

RegisterNetEvent("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData

    while not ESX.PlayerData.ped or not DoesEntityExist(ESX.PlayerData.ped) do
        Wait(0)
    end

    ESX.PlayerLoaded = true

    RefreshPermissions()
end)

RegisterNetEvent("esx:onPlayerLogout", function()
    ESX.PlayerLoaded = false

    ToggleRacingTablet(false)
end)

AddEventHandler("esx:setPlayerData", function(key, val, last)
    if GetInvokingResource() == "es_extended" and ESX.PlayerData then
        ESX.PlayerData[key] = val

        if key == "dead" and val == true then
            ToggleRacingTablet(false)
        end
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    ESX.PlayerData.job = job

    if #Config.App.BlacklistedJobs > 0 then
        RefreshApps()
    end
end)

---@return string
function GetJob()
    return ESX.PlayerData?.job?.name or ""
end

---@param itemName string
---@return boolean
function HasItem(itemName)
    if GetResourceState("ox_inventory") == "started" then
        return (exports.ox_inventory:Search("count", itemName) or 0) > 0
    elseif GetResourceState("qs-inventory") == "started" then
        return (exports["qs-inventory"]:Search(itemName) or 0) > 0
    end

    if ESX.SearchInventory then
        return (ESX.SearchInventory(itemName, 1) or 0) > 0
    end

    local inventory = ESX.GetPlayerData()?.inventory

    if not inventory then
        infoprint("warning", "Unsupported inventory, modify ^4HasItem^7 in ^4lb-racing/client/custom/frameworks/esx.lua^7 to make it work.")
        return false
    end

    for i = 1, #inventory do
        local item = inventory[i]

        if item.name == itemName and item.count > 0 then
            return true
        end
    end

    return false
end

RegisterNetEvent("esx:addInventoryItem", function(item, count)
    if not Config.App.RequireItem then
        return
    end

    if Config.App.RequireItem == item and HasItem(item) then
        RefreshApps()
    end
end)

RegisterNetEvent("esx:removeInventoryItem", function(item, count)
    if (not Config.Standalone.RequireItem or not Config.Standalone.Enabled) and not Config.App.RequireItem then
        return
    end

    if Config.Standalone.Enabled and Config.Standalone.RequireItem == item and not HasItem(item) then
        ToggleRacingTablet(false)
    end

    if Config.App.RequireItem == item and not HasItem(item) then
        RefreshApps()
    end
end)

local isHandcuffed = false

RegisterNetEvent("esx_policejob:handcuff", function()
	isHandcuffed = not isHandcuffed

    if isHandcuffed then
        ToggleRacingTablet(false)
    end
end)

CreateThread(function()
    AddCanOpenCheck(function()
        if not ESX.PlayerLoaded then
            debugprint("Cannot open racing tablet, ESX player not loaded")
            return false
        end

        if ESX.PlayerData?.dead or isHandcuffed then
            debugprint("Cannot open racing tablet, player is dead or handcuffed")
            return false
        end

        return true
    end)
end)
