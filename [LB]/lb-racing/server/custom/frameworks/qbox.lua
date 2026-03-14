if Config.Framework ~= "qbox" then
    return
end

---@param source number
---@return string?
function GetIdentifier(source)
    local player = exports.qbx_core:GetPlayer(source)

    return player?.PlayerData?.citizenid
end

---@param identifier string
---@return number?
function GetSourceFromIdentifier(identifier)
    local player = exports.qbx_core:GetPlayerByCitizenId(identifier)

    if player?.PlayerData?.source then
        return player.PlayerData.source
    end
end

---@param source number
---@return number
function GetMoney(source)
    return exports.qbx_core:GetMoney(source, "bank") or 0
end

---@param source number
---@param amount number
---@return boolean
function RemoveMoney(source, amount)
    if amount <= 0 or GetMoney(source) < amount then
        return false
    end

    amount = math.floor(amount + 0.5)

    return exports.qbx_core:RemoveMoney(source, "bank", amount)
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
    amount = math.floor(amount + 0.5)

    return exports.qbx_core:AddMoney(source, "bank", amount)
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
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return GetPlayerName(source), tostring(source)
    end

    local characterInfo = player.PlayerData.charinfo

    return characterInfo.firstname, characterInfo.lastname
end

---@return boolean
function IsAdmin(source)
    return IsPlayerAceAllowed(source, "command.lbracing_admin") == 1
end

---@param source number
---@param plate string
---@param vehicle number
function DoesPlayerOwnVehicle(source, plate, vehicle)
    local identifier = GetIdentifier(source)

    if not identifier then
        return false
    end

    return MySQL.scalar.await("SELECT 1 FROM player_vehicles WHERE plate = ? AND citizenid = ?", { plate, identifier }) == 1
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
