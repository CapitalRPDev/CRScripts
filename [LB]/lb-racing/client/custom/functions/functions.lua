---@param action string
---@param data any
function SendAppMessage(action, data)
    if CurrentDevice == "phone" then
        exports["lb-phone"]:SendCustomAppMessage("lb-racing", { action = action, data = data })
    elseif CurrentDevice == "tablet" then
        exports["lb-tablet"]:SendCustomAppMessage("lb-racing", action, data)
    else
        SendNUIAction(action, data)
    end
end

---@param action string
---@param data any
function SendNUIAction(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

function RefreshPermissions()
    SendAppMessage("setPermissions", {
        track = {
            create = CanCreateTrack(),
            freecam = CanUseFreecam()
        },
        race = GetCreateRacePermissions()
    })
end

---@param model string | number
---@return string | number model
function LoadModel(model)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    return model
end

---@param dict string
---@return string dict
function LoadDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    return dict
end

---@param ptfx string
---@return string ptfx
function LoadPtfx(ptfx)
	RequestNamedPtfxAsset(ptfx)

	while not HasNamedPtfxAssetLoaded(ptfx) do
		Wait(0)
	end

	UseParticleFxAsset(ptfx)

    return ptfx
end

---@param coords vector3 | vector4
---@param sprite number
---@param colour number
---@param scale? number
---@param label string
---@return number
function CreateBlip(coords, sprite, colour, scale, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale or 0.8)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)

    return blip
end

local drawingHelpText = false

---@param text string
---@param button number
---@param instructionalKey string
function DrawHelpText(text, button, instructionalKey)
    drawingHelpText = true

    if Config.HelpTextStyle == "default" then
        SendNUIAction("hud:setHelptext", { control = GetControlKey(button), label = text })
    elseif Config.HelpTextStyle == "ox_lib" then
        local key = "[" .. GetControlInstructionalButton(0, button, true):gsub("t_", "") .. "]"

        exports.ox_lib:showTextUI(key .. " - " .. text)
    elseif Config.HelpTextStyle == "gta" then
        BeginTextCommandDisplayHelp("STRING")
        AddTextComponentSubstringPlayerName(instructionalKey .. " " .. text)
        EndTextCommandDisplayHelp(0, true, true, 0)
    end
end

function ClearHelpText()
    if not drawingHelpText then
        return
    end

    drawingHelpText = false

    if Config.HelpTextStyle == "default" then
        SendNUIAction("hud:setHelptext", nil)
    elseif Config.HelpTextStyle == "ox_lib" then
        exports.ox_lib:hideTextUI()
    elseif Config.HelpTextStyle == "gta" then
        ClearHelp(true)
    end
end

function ShouldUseImperial()
    if Config.Units == "imperial" then
        return true
    elseif Config.Units == "metric" then
        return false
    else
        return not ShouldUseMetricMeasurements()
    end
end

---@param netId number
---@param timeout? number # Timeout in milliseconds. Defaults to 15000ms.
---@return number? entity
function WaitForNetId(netId, timeout)
    timeout = timeout or 15000

    local startTime = GetGameTimer()

    while not NetworkDoesNetworkIdExist(netId) or not NetworkGetEntityFromNetworkId(netId) do
        Wait(0)

        if timeout and GetGameTimer() - startTime > timeout then
            debugprint("WaitForNetId: Timed out waiting for netId:", netId, "after", timeout, "ms")
            return
        end
    end

    return NetworkGetEntityFromNetworkId(netId)
end

---@param ms number
function FormatTime(ms)
    local hours = math.floor(ms / 3600000)
    local minutes = math.floor((ms % 3600000) / 60000)
    local seconds = math.floor((ms % 60000) / 1000)
    local milliseconds = ms % 1000

    if hours > 0 then
        return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    elseif minutes > 0 then
        return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
    else
        return string.format("%02d.%03d", seconds, milliseconds)
    end
end

---@param message string
---@param level? "info" | "success" | "warning" | "error"
---@param title? string
function Notify(message, level, title)
    if Config.NotificationSystem == "ox_lib" then
        if level == "info" then
            ---@diagnostic disable-next-line: cast-local-type
            level = "inform"
        end

        exports.ox_lib:notify({
            title = title or message,
            description = title and message or nil,
            type = level,
        })
    elseif Config.NotificationSystem == "gta" then
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostMessagetext(
            "CHAR_BLOCKED",
            "CHAR_BLOCKED",
            true,
            1,
            title or L("NOTIFICATION_TITLE"),
            ""
        )
    elseif Config.Framework == "esx" then
        TriggerEvent("esx:showNotification", message, level, nil, title)
    elseif Config.Framework == "qb" or Config.Framework == "qbox" then
        if level == "info" or level == "warning" then
            ---@diagnostic disable-next-line: cast-local-type
            level = "primary"
        end

        TriggerEvent("QBCore:Notify", message, level)
    end
end

RegisterNetEvent("lb-racing:notify", Notify)

local freezeWeatherInterval = Interval:new(function()
    local weather = Config.Creator.Weather

    NetworkOverrideClockTime(weather.Hour, weather.Minute, 0)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist(weather.Type)
    SetWeatherTypeNow(weather.Type)
    SetWeatherTypeNowPersist(weather.Type)
end, 500, false)

function FreezeWeather()
    if not Config.Creator?.Weather?.Freeze then
        return
    end

    TriggerEvent("ToggleWeatherSync", false)
    TriggerEvent("qb-weathersync:client:DisableSync")
    TriggerEvent("cd_easytime:PauseSync", true, Config.Creator.Weather.Hour)

    freezeWeatherInterval:toggle(true)
end

function UnfreezeWeather()
    if not Config.Creator?.Weather?.Freeze then
        return
    end

    freezeWeatherInterval:toggle(false)

    TriggerEvent("ToggleWeatherSync", true)
    TriggerEvent("qb-weathersync:client:EnableSync")
    TriggerEvent("cd_easytime:PauseSync", false)
end

local appRemoved = false

exports("RemoveApp", function()
    appRemoved = true

    RefreshApps()
end)

exports("AddApp", function()
    appRemoved = false

    RefreshApps()
end)

function ShouldAddApp()
    if appRemoved then
        debugprint("App has been removed via export")
        return false
    end

    if Config.App.RequireItem and not HasItem(Config.App.RequireItem) then
        debugprint("Player does not have required item:", Config.App.RequireItem)
        return false
    end

    if #Config.App.BlacklistedJobs > 0 and table.contains(Config.App.BlacklistedJobs, GetJob()) then
        debugprint("Player job is blacklisted")
        return false
    end

    return true
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    ClearHelpText()
end)

CreateThread(function()
    AddCanOpenCheck(function()
        if IsNuiFocused() then
            debugprint("Cannot open racing tablet, NUI is focused")
            return false
        end

        if IsPedDeadOrDying(PlayerPedId(), true) then
            debugprint("Cannot open racing tablet, player is dead or dying")
            return false
        end

        if GetResourceState("lb-phone") == "started" and exports["lb-phone"]:IsOpen() then
            debugprint("Cannot open racing tablet, lb-phone is open")
            return false
        end

        if GetResourceState("lb-tablet") == "started" and exports["lb-tablet"]:IsOpen() then
            debugprint("Cannot open racing tablet, lb-tablet is open")
            return false
        end

        return true
    end)
end)
