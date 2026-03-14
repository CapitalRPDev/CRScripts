if Config.Framework ~= "qbcore" then
    return
end

local QB = exports["qb-core"]:GetCoreObject()
local PlayerData

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    PlayerData = QB.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QB.Functions.GetPlayerData()

    RefreshPermissions()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    PlayerData = {}

    ToggleRacingTablet(false)
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(newData)
    PlayerData = newData

    local metadata = PlayerData.metadata or {}

    if metadata.ishandcuffed or metadata.isdead or metadata.inlaststand then
        ToggleRacingTablet(false)
    end

    Wait(500)

    if Config.Standalone.Enabled and Config.Standalone.RequireItem and not HasItem(Config.Standalone.RequireItem) then
        ToggleRacingTablet(false)
    end

    if Config.App.RequireItem then
        RefreshApps()
    end
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(jobInfo)
    PlayerData.job = jobInfo

    if #Config.App.BlacklistedJobs > 0 then
        RefreshApps()
    end
end)

---@return string
function GetJob()
    return PlayerData?.job?.name or ""
end

---@param itemName string
---@return boolean
function HasItem(itemName)
    if GetResourceState("ox_inventory") == "started" then
        return (exports.ox_inventory:Search("count", itemName) or 0) > 0
    end

    return QB.Functions.HasItem(itemName)
end

CreateThread(function()
    AddCanOpenCheck(function()
        if not LocalPlayer.state.isLoggedIn then
            debugprint("Cannot open racing tablet, player is not logged in")
            return false
        end

        local metadata = PlayerData.metadata or {}

        if metadata.ishandcuffed or metadata.isdead or metadata.inlaststand then
            debugprint("Cannot open racing tablet, player is handcuffed, dead, or in last stand")
            return false
        end

        return true
    end)
end)
