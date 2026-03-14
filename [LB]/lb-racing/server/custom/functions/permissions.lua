RegisterCallback("isAdmin", function(source)
    return IsAdmin(source)
end)

RegisterCallback("getIdentifier", function(source)
    return GetIdentifier(source)
end)

---@param source number
---@param allowed { Everyone: boolean, Admin: boolean }
function HasPermission(source, allowed)
    if allowed.Everyone then
        return true
    end

    if allowed.Admin and IsAdmin(source) then
        return true
    end

    return false
end

---@param source number
---@return boolean
function CanCreateTrack(source)
    return HasPermission(source, Config.Permissions.Creator)
end

---@param source number
---@param track Track
function CanEditTrack(source, track)
    local permissions = Config.Permissions.EditTrack

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and track.creator.id == GetIdentifier(source) then
        return true
    end

    if permissions.Admin and IsAdmin(source) then
        return true
    end

    return false
end

---@param source number
---@param track Track
function CanRemoveTrack(source, track)
    local permissions = Config.Permissions.RemoveTrack

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and track.creator.id == GetIdentifier(source) then
        return true
    end

    if permissions.Admin and IsAdmin(source) then
        return true
    end

    return false
end

---@param source number
function GetCreateRacePermissions(source)
    local racePermissions = Config.Permissions.CreateRace
    local optionPermissions = racePermissions.RaceOptions

    ---@type CreateRacePermissions
    return {
        create = HasPermission(source, racePermissions),
        paymentMethod = {
            allowed = HasPermission(source, optionPermissions.PaymentMethod),
            default = optionPermissions.PaymentMethod.Default,
            options = optionPermissions.PaymentMethod.Options
        },
        prizeDistribution = {
            allowed = HasPermission(source, optionPermissions.PrizeDistribution),
            default = optionPermissions.PrizeDistribution.Default,
            algorithms = optionPermissions.PrizeDistribution.Algorithms
        },
        ["repeat"] = {
            allowed = HasPermission(source, optionPermissions.Repeat),
            intervals = {}
        },
        commission = {
            default = optionPermissions.Commission.Default,
            allowed = HasPermission(source, optionPermissions.Commission),
            min = optionPermissions.Commission.Min,
            max = optionPermissions.Commission.Max
        },
        requireSignUp = {
            default = optionPermissions.RequireSignUp.Default,
            allowed = HasPermission(source, optionPermissions.RequireSignUp)
        },
        ranked = {
            default = optionPermissions.Ranked.Default,
            allowed = HasPermission(source, optionPermissions.Ranked)
        },
        inviteOnly = {
            default = optionPermissions.InviteOnly.Default,
            allowed = HasPermission(source, optionPermissions.InviteOnly)
        },
        personalVehicle = {
            default = optionPermissions.PersonalVehicle.Default,
            allowed = HasPermission(source, optionPermissions.PersonalVehicle)
        },
        assignVehicle = {
            default = optionPermissions.AssignVehicle.Default,
            allowed = HasPermission(source, optionPermissions.AssignVehicle)
        },
        collisions = {
            default = optionPermissions.Collisions.Default,
            allowed = HasPermission(source, optionPermissions.Collisions)
        },
        firstPerson = {
            default = optionPermissions.FirstPerson.Default,
            allowed = HasPermission(source, optionPermissions.FirstPerson)
        },
        disableTraffic = {
            default = optionPermissions.DisableTraffic.Default,
            allowed = HasPermission(source, optionPermissions.DisableTraffic)
        }
    }
end

---@param source number
---@param creator string
function CanCancelRace(source, creator)
    local permissions = Config.Permissions.CancelRace

    if permissions.Everyone then
        return true
    end

    if permissions.Creator and creator == GetIdentifier(source) then
        return true
    end

    if permissions.Admin and IsAdmin(source) then
        return true
    end

    return false
end
