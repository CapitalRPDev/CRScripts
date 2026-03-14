local isAdmin = false
local lastCheckedAdmin

function IsAdmin()
    if lastCheckedAdmin and (GetGameTimer() - lastCheckedAdmin) < 60000 then
        return isAdmin
    end

    isAdmin = AwaitCallback("isAdmin") --[[@as boolean]]
    lastCheckedAdmin = GetGameTimer()

    return isAdmin
end

local identifier
local lastCheckedIdentifier

function GetIdentifier()
    if lastCheckedIdentifier and (GetGameTimer() - lastCheckedIdentifier) < 60000 then
        return identifier
    end

    identifier = AwaitCallback("getIdentifier") --[[@as string]]
    lastCheckedIdentifier = GetGameTimer()

    return identifier
end

---@param allowed { Everyone: boolean, Admin: boolean }
function HasPermission(allowed)
    if allowed.Everyone then
        return true
    end

    if allowed.Admin and IsAdmin() then
        return true
    end

    return false
end

function CanUseFreecam()
    return HasPermission(Config.Permissions.Creator.Freecam)
end

function CanCreateTrack()
    if IsInRace() then
        return false
    end

    return HasPermission(Config.Permissions.Creator)
end

---@param track Track
function CanEditTrack(track)
    local permissions = Config.Permissions.EditTrack

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and track.creator.id == GetIdentifier() then
        return true
    end

    if permissions.Admin and IsAdmin() then
        return true
    end

    return false
end

---@param track Track
function CanRemoveTrack(track)
    local permissions = Config.Permissions.RemoveTrack

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and track.creator.id == GetIdentifier() then
        return true
    end

    if permissions.Admin and IsAdmin() then
        return true
    end

    return false
end

---@alias CreateRacePermission { default: boolean, allowed: boolean }

---@class CreateRacePermissions
---@field create boolean
---@field repeat { allowed: boolean, intervals: { label: string, minutes: number, localeParams?: { [string]: any } }[] }
---@field commission { default: number, allowed: boolean, min: number, max: number }
---@field paymentMethod { default: string, allowed: boolean, options: { label: string, value: string }[] }
---@field prizeDistribution { allowed: boolean, default: "auto" | "defined", algorithms: { label: string, value: string }[] }
---@field requireSignUp CreateRacePermission
---@field inviteOnly CreateRacePermission
---@field ranked CreateRacePermission
---@field personalVehicle CreateRacePermission
---@field assignVehicle CreateRacePermission
---@field collisions CreateRacePermission
---@field firstPerson CreateRacePermission
---@field disableTraffic CreateRacePermission

local function GetRepeatIntervals()
    ---@type { label: string, minutes: number, localeParams?: { [string]: any } }[]
    local intervals = {}

    for i = 1, #Config.Permissions.CreateRace.RaceOptions.Repeat.Intervals do
        local minutes = Config.Permissions.CreateRace.RaceOptions.Repeat.Intervals[i]
        local hours = minutes / 60
        local days = hours / 24
        local weeks = days / 7
        local months = days / 30

        ---@type string
        local locale

        if months >= 1 then
            locale = months == 1 and "APP.RACES.REPEAT.EVERY_MONTH" or "APP.RACES.REPEAT.EVERY_X_MONTHS"
        elseif weeks >= 1 then
            locale = weeks == 1 and "APP.RACES.REPEAT.EVERY_WEEK" or "APP.RACES.REPEAT.EVERY_X_WEEKS"
        elseif days >= 1 then
            locale = days == 1 and "APP.RACES.REPEAT.EVERY_DAY" or "APP.RACES.REPEAT.EVERY_X_DAYS"
        elseif hours >= 1 then
            locale = hours == 1 and "APP.RACES.REPEAT.EVERY_HOUR" or "APP.RACES.REPEAT.EVERY_X_HOURS"
        else
            locale = minutes == 1 and "APP.RACES.REPEAT.EVERY_MINUTE" or "APP.RACES.REPEAT.EVERY_X_MINUTES"
        end

        intervals[#intervals+1] = {
            label = locale,
            minutes = minutes,
            localeParams = {
                minutes = LimitDecimals(minutes, 1),
                hours = LimitDecimals(hours, 1),
                days = LimitDecimals(days, 1),
                weeks = LimitDecimals(weeks, 1),
                months = LimitDecimals(months, 1)
            }
        }
    end

    return intervals
end

function GetCreateRacePermissions()
    local racePermissions = Config.Permissions.CreateRace
    local optionPermissions = racePermissions.RaceOptions

    ---@type CreateRacePermissions
    return {
        create = HasPermission(racePermissions),
        paymentMethod = {
            allowed = HasPermission(optionPermissions.PaymentMethod),
            default = optionPermissions.PaymentMethod.Default,
            options = optionPermissions.PaymentMethod.Options
        },
        prizeDistribution = {
            allowed = HasPermission(optionPermissions.PrizeDistribution),
            default = optionPermissions.PrizeDistribution.Default,
            algorithms = optionPermissions.PrizeDistribution.Algorithms
        },
        ["repeat"] = {
            allowed = HasPermission(racePermissions.RaceOptions.Repeat),
            intervals = GetRepeatIntervals()
        },
        commission = {
            default = optionPermissions.Commission.Default,
            allowed = HasPermission(optionPermissions.Commission),
            min = optionPermissions.Commission.Min,
            max = optionPermissions.Commission.Max
        },
        requireSignUp = {
            default = optionPermissions.RequireSignUp.Default,
            allowed = HasPermission(optionPermissions.RequireSignUp)
        },
        ranked = {
            default = optionPermissions.Ranked.Default,
            allowed = HasPermission(optionPermissions.Ranked)
        },
        inviteOnly = {
            default = optionPermissions.InviteOnly.Default,
            allowed = HasPermission(optionPermissions.InviteOnly)
        },
        personalVehicle = {
            default = optionPermissions.PersonalVehicle.Default,
            allowed = HasPermission(optionPermissions.PersonalVehicle)
        },
        assignVehicle = {
            default = optionPermissions.AssignVehicle.Default,
            allowed = HasPermission(optionPermissions.AssignVehicle)
        },
        collisions = {
            default = optionPermissions.Collisions.Default,
            allowed = HasPermission(optionPermissions.Collisions)
        },
        firstPerson = {
            default = optionPermissions.FirstPerson.Default,
            allowed = HasPermission(optionPermissions.FirstPerson)
        },
        disableTraffic = {
            default = optionPermissions.DisableTraffic.Default,
            allowed = HasPermission(optionPermissions.DisableTraffic)
        }
    }
end

---@param creator string
function CanCancelRace(creator)
    local permissions = Config.Permissions.CancelRace

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and creator == GetIdentifier() then
        return true
    end

    if permissions.Admin and IsAdmin() then
        return true
    end

    return false
end
