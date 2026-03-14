---@class KeyBindOptions
---@field name string
---@field description string
---@field defaultKey string
---@field defaultMapper? string
---@field secondaryKey? string
---@field secondaryMapper? string
---@field onPress? fun(self: KeyBind)
---@field onRelease? fun(self: KeyBind, timePressed: integer)

---@class KeyBind : KeyBindOptions
---@field defaultMapper string
---@field pressed boolean
---@field startedPressing integer
---@field disabled boolean
---@field hash integer
---@field hex string
---@field instructional string

---@type { [string]: KeyBind }
KeyBinds = {}

---@param options KeyBindOptions
---@return KeyBind
function AddKeyBind(options)
    ---@cast options KeyBind
    assert(type(options) == "table", "options must be a table")
    assert(type(options.name) == "string", "options.name must be a string")
    assert(type(options.description) == "string", "options.description must be a string")

    options.defaultMapper = options.defaultMapper or "keyboard"

    local name = "racing_" .. options.name:lower()
    local instructionalHash = joaat("+" .. name)

    options.hash = joaat("+" .. name) | 0x80000000
    options.hex = string.upper(string.format("%x", instructionalHash))

    if instructionalHash < 0 then
        options.hex = string.gsub(options.hex, string.rep("F", 8), "")
    end

    options.instructional = "~INPUT_" .. options.hex .. "~"

    RegisterCommand("+" .. name, function()
        if options.disabled or IsPauseMenuActive() then
            return
        end

        options.pressed = true
        options.startedPressing = GetGameTimer()

        if options.onPress then
            options:onPress()
        end

        TriggerEvent("lb-racing:keyPressed", options.name)
    end, false)

    RegisterCommand("-" .. name, function()
        if options.disabled or IsPauseMenuActive() then
            return
        end

        local timePressed = GetGameTimer() - (options.startedPressing or 0)

        options.pressed = false
        options.startedPressing = nil

        if options.onRelease then
            options:onRelease(timePressed)
        end

        TriggerEvent("lb-racing:keyReleased", options.name, timePressed)
    end, false)

    RegisterKeyMapping("+" .. name, options.description, options.defaultMapper, options.defaultKey)

    if options.secondaryKey then
        RegisterKeyMapping("~!+" .. name, options.description, options.secondaryMapper or options.defaultMapper, options.secondaryKey)
    end

    SetTimeout(500, function()
        TriggerEvent("chat:removeSuggestion", ("/+%s"):format(name))
        TriggerEvent("chat:removeSuggestion", ("/-%s"):format(name))
    end)

    KeyBinds[options.name] = options

    return options
end

---@param name string
function GetKeyBind(name)
    return KeyBinds[name]
end

---@param instructionalButton string
---@return string?
local function GetButtonFromInstructional(instructionalButton)
    local instructionalType = instructionalButton:sub(1, 2)

    if instructionalType == "t_" then
        local button = instructionalButton:gsub("t_", "")

        return button
    end
end

---@param control number
---@param padIndex? number
---@return string
function GetControlKey(control, padIndex)
    if not control then
        return ""
    end

    local instructionalButton = GetControlInstructionalButton(padIndex or 0, control, true)

    if instructionalButton:find("%%") then
        local alternatives = {}

        for alternative in instructionalButton:gmatch("([^%%]+)") do
            local button = GetButtonFromInstructional(alternative)

            if button then
                alternatives[#alternatives+1] = button
            end
        end

        if #alternatives > 0 then
            return table.concat(alternatives, "/")
        end
    end

    local button = GetButtonFromInstructional(instructionalButton)

    if button then
        return button
    end

    return instructionalButton
end

