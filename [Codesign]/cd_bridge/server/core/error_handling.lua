-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          ERROR HANDLING                          │
-- └──────────────────────────────────────────────────────────────────┘ 

local resource_name = string.format('[%s - v%s - %s]', GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0), 'server')
local end_line = '^0==================[END]===================^0'
local total_length = #end_line-4
local side = math.floor((total_length - #resource_name) / 2)
local left = string.rep('=', side)
local right = string.rep('=', total_length - #resource_name - side)
local start_line = ('^0%s%s%s^0'):format(left, resource_name, right)
local error_support_message = '^2NEED SUPPORT?^0\n^0Discord: ^3https://discord.gg/codesign.\n^0Documentation: ^3https://docs.codesign.pro.\n'..end_line

local function GetCallOrigin()
    local info = debug.getinfo(3, 'Sl')
    if not info then return ('@%s:unknown:0'):format(GetCurrentResourceName()) end
    return (info.short_src or ('@%s:unknown'):format(GetCurrentResourceName())) .. ':' .. (info.currentline or '0')
end

function ERROR(error_code, explanation)
    local code = error_code and tostring(error_code) or 'NULL'
    local origin = GetCallOrigin() or 'unknown'
    explanation = explanation and tostring(explanation) or 'No explanation provided'

    exports.cd_bridge:StoreError(error_code, origin, explanation)
    Citizen.Trace(('\n\n%s\n^1ERROR CODE: %s^0\n^1ERROR SOURCE: %s^0\n^1EXPLANATION: %s^0\n\n%s\n\n'):format(
        start_line,
        error_code,
        origin,
        explanation,
        error_support_message
    ))
end

function TypeCheck(value, expected_type, error_code, explanation)
    local actual = type(value)
    if actual == expected_type then return true end

    local code = error_code and tostring(error_code) or 'NULL'
    local origin = GetCallOrigin() or 'unknown'
    value = tostring(value)
    explanation = explanation and tostring(explanation) or 'No explanation provided'

    exports.cd_bridge:StoreError(error_code, origin, explanation, expected_type, actual, value)
    Citizen.Trace(('\n\n%s\n^1ERROR: %s expected, got %s : [%s]^0\n^1ERROR CODE: %s^0\n^1ERROR SOURCE: %s^0\n^1EXPLANATION: %s^0\n\n%s\n\n'):format(
        start_line,
        expected_type,
        actual,
        value,
        code,
        origin,
        explanation,
        error_support_message
    ))

    return false
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         REMOTE ERROR LOGS                        │
-- └──────────────────────────────────────────────────────────────────┘

local function getCallResource()
    local invoking = GetInvokingResource()
    if invoking then return invoking end

    local info = debug.getinfo(3, 'Sl')
    if info and info.short_src then
        local resource = info.short_src:match('^@([^/]+)/')
        if resource then return resource end
    end

    return 'unknown'
end

local caughtErrors = {}
local function storeError(error_code, origin, explanation, expected_type, actual_type, value)
    local type_check = expected_type and ('%s expected, got %s : [%s]'):format(expected_type, type(value), tostring(value)) or nil
    local callResource = getCallResource() or 'unknown'
    local version = callResource ~= 'unknown' and GetResourceMetadata(callResource, 'version', 0) or 'unknown'
    local title = ('%s v%s - server'):format(callResource, version)

    caughtErrors[#caughtErrors + 1] = {
        error_code = error_code,
        type_check = type_check,
        origin = origin,
        explanation = explanation,
        title = title,
        timestamp = os.time()
    }
end
exports('StoreError', storeError)
exports('GetErrors', function()
    return caughtErrors or {}
end)

local function getEarliestPlayer()
    local players = GetPlayers()
    if not players or #players == 0 then return nil end

    local earliest = nil
    local earliestId = math.huge

    for _, source in ipairs(players) do
        local id = tonumber(source)
        if id and id < earliestId then
            earliestId = id
            earliest = source
        end
    end

    return earliest
end

local function getClientErrorCodes(source)
    if not source then return {} end
    local callback = exports.cd_bridge:Callback('cd_bridge:GetClientErrorCodes', source)
    if callback == nil then
        ERROR('1203', '"GetClientErrorCodes" returned {}')
        return nil
    end

    return callback
end

local function formatDiscordErrorLogWebhook(source)
    local serverErrors = exports.cd_bridge:GetErrors() or {}
    local clientErrors = getClientErrorCodes(source) or {}

    local combined = {}

    for _, err in ipairs(serverErrors) do
        combined[#combined + 1] = err
    end

    for _, err in ipairs(clientErrors) do
        combined[#combined + 1] = err
    end

    table.sort(combined, function(a, b)
        return (a.timestamp or 0) < (b.timestamp or 0)
    end)

    local lines = {}

    for _, err in ipairs(combined) do
        lines[#lines + 1] = ('__%s__ %s\nError Code: **%s**%s\nOrigin: %s\nExplanation: %s'):format(
            err.title,
            os.date('%H:%M:%S', err.timestamp),
            tostring(err.error_code),
            (err.type_check and (' - ' .. err.type_check) or ''),
            err.origin,
            err.explanation
        )
    end

    return {
        description = #lines > 0 and table.concat(lines, '\n\n') or 'No errors to display',
        errorCount = {
            server = #serverErrors,
            client = #clientErrors
        }
    }
end

if GetCurrentResourceName() == 'cd_bridge' then
    RegisterCommand('send_error_report', function(source)
        if not CodesignDiscordWebhook or CodesignDiscordWebhook == '' or CodesignDiscordWebhook == 'DISCORD_WEBHOOK_HERE' then
            Citizen.Trace('CodesignDiscordWebhook is not set. Please set it in the config.lua file to enable this command.\n')
            return
        end

        local isConsole = source == 0
        local isAdmin = HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'})
        local debugEnabled = Cfg.BridgeDebug

        if source == 0 then
            source = getEarliestPlayer() or nil
        end

        local webhookData = {}
        if isConsole or isAdmin or debugEnabled then
            webhookData = formatDiscordErrorLogWebhook(source)
            if source == nil then
                if webhookData and webhookData.description and webhookData.errorCount.server > 0 then
                    webhookData.description = 'No players online to retrieve error data from client. Displaying server errors only.\n\n' .. webhookData.description
                end
            end
        else
            Citizen.Trace('You cannot use this command. You must have admin permissions, enable Cfg.BridgeDebug, or run it from the server console.\n')
            return
        end

        local errorCount = webhookData.errorCount or {client = 0, server = 0}
        local uniqueId = GenerateUniqueId()

        local data = {{
            ['color'] = 16711680,
            ['title'] = resource_name..' : ['..GetConvar('sv_projectName', 'unknown')..']',
            ['description'] = webhookData.description,
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ['footer'] = {
                ['text'] = ('Server: %s errors | Client: %s errors | ID: %s'):format(errorCount.server, errorCount.client, uniqueId),
                ['icon_url'] = 'https://i.imgur.com/VMPGPTQ.png',
            },
        }}
        PerformHttpRequest(CodesignDiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = 'cd_bridge', embeds = data}), { ['Content-Type'] = 'application/json' })
        Citizen.Trace(('\n^1===================================================^0\n^1Error log sent to Discord (^0ID: %s^1)^0\n^1===================================================^0\n'):format(uniqueId))
    end, false)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               DEBUG                              │
-- └──────────────────────────────────────────────────────────────────┘ 

local function DebugPrints(source, sendToDiscord)
    local lines = {}

    local function add(str)
        lines[#lines + 1] = str
    end

    add('^6-----------------------^0')
    add(('^1CODESIGN DEBUG^0 (%s - v%s - %s)'):format(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0), source and 'client' or 'server'))

    if source then
        local admin = GetAdminPerms(source)
        local hasAdminPerms = HasAdminPerms(source, admin)

        add('^3PLAYER^0')
        add(('^6Source:^0 %s'):format(source))
        add(('^6Identifier:^0 %s'):format(GetIdentifier(source)))
        add(('^6Admin Perms:^0 %s'):format(type(admin) == 'string' and admin or json.encode(admin)))
        add(('^6Has Admin Perms:^0 %s'):format(tostring(hasAdminPerms)))
        add('^6-----------------------^0')
        if not hasAdminPerms then
            add('^3PLAYER IDENTIFIERS^0')
            for i = 0, GetNumPlayerIdentifiers(source) - 1 do
                add(GetPlayerIdentifier(source, i))
            end
            add('^6-----------------------^0')
        end

        if Cfg.Framework == 'esx' or Cfg.Framework == 'qbcore' or Cfg.Framework == 'qbox' or Cfg.Framework == 'other' then
            local charInfo = {
                charName = GetCharacterName(source),
                jobName = GetJobName(source),
                jobLabel = GetJobLabel(source),
                jobGrade = GetJobGrade(source),
                jobGradeLabel = GetJobGradeLabel(source),
                onDuty = GetJobDuty(source),
                gangName = GetGangName(source),
                gangLabel = GetGangLabel(source),
                gangGrade = GetGangGrade(source)
            }

            add('^3CHARACTER^0')
            add(('^6Character Name:^0 %s'):format(tostring(charInfo.charName)))
            add(('^6Job Name:^0 %s'):format(tostring(charInfo.jobName)))
            add(('^6Job Label:^0 %s'):format(tostring(charInfo.jobLabel)))
            add(('^6Job Grade:^0 %s'):format(tostring(charInfo.jobGrade)))
            add(('^6Job Grade Label:^0 %s'):format(tostring(charInfo.jobGradeLabel)))
            add(('^6On Duty:^0 %s'):format(tostring(charInfo.onDuty)))
            add(('^6Gang Name:^0 %s'):format(tostring(charInfo.gangName)))
            add(('^6Gang Label:^0 %s'):format(tostring(charInfo.gangLabel)))
            add(('^6Gang Grade:^0 %s'):format(tostring(charInfo.gangGrade)))
            add('^6-----------------------^0')

            TriggerClientEvent('cd_bridge:debug:charInfo', source, charInfo)
        end

        Notification(source, 2, 'DEBUG INFO: OPEN F8 CONSOLE TO VIEW^0')
    end

    add('^3CONFIG^0')
    add(('^6Framework:^0 %s'):format(Cfg.Framework))
    add(('^6Database:^0 %s'):format(Cfg.Database))
    add(('^6Language:^0 %s'):format(Cfg.Language))
    add('-----')
    add(('^6BridgeDebugSQL:^0 %s'):format(tostring(Cfg.BridgeDebugSQL)))
    add(('^6BridgeDebug:^0 %s'):format(tostring(Cfg.BridgeDebug)))
    add(('^6DisableDuty:^0 %s'):format(tostring(Cfg.DisableDuty)))
    add('-----')
    add(('^6Banking:^0 %s'):format(Cfg.Banking))
    add(('^6Dispatch:^0 %s'):format(Cfg.Dispatch))
    add(('^6DrawTextUI:^0 %s'):format(Cfg.DrawTextUI))
    add(('^6Duty:^0 %s'):format(Cfg.Duty))
    add(('^6Gang:^0 %s'):format(Cfg.Gang))
    add(('^6Inventory:^0 %s'):format(Cfg.Inventory))
    add(('^6Mechanic:^0 %s'):format(Cfg.Mechanic))
    add(('^6Notification:^0 %s'):format(Cfg.Notification))
    add(('^6PersistentVehicles:^0 %s'):format(Cfg.PersistentVehicles))
    add(('^6Phone:^0 %s'):format(Cfg.Phone))
    add(('^6Society:^0 %s'):format(Cfg.Society))
    add(('^6Target:^0 %s'):format(Cfg.Target))
    add(('^6TimeWeather:^0 %s'):format(Cfg.TimeWeather))
    add(('^6VehicleFuel:^0 %s'):format(Cfg.VehicleFuel))
    add(('^6VehicleKeys:^0 %s'):format(Cfg.VehicleKeys))
    add('^6-----------------------^0\n')

    local output = table.concat(lines, '\n')
    Citizen.Trace(output .. '\n')
    CreateThread(function()
        Wait(0)
        Citizen.Trace(output)
    end)

    if sendToDiscord then
        if not CodesignDiscordWebhook or CodesignDiscordWebhook == '' or CodesignDiscordWebhook == 'DISCORD_WEBHOOK_HERE' then
            Citizen.Trace('CodesignDiscordWebhook is not set. Please set it in the config.lua file.\n')
            return
        end

        local uniqueId = GenerateUniqueId()

        local data = {{
            ['color'] = 56108,
            ['title'] = GetConvar('sv_projectName', 'unknown'),
            ['description'] = string.gsub(output, '%^%d', ''),
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ['footer'] = {
                ['text'] = ('ID: %s'):format(uniqueId),
                ['icon_url'] = 'https://i.imgur.com/VMPGPTQ.png',
            },
        }}
        PerformHttpRequest(CodesignDiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = 'cd_bridge', embeds = data}), { ['Content-Type'] = 'application/json' })
        Wait(1000)
        Citizen.Trace(('\n^2===================================================^0\n^2Debug log sent to Discord (^0ID: %s^2)^0\n^2===================================================^0\n'):format(uniqueId))
    end
end

if GetCurrentResourceName() == 'cd_bridge' then
    RegisterCommand('debugbridge', function(source, args)
        local isConsole = source == 0
        local isAdmin = HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'})
        local debugEnabled = Cfg.BridgeDebug
        local sendToDiscord = args and args[1] == '1' or nil

        if isConsole then
            DebugPrints(nil, sendToDiscord)
            return
        end

        if isAdmin or debugEnabled then
            DebugPrints(source, sendToDiscord)
            return
        end

        Citizen.Trace('You cannot use this command. You must have admin permissions, enable Cfg.BridgeDebug, or run it from the server console.\n')
    end, false)

    RegisterServerEvent('cd_bridge:debug:charInfo', function(message)
        ERROR('7903', 'Character info mismatch found between server and client.\n\n'..message)
    end)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          PRE START CHECKS                        │
-- └──────────────────────────────────────────────────────────────────┘ 

CreateThread(function()
    if GetCurrentResourceName() ~= 'cd_bridge' then return end
    Wait(1000)

    if Cfg == nil then
        ERROR('configuration_error_found', 'Cfg.lua Syntax Error')
    end

    if BridgeLocalesTable[Cfg.Language] == nil then
        ERROR('configuration_error_found', 'Cfg.Language/locales.lua Typo : ['..Cfg.Language..']')
    end

    if GetCurrentResourceName() ~= 'cd_bridge' then
        ERROR('configuration_error_found', 'Resource Name Changed : '..GetCurrentResourceName()..'')
    end

    if Cfg.Database ~= 'mysql-async' and Cfg.Database ~= 'ghmattimysql' and Cfg.Database ~= 'oxmysql' and Cfg.Database ~= 'none' then
        ERROR('configuration_error_found', 'Cfg.Database Error : ['..Cfg.Database..']')
    end

    if Cfg.Database == 'mysql-async' and not MySQL then
        MySQLErrorPrint()
    end

    if not HasFrameworkLoaded() then
        ERROR('framework_configuration_error_found', Cfg.Framework..' object not found. Please ensure that your framework resource is installed and running properly.')
    end
end)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                 OTHER                            │
-- └──────────────────────────────────────────────────────────────────┘ 

function MySQLErrorPrint()
    Citizen.Trace([[
        ^5===============================================================
        ^3[cd_bridge] ^7mysql-async not enabled
        ^5===============================================================

        ^7To enable ^2mysql-async^7 support:

        ^6• Open the ^2fxmanifest.lua^6 file
        ^6• Go to the ^2shared_scripts^6 section
        ^6• Remove the ^4--^6 from the beginning of the ^2@mysql-async/lib/MySQL.lua^6 line

        ^3After editing the file:
        ^6• Type ^2refresh^6 in your server console
        ^6• Restart this resource for the changes to apply

        ^5===============================================================
    ]] .. '^0\n')
end

function CheckAllItemsExist(needed)
    if Config.Inventory == 'none' then
        return
    end

    local have = {}

    local items = GetItemList()
    if not items then
        ERROR('0010', 'Inventory items table not available: '..Config.Inventory)
        return
    end
    for name, _ in pairs(items) do
        if name then have[name] = true end
    end

    local missing = {}
    for _, item_name in pairs(needed) do
        if not have[item_name] then
            missing[#missing+1] = item_name
        end
    end

    if #missing > 0 then
        table.sort(missing)
        local string = ''
        for _, item in ipairs(missing) do
            string = string..item..'\n'
        end
        string = string.sub(string, 1, -2)
        ERROR('configuration_error_found', 'Item(s) Not Found in Inventory Database/Table:\n\n'..string)
    end
end