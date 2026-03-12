if Cfg.Framework ~= 'standalone' then return end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if the framework is loaded
function HasFrameworkLoaded()
    return true
end

-- Check if the player has loaded (after character selection).
function HasPlayerLoadedIn()
    return NetworkIsSessionStarted()
end

CreateThread(function()
    local function IsPlayerReady()
        local ped = PlayerPedId()
        return NetworkIsSessionStarted() and ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped)
    end

    while not IsPlayerReady() do
        Wait(250)
    end

    Wait(500)

    TriggerEvent('cd_bridge:TriggerStartEvents', GetCurrentResourceName())
end)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of the player
function GetJobName()
    return 'unemployed'
end

-- Get the job label of the player
function GetJobLabel()
    return 'Unemployed'
end

-- Get the job grade of the player
function GetJobGrade()
    return 0
end

-- Get the job grade label of the player
function GetJobGradeLabel()
    return 'Unemployed'
end

-- Get if the player is on duty
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

-- Get the gang name of the player
function GetGangName()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.name
    end
    return 'none'
end

-- Get the gang label of the player
function GetGangLabel()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.label
    end
    return 'No Gang'
end

-- Get the gang grade of the player
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