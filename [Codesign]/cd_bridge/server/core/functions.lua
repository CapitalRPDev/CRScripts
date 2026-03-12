-- Table debug print.
function TBL(t, src)
    if GetResourceState('cd_devtools') == 'started' then
        TriggerClientEvent('table', src or -1, t)
        print(json.encode(t, { indent = true }))
    else
        print(json.encode(t, { indent = true }))
    end
end

-- Notification wrapper.
function Notif(source, action, locale_key, ...)
    if not TypeCheck(source, 'number', '3000', 'source missing from Notif function, 1st arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    if not TypeCheck(action, 'number', '3001', 'action missing from Notif function, 2nd arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    if action < 1 or action > 3 then
        return ERROR('3002', 'action not valid in Notif function, 2nd arg: '..tostring(action)..'. Locale Key: '..(locale_key or 'nil'))
    end

    if not TypeCheck(locale_key, 'string', '3002', 'locale_key missing from Notif function, 3rd arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    local preferred = tostring(Config.Language):upper()

    local function getFromOneTable(tbl, langKey)
        if not tbl then return nil end
        if tbl[langKey] and tbl[langKey][locale_key] then
            return tbl[langKey][locale_key]
        end
        return nil
    end

    local function findTemplate(langKey)
        return getFromOneTable(LocalesTable, langKey) or getFromOneTable(Locales, langKey) or getFromOneTable(BridgeLocalesTable, langKey)
    end

    local template = findTemplate(preferred)

    if not template and preferred ~= 'EN' then
        template = findTemplate('EN')
    end

    if not template then
        return ERROR('3003', 'locale not found in any locale table: '..(locale_key or 'nil')..' (lang tried: '..preferred..' -> EN)')
    end

    local message = template

    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, template, ...)
        if not ok then
            return ERROR('3004', 'Format failed for key: ' .. (locale_key or 'nil'))
        end
        message = formatted
    end

    local ok, err = pcall(Notification, source, action, message)
    if not ok then
        return ERROR('3005', 'Notification failed: ' .. tostring(err))
    end
end

-- Attempts to json encode a table, but returns nil if the table is empty or nil.
function EncodeOrNil(value)
    if value == nil then
        return nil
    end

    if type(value) == 'table' then
        if next(value) == nil then
            return nil
        end
        return json.encode(value)
    end

    return value
end

-- Waits for an entity to exist from a netId, returns nil if it doesn't exist after the timeout.
function WaitForEntityFromNetId(netId, timeout)
    timeout = timeout or 2000
    local attempts = math.floor(timeout / 100)
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    local i = 0
    while vehicle == 0 and i < attempts do
        Wait(100)
        vehicle = NetworkGetEntityFromNetworkId(netId)
        i = i + 1
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    return vehicle
end