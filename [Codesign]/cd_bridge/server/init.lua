local BRIDGE = 'cd_bridge'

if GetCurrentResourceName() == BRIDGE then
    return
end

local function Include(path)
    local content = LoadResourceFile(BRIDGE, path)
    if not content then
        error(('[cd_bridge] Failed to load file: %s'):format(path), 0)
    end

    local fn, err = load(content, ('@%s/%s'):format(BRIDGE, path))
    if not fn then error(err, 0) end

    local ok, runtimeErr = pcall(fn)
    if not ok then error(runtimeErr, 0) end
end

HasBridgeLoaded = false

--server/core
Include('server/core/database.lua')
Include('server/core/error_handling.lua')
Include('server/core/functions.lua')
Include('server/core/vehicle_functions.lua')

--shared
Include('shared/functions.lua')
Include('shared/locales.lua')

--server/integrations
Include('server/integrations/banking.lua')
Include('server/integrations/callsign.lua')
Include('server/integrations/gang.lua')
Include('server/integrations/job_duty.lua')
Include('server/integrations/notifications.lua')
Include('server/integrations/phone_number.lua')
Include('server/integrations/society.lua')
Include('server/integrations/vehicle_shop.lua')

--server/framework
Include(('server/framework/%s.lua'):format(Cfg.Framework:lower()))
Include('server/framework/framework_functions.lua')

--server inventory
Include(('server/inventory/%s.lua'):format(Cfg.Inventory:lower()))

if Cfg.BridgeDebug then
    Citizen.Trace(('^2[cd_bridge] Server bridge loaded into: ^7%s\n'):format(GetCurrentResourceName()))
end

HasBridgeLoaded = true