---@alias RawLocales { [string]: string | RawLocales }
---@alias FormattedLocales { [string]: string }

---@param locales RawLocales
---@return FormattedLocales
local function GenerateLocales(locales)
    local formattedLocales = {}

    ---@param localeTable RawLocales
    ---@param prefix string
    local function FormatLocales(localeTable, prefix)
        for k, v in pairs(localeTable) do
            if type(v) == "table" then
                FormatLocales(v, prefix .. k .. ".")
            else
                formattedLocales[prefix .. k] = v
            end
        end
    end

    FormatLocales(locales, "")

    return formattedLocales
end

---@param locale string
---@return FormattedLocales
local function LoadLocales(locale)
    local fileContent = LoadResourceFile(GetCurrentResourceName(), "config/locales/" .. locale .. ".json")

    if not fileContent then
        infoprint("error", "Invalid locale '" .. locale .. "' (file not found)")
        return {}
    end

    local decoded = json.decode(fileContent)

    if not decoded then
        infoprint("error", "Invalid locale '" .. locale .. "' (error in file)")
        return {}
    end

    return GenerateLocales(decoded)
end

local locales = LoadLocales(Config.Language or "en")
local defaultLocales = Config.Language ~= "en" and LoadLocales("en") or {}

---@param input string
---@param variables table<string, string>[]
function FormatString(input, variables)
    assert(type(input) == "string", "input must be a string")
    assert(type(variables) == "table", "variables must be a table")

    for k, v in pairs(variables) do
        local safeValue = tostring(v):gsub("%%", "%%%%")

        input = input:gsub("{" .. k .. "}", safeValue)
    end

    return input
end

---@param path string
---@param args? table
---@return string
function L(path, args)
    assert(type(path) == "string", "path must be a string")

    local translation = locales[path] or defaultLocales[path] or path

    if args then
        translation = FormatString(translation, args)
    end

    return translation
end

function GetAllLocales()
    return locales
end

---@param number number
---@param decimalPlaces? number
---@param padDecimals? boolean
function FormatNumber(number, decimalPlaces, padDecimals)
    local thousandSeparator = L("THOUSAND_SEPARATOR")
    local decimalSeparator = L("DECIMAL_SEPARATOR")

    local integerPart = math.floor(math.abs(number))
    local formattedInteger = tostring(integerPart):reverse():gsub("(%d%d%d)", "%1" .. thousandSeparator):reverse()

    if formattedInteger:sub(1, 1) == thousandSeparator then
        formattedInteger = formattedInteger:sub(2)
    end

    if number < 0 then
        formattedInteger = "-" .. formattedInteger
    end

    if decimalPlaces and decimalPlaces > 0 then
        local decimalPart = string.format("%." .. decimalPlaces .. "f", math.abs(number) - math.floor(math.abs(number)))

        decimalPart = decimalPart:sub(3) -- remove 0.

        if not padDecimals then
            decimalPart = decimalPart:gsub("0+$", "")

            if decimalPart == "" then
                return formattedInteger
            end
        end

        return formattedInteger .. decimalSeparator .. decimalPart
    end

    return formattedInteger
end
