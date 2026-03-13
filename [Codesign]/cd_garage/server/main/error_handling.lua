-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              DEBUG                               │
-- └──────────────────────────────────────────────────────────────────┘

local function DebugPrints(source)
    Citizen.Trace('^6-----------------------^0\n')
    Citizen.Trace(string.format('^1CODESIGN DEBUG^0 (%s - v%s - %s)\n', GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0), source and 'client' or 'server'))

    Citizen.Trace('^3CONFIG^0\n')
    Citizen.Trace(string.format('^6Config.AutoInsertSQL:^0 %s\n', tostring(Config.AutoInsertSQL)))
    Citizen.Trace(string.format('^6Config.Debug:^0 %s\n', tostring(Config.Debug)))
    Citizen.Trace(string.format('^6Config.GarageInteractMethod:^0 %s\n', tostring(Config.GarageInteractMethod)))
    Citizen.Trace(string.format('^6Config.VehiclePlateFormats.format:^0 %s\n', tostring(Config.VehiclePlateFormats.format)))

    if source then
        Citizen.Trace('^3PERMS^0\n')
        Citizen.Trace(string.format('^6Perms [add]:^0 %s\n', HasAdminPerms(source, Config.StaffPerms['add'].perms[Config.Framework])))
        Citizen.Trace(string.format('^6Perms [delete]:^0 %s\n', HasAdminPerms(source, Config.StaffPerms['delete'].perms[Config.Framework])))
        Citizen.Trace(string.format('^6Perms [plate]:^0 %s\n', HasAdminPerms(source, Config.StaffPerms['plate'].perms[Config.Framework])))
        Citizen.Trace(string.format('^6Perms [keys]:^0 %s\n', HasAdminPerms(source, Config.StaffPerms['keys'].perms[Config.Framework])))
        Citizen.Trace(string.format('^6Is Allowed Impound:^0 %s\n', IsAllowed_Impound(source)))
        Citizen.Trace('^6-----------------------^0\n')
        Notification(source, 2, 'DEBUG INFO: OPEN F8 CONSOLE TO VIEW^0')
    end
end

RegisterCommand('debuggarage', function(source)
    local isConsole = source == 0
    local isAdmin = HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'})
    local debugEnabled = Config.Debug

    if isConsole then
        DebugPrints(nil)
        return
    end

    if isAdmin or debugEnabled then
        DebugPrints(source)
        return
    end

    Citizen.Trace('You cannot use this command. You must have admin permissions, enable Config.Debug, or run it from the server console.\n')
end, false)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                        PRE START CHECKS                          │
-- └──────────────────────────────────────────────────────────────────┘

CreateThread(function()
    if GetResourceState('cd_bridge') ~= 'started' then
        BridgeDependancyMissingPrint()
    end
    if Config == nil then
        ERROR('configuration_error_found', 'Config.lua Syntax Error')
    end
    if LocalesTable[Config.Language] == nil then
        ERROR('configuration_error_found', 'No ['..Config.Language..'] locale found in configs/locales.lua. Reverting back to EN.')
    end
    if GetCurrentResourceName() ~= 'cd_garage' then
        ERROR('configuration_error_found', 'Resource Name Changed : ['..GetCurrentResourceName()..']')
    end
    if Config.IdentifierType ~= 'steamid' and Config.IdentifierType ~= 'license' then
        ERROR('configuration_error_found', 'Config.IdentifierType Error : ['..Config.IdentifierType..']')
    end
    if #Config.VehiclePlateFormats.new_plate_format < 0 or #Config.VehiclePlateFormats.new_plate_format > 8 then
        ERROR('configuration_error_found', 'Config.VehiclePlateFormats.new_plate_format length must be between 0 and 8 characters.')
    end
    if Config.VehiclePlateFormats.format ~= 'trimmed' and Config.VehiclePlateFormats.format ~= 'with_spaces' and Config.VehiclePlateFormats.format ~= 'mixed' then
        ERROR('configuration_error_found', 'Config.VehiclePlateFormats.format Error : ['..Config.VehiclePlateFormats.format..']')
    end
    if Config.GarageInteractMethod == 'textui' and Config.DrawTextUi == 'none' then
        ERROR('configuration_error_found', 'Invalid Config.GarageInteractMethod. Cfg.DrawTextUi not configured in bridge.')
    end
    if Config.GarageInteractMethod == 'target' and Config.Target == 'none' then
        ERROR('configuration_error_found', 'Invalid Config.GarageInteractMethod. Cfg.Target not configured in bridge.')
    end

    PreStartItemChecks()
end)

function PreStartItemChecks()
    local needed = {}

    if Config.FakePlates.ENABLE then
        table.insert(needed, Config.FakePlates.item_name)
    end

    if Config.VehicleKeys.ENABLE and Config.VehicleKeys.Lockpick.ENABLE and Config.VehicleKeys.Lockpick.usable_item.ENABLE then
        table.insert(needed, Config.VehicleKeys.Lockpick.usable_item.item_name)
    end

    CheckAllItemsExist(needed)
end

function BridgeDependancyMissingPrint()
    Citizen.Trace([[
        ^5===============================================================
        ^3[cd_doorlock] ^7Missing required dependency: ^1cd_bridge^7
        ^5===============================================================

        ^7This resource requires the ^2cd_bridge^7 framework bridge to function correctly.

        ^7Please download ^2cd_bridge^7 from the official source:
            ^3https://portal.cfx.re/assets/granted-assets?search=cd_bridge

        ^6After installing:
        • Ensure the ^2cd_bridge^7 resource is started ^4before^7 this resource
        • Verify it is named exactly ^2"cd_bridge"^7 in your resources folder
        • Restart your server after adding it

        ^5===============================================================\n
    ]] .. '^0\n')
end