local function LoadLocaleFile(language)
	local rawLocales = LoadResourceFile(GetCurrentResourceName(), "config/locales/" .. language .. ".lua")

	if not rawLocales then
		print("warning Locale file '" .. language .. ".lua' not found")
		return {}
	end

	local fn, err = load(rawLocales)

	if not fn or err then
		print("error Failed to load locale file '" .. language .. ".lua': " .. (err or ""))
		return {}
	end

	local locales = fn()
	local formattedLocales = {}

	local function FormatLocales(localeTable, prefix)
		prefix = prefix or ""

		for k, v in pairs(localeTable) do
			if type(v) == "table" and #v == 0 then
				FormatLocales(v, prefix .. k .. ".")
			else
				formattedLocales[prefix .. k] = v
			end
		end
	end

	FormatLocales(locales)

	return formattedLocales
end

if type(Config.Locale) ~= "string" then
	Config.Locale = "en"
end

local locales = LoadLocaleFile(Config.Locale)

if Config.Locale ~= "en" then
	local fallbackLocales = LoadLocaleFile("en")

	for path, locale in pairs(fallbackLocales) do
		if not locales[path] then
			locales[path] = locale
		end
	end
end

function L(path, args)
	local translation = locales[path] or path

	if args then
		for k, v in pairs(args) do
			local escapedValue = tostring(v):gsub("%%", "%%%%")

			translation = translation:gsub("{" .. k .. "}", escapedValue)
		end
	end

	return translation
end

function GetAllLocales()
	return locales
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = Config.Debug

function DebugPrint(fmt, ...)
	if not debugIsEnabled then
		return
	end
	local msg = string.format(fmt, ...)
	local finalMsg = string.format("^3[%s]^0%s", currentResourceName, msg)
	print(finalMsg)
end
