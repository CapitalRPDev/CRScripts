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

--client/core
Include('client/core/error_handling.lua')
Include('client/core/functions.lua')
Include('client/core/vehicle_functions.lua')

--shared
Include('shared/functions.lua')
Include('shared/locales.lua')

--client/integrations
Include('client/integrations/drawtextui.lua')
Include('client/integrations/gang.lua')
Include('client/integrations/job_duty.lua')
Include('client/integrations/notifications.lua')
Include('client/integrations/persistent_vehicle.lua')
Include('client/integrations/vehicle_fuel.lua')
Include('client/integrations/vehicle_keys.lua')

--client/framework
Include(('client/framework/%s.lua'):format(Cfg.Framework:lower()))
Include('client/framework/framework_functions.lua')

if Cfg.BridgeDebug then
    Citizen.Trace(('^2[cd_bridge] Client bridge loaded into: ^7%s\n'):format(GetCurrentResourceName()))
end

HasBridgeLoaded = true