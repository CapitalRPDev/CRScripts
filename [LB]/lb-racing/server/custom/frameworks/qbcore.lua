if Config.Framework ~= "qbcore" then
    return
end

local QB = exports["qb-core"]:GetCoreObject()

---@param source number
local function GetQBPlayer(source)
    return QB.Functions.GetPlayer(tonumber(source))
end

---@param source number
---@return string?
function GetIdentifier(source)
    local qPlayer = GetQBPlayer(source)

    return qPlayer?.PlayerData?.citizenid
end

---@param identifier string
---@return number?
function GetSourceFromIdentifier(identifier)
    local qPlayer = QB.Functions.GetPlayerByCitizenId(identifier)

    if qPlayer?.PlayerData?.source then
        return qPlayer.PlayerData.source
    end
end

---@param source number
---@return number
function GetMoney(source)
    local qPlayer = GetQBPlayer(source)

    if not qPlayer then
        return 0
    end

    return qPlayer.Functions.GetMoney("bank") or 0
end

---@param source number
---@param amount number
---@return boolean
function RemoveMoney(source, amount)
    local qPlayer = GetQBPlayer(source)

    if not qPlayer then
        return false
    end

    if (qPlayer.Functions.GetMoney("bank") or 0) >= amount then
        qPlayer.Functions.RemoveMoney("bank", math.floor(amount + 0.5), "lb-racing")

        return true
    end

    return false
end

---@param identifier string
---@param amount number
---@return boolean
function RemoveMoneyOffline(identifier, amount)
    if amount <= 0 then
        return false
    end

    amount = math.floor(amount + 0.5)

    local money = MySQL.scalar.await("SELECT money FROM players WHERE citizenid = ?", { identifier }) or '{}'

    money = json.decode(money)

    if (money.bank or 0) < amount then
        return false
    end

    money.bank = money.bank - amount

    return MySQL.update.await("UPDATE players SET money = ? WHERE citizenid = ?", { json.encode(money), identifier }) > 0
end

---@param source number
---@param amount number
---@return boolean
function AddMoney(source, amount)
    local qPlayer = GetQBPlayer(source)

    if not qPlayer or amount <= 0 then
        return false
    end

    qPlayer.Functions.AddMoney("bank", math.floor(amount + 0.5), "lb-racing")

    return true
end

---@param identifier string
---@param amount number
---@return boolean
function AddMoneyOffline(identifier, amount)
    if amount <= 0 then
        return false
    end

    amount = math.floor(amount + 0.5)

    return MySQL.update.await("UPDATE players SET money = JSON_SET(money, '$.bank', JSON_EXTRACT(money, '$.bank') + ?) WHERE citizenid = ?", { amount, identifier }) > 0
end

---@param source number
---@return string firstName
---@return string lastName
function GetCharacterName(source)
    local qPlayer = GetQBPlayer(source)

    if not qPlayer then
        debugprint("GetCharacterName: Failed to get QB player for source:", source)

        return GetPlayerName(source), tostring(source)
    end

    local characterInfo = qPlayer.PlayerData.charinfo

    return characterInfo.firstname, characterInfo.lastname
end

---@return boolean
function IsAdmin(source)
    return QB.Functions.HasPermission(source, "admin") or IsPlayerAceAllowed(source, "command.lbracing_admin") == 1
end

---@param source number
---@param plate string
---@param vehicle number
---@return boolean
function DoesPlayerOwnVehicle(source, plate, vehicle)
    local identifier = GetIdentifier(source)

    if not identifier then
        return false
    end

    return MySQL.scalar.await("SELECT 1 FROM player_vehicles WHERE plate = ? AND citizenid = ?", { plate, identifier }) == 1
end

---@param item string
---@param cb function
function CreateUsableItem(item, cb)
    QB.Functions.CreateUseableItem(item, cb)
end

AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
    TriggerEvent("lb-racing:playerLoaded", source, player.PlayerData.identifier)
end)

AddEventHandler("QBCore:Server:OnPlayerUnload", function(source)
    local identifier = GetIdentifier(source)

    if identifier then
        TriggerEvent("lb-racing:playerUnloaded", source, identifier)
    end
end)
