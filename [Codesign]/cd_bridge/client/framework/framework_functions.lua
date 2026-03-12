-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get a players character name
local CharacterName = nil
function GetCharacterName()
    if CharacterName then
        return CharacterName
    end

    CharacterName = exports.cd_bridge:Callback('cd_bridge:GetCharacterName')
    return CharacterName
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               PERMS                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the admin permissions/group of a player
function GetAdminPerms()
    return exports.cd_bridge:Callback('cd_bridge:GetAdminPerms')
end

-- Check if a player has admin permissions
function HasAdminPerms(perms)
    if not perms then
        return false
    end
    return exports.cd_bridge:Callback('cd_bridge:HasAdminPerms', perms)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player has the job
--- @param job string|table     The job name or a table of job names.
--- @return boolean             --True if the player has the job, false otherwise.
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
-- │                               ITEMS                              │
-- └──────────────────────────────────────────────────────────────────┘

function HasItem(item, amount)
    return exports.cd_bridge:Callback('cd_bridge:HasItem', item, amount)
end

function HasItemThenRemove(item, amount)
    return exports.cd_bridge:Callback('cd_bridge:HasItemThenRemove', item, amount)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Get a formatted table of all shared vehicles
--- @return table         --A table of all shared vehicles.
local SharedVehicles = {}
function GetSharedVehicles()
    if next(SharedVehicles) ~= nil then
        return SharedVehicles
    else
        SharedVehicles = exports.cd_bridge:Callback('cd_bridge:GetSharedVehicles')
        return SharedVehicles
    end
end