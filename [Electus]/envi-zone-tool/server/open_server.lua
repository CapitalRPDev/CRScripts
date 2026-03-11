-- Check if a player can use zone tool commands
-- @param source - The player's server ID
-- @param commandType - The type of command: 'zone', 'polyzone', 'prop'
-- @return boolean - true if allowed, false if denied
function CanUseZoneTool(source, commandType)
    -- IMPORTANT: Modify this function to integrate with your admin system
    -- Examples:
    --   return IsPlayerAceAllowed(source, 'command.zonetool')
    --   return exports['qbx_core']:HasPermission(source, 'admin')
    --   return IsPlayerAdmin(source)

    -- Default: Allow all (change this for live server!)
    return true
end

lib.callback.register('envi-zone-tool:server:canUseCommand', function(source, commandType)
    return CanUseZoneTool(source, commandType)
end)

exports('CanUseZoneTool', CanUseZoneTool)
