if Config.Framework ~= "esx" then
    return
end

local ESX = exports.es_extended:getSharedObject()

---@param source number
---@return string?
function GetIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    return xPlayer and xPlayer.identifier
end

---@param identifier string
---@return number?
function GetSourceFromIdentifier(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        return xPlayer.source
    end
end

---@param source number
---@return number
function GetMoney(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return 0
    end

    local bank = xPlayer.getAccount("bank").money or 0

    return bank
end

---@param source number
---@param amount number
---@return boolean
function RemoveMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return false
    end

    local bank = xPlayer.getAccount("bank").money or 0

    if bank >= amount then
        xPlayer.removeAccountMoney("bank", amount)

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

    local accounts = MySQL.scalar.await("SELECT accounts FROM users WHERE identifier = ?", { identifier })

    if not accounts then
        return false
    end

    accounts = json.decode(accounts)

    if (accounts.bank or 0) < amount then
        return false
    end

    accounts.bank = accounts.bank - amount

    return MySQL.update.await("UPDATE users SET accounts = ? WHERE identifier = ?", { json.encode(accounts), identifier }) > 0
end

---@param source number
---@param amount number
---@return boolean
function AddMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return false
    end

    xPlayer.addAccountMoney("bank", amount)

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

    return MySQL.update.await("UPDATE users SET accounts = JSON_SET(accounts, '$.bank', JSON_EXTRACT(accounts, '$.bank') + ?) WHERE identifier = ?", { amount, identifier }) > 0
end

---@param source number
---@return string firstName
---@return string lastName
function GetCharacterName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local firstName, lastName

    if xPlayer.get and xPlayer.get("firstName") and xPlayer.get("lastName") then
        firstName = xPlayer.get("firstName")
        lastName = xPlayer.get("lastName")
    else
        local name = MySQL.single.await("SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?", { xPlayer.identifier })

        firstName = name and name.firstname or GetPlayerName(source)
        lastName = name and name.lastname or ""
    end

    return firstName, lastName
end

---@return boolean
function IsAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isAdmin = xPlayer?.getGroup() == "superadmin"

    if not isAdmin then
        return IsPlayerAceAllowed(source, "command.lbphone_admin") == 1
    end

    return isAdmin
end

---@param source number
---@param plate string
---@param vehicle number
function DoesPlayerOwnVehicle(source, plate, vehicle)
    local identifier = GetIdentifier(source)

    if not identifier then
        return false
    end

    return MySQL.scalar.await("SELECT 1 FROM owned_vehicles WHERE plate = ? AND owner = ?", { plate, identifier }) == 1
end

---@param item string
---@param cb function
function CreateUsableItem(item, cb)
    ESX.RegisterUsableItem(item, cb)
end

AddEventHandler("esx:playerLoaded", function(source, xPlayer, isNew)
    TriggerEvent("lb-racing:playerLoaded", source, xPlayer.identifier)
end)

AddEventHandler("esx:playerLogout", function(source)
    local identifier = GetIdentifier(source)

    if identifier then
        TriggerEvent("lb-racing:playerUnloaded", source, identifier)
    end
end)

AddEventHandler("esx:playerDropped", function(source)
    local identifier = GetIdentifier(source)

    if identifier then
        TriggerEvent("lb-racing:playerUnloaded", source, identifier)
    end
end)
