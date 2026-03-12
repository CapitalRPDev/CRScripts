if Cfg.Framework ~= 'other' then return end

FRAMEWORK = nil
local CharacterNames = {}
local SharedVehicles = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Initialize the framework object here if needed.

--- Check if the framework is loaded
--- @return boolean         --True if the framework is loaded, false otherwise.
function HasFrameworkLoaded()
    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

--- Get the player object
--- @param source number    The player's server ID.
--- @return table           --The player object.
function GetPlayer(source)
    return {}
end

--- Get the unique identifier of a player
--- @param source number    The player's server ID.
--- @return string          --The player's unique identifier.
function GetIdentifier(source)
    return 'ACBD1234'
end

-- Get the source from a unique identifier
--- @param identifier string    The unique identifier to search for.
--- @return number              --The player's server ID.
function GetSourceFromIdentifier(identifier)
    return 0
end

--- Get a players character name
--- @param source number        The player's server ID.
--- @return string              --The player's character name.
function GetCharacterName(source)
    if CharacterNames[source] then
        return CharacterNames[source]
    end

    CharacterNames[source] = 'John_Doe'
    return 'John_Doe'
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               PERMS                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the admin permissions/group of a player
--- @param source number        The player's server ID.
--- @return string|table        The player's permission group(s). Can return:
---                             * string - e.g. "admin"
---                             * table  - e.g. { "admin", "god" } or { admin = true }
function GetAdminPerms(source)
    return 'admin'
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

--- Get the job name of a player
--- @param source number    The player's server ID.
--- @return string          --The player's job name.
function GetJobName(source)
    return 'police'
end

--- Get the job label of a player
--- @param source number     The player's server ID.
--- @return string           --The player's job label.
function GetJobLabel(source)
    return 'LSPD'
end

--- Get the job grade of a player
--- @param source number        The player's server ID.
--- @return number              --The player's job grade.
function GetJobGrade(source)
    return 0
end

--- Get the job label of a player
--- @param source number      The player's server ID.
--- @return string            --The player's job grade label.
function GetJobGradeLabel(source)
    return 'Recruit'
end

--- Check if a player is on duty
--- @param source number    The player's server ID.
--- @return boolean         --True if the player is on duty, false otherwise.
function GetJobDuty(source)
    if Cfg.DisableDuty then
        return true
    end

    local customDuty = GetCustomJobDuty()
    if customDuty ~= nil then
        return customDuty
    end

    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                GANG                              │
-- └──────────────────────────────────────────────────────────────────┘


--- Get the gang name of the player
--- @param source number      The player's server ID.
--- @return string            --The player's gang name.
function GetGangName(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.name
    end
    return 'none'
end

--- Get the gang label of the player
--- @param source number      The player's server ID.
--- @return string            --The player's gang label.
function GetGangLabel(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.label
    end
    return 'No Gang'
end

-- Get the gang grade of the player
--- @param source number      The player's server ID.
--- @return number            --The player's gang grade.
function GetGangGrade(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.grade
    end
    return 0
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               MONEY                              │
-- └──────────────────────────────────────────────────────────────────┘

--- Get the amount of money a player has
--- @param source number        The player's server ID.
--- @param money_type string    The type of money ('cash' or 'bank').
--- @return number              --The amount of money the player has.
function GetPlayerMoney(source, money_type)
    if money_type == 'bank' then
        return 0

    elseif money_type == 'cash' then
        return 0
    end
    return 0
end

--- Add money to a player
--- @param source number        The player's server ID.
--- @param amount number        The amount of money to add.
--- @param money_type  string   The type of money ('cash' or 'bank').
--- @param reason string        The reason for adding the money.
function AddPlayerMoney(source, amount, money_type, reason)
    reason = reason or ''

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'deposit')
    end

    if money_type == 'bank' then
        -- add money here.
    elseif money_type == 'cash' then
        -- add money here.
    end
end

--- Remove money from a player
--- @param source number        The player's server ID.
--- @param amount number        The amount of money to remove.
--- @param money_type string    The type of money ('cash' or 'bank').
--- @param reason string        The reason for removing the money.
--- @return boolean             --True if the money was removed, false otherwise.
function RemovePlayerMoney(source, amount, money_type, reason)
    if amount <= 0 then return false end
    reason = reason or ''

    local balance = GetPlayerMoney(source, money_type)
    if balance < amount then
        return false
    end

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'withdraw')
    end

    if money_type == 'bank' then
        -- remove money here.
        return true

    elseif money_type == 'cash' then
        -- remove money here.
        return true
    end
    return false
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               ITEMS                              │
-- └──────────────────────────────────────────────────────────────────┘

--- Register a usable item
--- @param item_name string        The name of the usable item.
--- @param onUse function          The function to call when the item is used.
function RegisterUsableItem(item_name, onUse)
    -- Register usable item here.
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Get a formatted table of all shared vehicles
--- @return table         --A table of all shared vehicles.
function GetSharedVehicles()
    if next(SharedVehicles) ~= nil then
        return SharedVehicles
    end

    local customSharedVehicles = GetCustomSharedVehicles()
    if customSharedVehicles then
        SharedVehicles = customSharedVehicles
        return SharedVehicles
    end

    return SharedVehicles
end

-- Get a formatted table of all shared jobs
--- @return table         --A table of all shared jobs.
function GetSharedJobs()
    return {}
end