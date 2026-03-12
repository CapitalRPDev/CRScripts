-- Rounds numbers to a specified number of decimal places.
function RoundDecimals(data, decimalPlaces)
    decimalPlaces = decimalPlaces or 2
    local mult = 10 ^ decimalPlaces

    local function r(n)
        return Round(n * mult) / mult
    end

    if type(data) == 'vector4' then
        return {x = r(data.x), y = r(data.y), z = r(data.z), h = r(data.w)}

    elseif type(data) == 'vector3' then
        return {x = r(data.x), y = r(data.y), z = r(data.z)}

    elseif type(data) == 'number' then
        return r(data)

    elseif type(data) == 'table' then
        for k, v in pairs(data) do
            if type(v) == 'number' then
                data[k] = r(v)
            end
        end
        return data
    end
end

-- Rounds a number to the nearest integer.
function Round(num)
    return num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
end

-- Trims whitespace from both ends of a string.
function Trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Capitalizes the first letter of a string.
function CapitalizeFirstLetter(str)
    return (str:gsub("^%l", string.upper))
end

-- Checks if a string is nil, not a string, or consists only of whitespace.
function IsBlankString(str)
    return type(str) ~= 'string' or str:match('^%s*$') ~= nil
end

-- Normalizes the case of a string to either upper or lower case.
function FormatTextCase(string, mode)
    if type(string) ~= 'string' then
        return string
    end

    mode = mode and string.lower(mode) or 'upper'

    if mode == 'lower' then
        return string.lower(string)
    end

    return string.upper(string)
end

-- Generates a unique identifier string.
local __uid_counter = 0
function GenerateUniqueId(length)
    length = length or 16
    __uid_counter = __uid_counter + 1

    local ALPH = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local parts = {}

    local blocks = math.ceil(length / 6)

    for _ = 1, blocks do
        local t = GetGameTimer()
        local salt = string.format(
            '%d:%d:%d:%d:%d:%d',
            t * math.random(17, 97),
            t + math.random(0, 0x7FFFFFFF),
            __uid_counter * math.random(3, 29),
            math.random(0, 0x7FFFFFFF),
            math.random(0, 0x7FFFFFFF),
            (t % 1000) * math.random(1, 1000)
        )

        local h = 2166136261
        for i = 1, #salt do
            h = (h ~ salt:byte(i)) & 0xFFFFFFFF
            h = (h * 16777619) % 0x100000000
        end

        local block = {}
        for i = 1, 6 do
            local idx = (h % #ALPH) + 1
            block[i] = ALPH:sub(idx, idx)
            h = math.floor(h / #ALPH)
        end

        parts[#parts + 1] = table.concat(block)
    end

    local raw = table.concat(parts):sub(1, length)

    local t = {}
    for i = 1, #raw do
        t[i] = raw:sub(i, i)
    end
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    raw = table.concat(t)

    local out = {}
    for i = 1, length do
        out[#out + 1] = raw:sub(i, i)
        if i % 4 == 0 and i < length then
            out[#out + 1] = '-'
        end
    end

    return table.concat(out)
end

-- Registers a legacy export for a resource.
function RegisterLegacyExport(resourceName, exportName, callback)
    if not TypeCheck(resourceName, 'string', '4993', '"resourceName" must be a string.') then
        return
    end

    if not TypeCheck(exportName, 'string', '4994', '"exportName" must be a string.') then
        return
    end

    if not TypeCheck(callback, 'function', '4995', '"callback" must be a function.') then
        return
    end

    if resourceName == '' or exportName == '' then
        ERROR('4996', 'resourceName and exportName cannot be empty strings.')
        return
    end

    AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, exportName), function(register)
        register(function(...)
            local ok, result = pcall(callback, ...)
            if ok then
                return result
            end
            ERROR('4996', ('[RegisterLegacyExport] %s:%s failed: %s'):format(resourceName, exportName, tostring(result)))
            return nil
        end)
    end)
end