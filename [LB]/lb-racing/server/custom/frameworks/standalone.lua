if Config.Framework ~= "standalone" then
    return
end

---@param source number
---@return string?
function GetIdentifier(source)
    ---@diagnostic disable-next-line: param-type-mismatch
    return GetPlayerIdentifierByType(source, "license")
end

---@param identifier string
---@return number?
function GetSourceFromIdentifier(identifier)
    local players = GetPlayers()

    for i = 1, #players do
        if GetPlayerIdentifierByType(players[i], "license") == identifier then
            ---@diagnostic disable-next-line: return-type-mismatch
            return players[i]
        end
    end
end

---@param source number
---@return number
function GetMoney(source)
    return 0
end

---@param source number
---@param amount number
---@return boolean
function RemoveMoney(source, amount)
    return true
end

---@param identifier string
---@param amount number
---@return boolean
function RemoveMoneyOffline(identifier, amount)
    return true
end

---@param source number
---@param amount number
---@return boolean
function AddMoney(source, amount)
    return true
end

---@param identifier string
---@param amount number
---@return boolean
function AddMoneyOffline(identifier, amount)
    return true
end

---@param source number
---@return string firstName
---@return string lastName
function GetCharacterName(source)
    return GetPlayerName(source), tostring(source)
end

---@return boolean
function IsAdmin(source)
    return IsPlayerAceAllowed(source, "command.lbracing_admin") == 1
end

---@param source number
---@param plate string
---@param vehicle number
---@return boolean
function DoesPlayerOwnVehicle(source, plate, vehicle)
    return true
end

---@param source number
---@param playerData { identifier: string }
AddEventHandler("yourFramework:playerLoaded", function(source, playerData)
    TriggerEvent("lb-racing:playerLoaded", source, playerData.identifier)
end)

AddEventHandler("yourFramework:playerUnloaded", function(source)
    local identifier = GetIdentifier(source)

    if identifier then
        TriggerEvent("lb-racing:playerUnloaded", source, identifier)
    end
end)
