-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the license identifier of a player
--- @param source number    The player's server ID.
--- @return string          --The player's license identifier.
function GetLicenseIdentifier(source)
    return GetPlayerIdentifierByType(source, 'license')
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               PERMS                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player has admin permissions
--- @param source number        The player's server ID.
--- @param perms string|table   The permission(s) to check for. Can be:
--- @                             * string - e.g. "admin"
--- @                             * number - e.g. 1
--- @                             * table (array)  - e.g. { "admin", "god" }
--- @                             * table (map)    - e.g. { admin = true, god = true }
--- @                             * table (mixed)  - e.g. { "admin", god = true }
--- @return boolean true        Returns true if the player has ANY of the specified permission(s), false otherwise.
function HasAdminPerms(source, perms)
    if not perms then return false end

    local playerPerm = GetAdminPerms(source)
    if not playerPerm then return false end

    local tPerms = type(perms)

    local function norm(v)
        return tostring(v):lower()
    end

    local function listHasPerm(list, target)
        local lt = type(list)
        target = norm(target)

        if lt == 'string' or lt == 'number' then
            return norm(list) == target
        elseif lt == 'table' then
            for k, v in pairs(list) do
                if type(k) == 'string' and norm(k) == target then
                    return true
                end
                if type(v) == 'string' or type(v) == 'number' then
                    if norm(v) == target then
                        return true
                    end
                end
            end
        end

        return false
    end

    if tPerms == 'string' or tPerms == 'number' then
        return listHasPerm(playerPerm, perms)
    end

    if tPerms == 'table' then
        for k, v in pairs(perms) do
            if type(k) == 'string' and listHasPerm(playerPerm, k) then
                return true
            end
            if type(v) == 'string' or type(v) == 'number' then
                if listHasPerm(playerPerm, v) then
                    return true
                end
            end
        end
    end

    return false
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if the player has the job
--- @param source number        The player's server ID.
--- @param job string|table     The job(s) to check against. Can be:
--- @                             * string - e.g. "police"
--- @                             * table (array of names)  - e.g. { "police", "ambulance" }
--- @                             * table (array of grades) - e.g. { 1, 2, 3 }
--- @                             * table (map)             - e.g. { police = true, ambulance = 2 } (value = min grade)
--- @                             * table (min grade)       - e.g. { min = 2 } or { minimum = 2 }
--- @return boolean true        Returns true if the player has the specified job and is on duty, false otherwise.
function HasJob(source, job)
    local myJob = GetJobName(source)
    if not myJob or not GetJobDuty(source) or not GetJobGrade(source) then return false end

    local myGrade = tonumber(GetJobGrade(source))
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