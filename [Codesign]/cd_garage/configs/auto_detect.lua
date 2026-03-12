local function running(res)
    return GetResourceState(res) == 'started'
end

local function detect(list, fallback)
    for _, res in ipairs(list) do
        if running(res) then
            return res
        end
    end
    return fallback
end

if Config.GarageInteractMethod == 'auto_detect' then
    local method = detect({
        'cd_drawtextui',
        'jg-textui',
        'okokTextUI',
        'ox_target',
        'ps-ui',
        'vms_notifyv2',
        'qb-target'
    }, nil)

    if method then
        Config.GarageInteractMethod = method
    else
        if Config.Framework == 'qbcore' then
            Config.GarageInteractMethod = 'qbcore'
        else
            Config.GarageInteractMethod = 'none'
        end
    end
end

if Config.Framework == 'qbox' then
    Config.SaveAdvancedVehicleDamage = false
end