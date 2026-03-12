if Cfg.Framework ~= 'other' then return end

FRAMEWORK = nil

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

--- Check if the framework is loaded
--- @return boolean         --True if the framework is loaded, false otherwise.
function HasFrameworkLoaded()
    return true
end

--- Check if the player has loaded (after character selection).
--- @return boolean         --True if the framework is loaded, false otherwise.
function HasPlayerLoadedIn()
    return NetworkIsSessionStarted()
end

-- Initialize the framework object here (if needed).
local function initateFramework()
    RegisterNetEvent('FRAMEWORK:playerLoaded', function(player)
        -- Cache the job data (if needed).
        TriggerEvent('cd_bridge:TriggerStartEvents', GetCurrentResourceName())
    end)

    RegisterNetEvent('FRAMEWORK:JobChanged', function(job)
        -- Update the cached job data (if needed).
    end)

    RegisterNetEvent('FRAMEWORK:GangChanged', function(gang)
        -- Update the cached gang data (if needed).
    end)

    RegisterNetEvent('FRAMEWORK:DutyChanged', function(duty)
        -- Update the cached job data (if needed).
    end)
end
initateFramework()

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

--- Get the job name of a player
--- @return string          --The player's job name.
function GetJobName()
    return 'police'
end

--- Get the job label of a player
--- @return string           --The player's job label.
function GetJobLabel()
    return 'LSPD'
end

--- Get the job grade of a player
--- @return number              --The player's job grade.
function GetJobGrade()
    return 0
end

--- Get the job label of a player
--- @return string            --The player's job grade label.
function GetJobGradeLabel()
    return 'Recruit'
end

--- Check if a player is on duty
--- @return boolean         --True if the player is on duty, false otherwise.
function GetJobDuty()
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
--- @return string            --The player's gang name.
function GetGangName()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.name
    end
    return 'none'
end

--- Get the gang label of the player
--- @return string            --The player's gang label.
function GetGangLabel()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.label
    end
    return 'No Gang'
end

-- Get the gang grade of the player
--- @return number            --The player's gang grade.
function GetGangGrade()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.grade
    end
    return 0
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              VEHICLE                             │
-- └──────────────────────────────────────────────────────────────────┘

function FrameworkCreateVehicle(model, coords)
    local heading = coords.w or coords.h or 0.0
    return CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
end