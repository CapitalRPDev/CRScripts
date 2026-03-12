if Cfg.Framework ~= 'qbox' then return end

QBX = nil
local JobData = {}
local LastJobData = {}
local GangData = {}
local LastGangData = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if the framework is loaded
function HasFrameworkLoaded()
    return QBX ~= nil
end

-- Check if the player has loaded (after character selection).
function HasPlayerLoadedIn()
    return LocalPlayer.state.isLoggedIn
end

-- Initialize the framework object
local function initateFramework()
    local function normalizeDuty(duty)
        return (duty ~= nil) and (duty == true or duty == 1 or duty == 'on') or true
    end

    local function cacheJobData(data)
        if not data then return end

        local onDuty = normalizeDuty(data.onduty)

        local newJob = {
            name = data.name,
            label = data.label,
            grade = data.grade.level,
            on_duty = onDuty
        }

        JobData.name = data.name
        JobData.label = data.label
        JobData.grade = data.grade.level
        JobData.grade_label = data.grade.name
        JobData.on_duty = onDuty

        return newJob
    end

    local function cacheGangData(data)
        if not data then return end

        local newGang = {
            name = data.name,
            label = data.label,
            grade = data.grade.level,
        }

        GangData.name = data.name
        GangData.label = data.label
        GangData.grade = data.grade.level

        return newGang
    end

    while QBX == nil do
        pcall(function()
            QBX = exports['qbx_core']:GetPlayerData()
        end)

        if not QBX then
            Wait(10)
        end
    end

    local function refreshPlayerData()
        local player = exports['qbx_core']:GetPlayerData()

        if player and player.job then
            LastJobData = cacheJobData(player.job)
        end

        if player and player.gang then
            LastGangData = cacheGangData(player.gang)
        end
    end

    refreshPlayerData()

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        refreshPlayerData()
        TriggerEvent('cd_bridge:TriggerStartEvents', GetCurrentResourceName())
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        local old = LastJobData or { name=nil, label=nil, grade=0, on_duty=true }

        local new = {
            name = job.name,
            label = job.label,
            grade = job.grade.level,
            on_duty = normalizeDuty(job.onduty)
        }

        TriggerEvent('cd_bridge:OnJobChanged', {
            job_changed = old.name ~= new.name,
            grade_changed = old.grade ~= new.grade,
            duty_changed = old.on_duty ~= new.on_duty,
            old = old,
            new = new
        })

        LastJobData = new
        cacheJobData(job)
    end)

    RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
        local old = LastGangData or { name=nil, label=nil, grade=0 }

        local new = {
            name = gang.name,
            label = gang.label,
            grade = gang.grade.level,
        }

        TriggerEvent('cd_bridge:OnGangChanged', {
            gang_changed = old.name ~= new.name,
            grade_changed = old.grade ~= new.grade,
            old = old,
            new = new
        })

        LastGangData = new
        cacheGangData(gang)
    end)

    RegisterNetEvent('QBCore:Client:SetDuty', function(state)
        local onDuty = (state == true or state == 1 or state == 'on')
        if JobData.on_duty == onDuty then return end

        TriggerEvent('cd_bridge:OnDutyChanged', {
            duty_changed = true,
            old = { name = JobData.name, on_duty = JobData.on_duty },
            new = { name = JobData.name, on_duty = onDuty }
        })

        JobData.on_duty = onDuty
        if LastJobData then LastJobData.on_duty = onDuty end
    end)
end

initateFramework()

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of the player
function GetJobName()
    return JobData.name
end

-- Get the job label of the player
function GetJobLabel()
    return JobData.label
end

-- Get the job grade of the player
function GetJobGrade()
    return JobData.grade
end

-- Get the job grade label of the player
function GetJobGradeLabel()
    return JobData.grade_label
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

    return JobData.on_duty
end

-- Check if a player has the job
function HasJob(job)
    local myJob = GetJobName()
    if not myJob or not GetJobDuty() or not GetJobGrade() then return false end

    local myGrade = tonumber(GetJobGrade())
    local jobType = type(job)

    if jobType == 'string' then
        return myJob == job
    end

    if jobType ~= 'table' then
        return false
    end

    local minOnly = tonumber(job.min or job.minimum)
    if minOnly then
        return myGrade >= minOnly
    end

    local keyed = job[myJob]
    if keyed ~= nil then
        if type(keyed) == 'boolean' then
            return keyed == true
        end

        local required = tonumber(keyed)
        if required then
            return myGrade >= required
        end

        return true
    end

    local isGradesOnly = (#job > 0)
    if isGradesOnly then
        for cd = 1, #job do
            if tonumber(job[cd]) == nil then
                isGradesOnly = false
                break
            end
        end
    end

    if isGradesOnly then
        for cd = 1, #job do
            if myGrade == tonumber(job[cd]) then
                return true
            end
        end
        return false
    end

    for _, value in ipairs(job) do
        if value == myJob then
            return true
        end
    end

    return false
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
    return GangData.name
end

-- Get the gang label of the player
function GetGangLabel()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.label
    end
    return GangData.label
end

-- Get the gang grade of the player
function GetGangGrade()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.grade
    end
    return GangData.grade
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              VEHICLE                             │
-- └──────────────────────────────────────────────────────────────────┘

function FrameworkCreateVehicle(model, coords)
    local heading = coords.w or coords.h or 0.0
    return CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
end