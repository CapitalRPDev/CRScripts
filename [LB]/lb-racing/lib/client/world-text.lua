---@class WorldText
---@field text string
---@field x number
---@field y number
---@field z number
---@field scale number
---@field font number
---@field height number
---@field width number

---@class WorldText
WorldText = {}
WorldText.__index = WorldText

---@type WorldText[]
local worldTextPool = {}

local drawWorldTextsInterval = Interval:new(function()
    local camCoords = GetFinalRenderedCamCoord()

    table.sort(worldTextPool, function(a, b)
        return #(camCoords - a.coords) < #(camCoords - b.coords)
    end)

    for i = 1, math.min(#worldTextPool, 32) do
        local worldText = worldTextPool[i]

        if #(camCoords - worldText.coords) <= worldText.drawDistance then
            SetDrawOrigin(worldText.x, worldText.y, worldText.z, 0)

            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(worldText.text)
            SetTextScale(worldText.scale, worldText.scale)
            SetTextCentre(true)
            SetTextFont(worldText.font)
            EndTextCommandDisplayText(0.0, 0.0)

            DrawRect(0.0, worldText.height / 2, worldText.width, worldText.height, 45, 45, 45, 150)

            ClearDrawOrigin()
        end
    end
end, 0, false)

---@param text string
---@param coords vector3 | vector4
---@param scale? number
---@param font? number
---@param drawDistance? number
function WorldText:new(text, coords, scale, font, drawDistance)
    self = setmetatable({}, self)

    scale = scale or 0.35
    font = font or 4

    self.text = text
    self.coords = vector3(coords.x, coords.y, coords.z)
    self.x = coords.x
    self.y = coords.y
    self.z = coords.z
    self.scale = scale
    self.font = font
    -- self.drawDistance = drawDistance or 25.0
    self.drawDistance = drawDistance or 500.0

    local height = GetRenderedCharacterHeight(scale, font) * 1.2
    local _, newLines = text:gsub("\n", "")

    height = height * (newLines + 1)

    BeginTextCommandGetWidth("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)

    self.width = EndTextCommandGetWidth(true) + 0.0015
    self.height = height

    worldTextPool[#worldTextPool + 1] = self

    drawWorldTextsInterval:toggle(true)

    return self
end

---@param text string
function WorldText:setText(text)
    local height = GetRenderedCharacterHeight(self.scale, self.font) * 1.2
    local _, newLines = text:gsub("\n", "")

    height = height * (newLines + 1)

    self.text = text

    BeginTextCommandGetWidth("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)

    self.width = EndTextCommandGetWidth(true) + 0.0015
    self.height = height
end

function WorldText:remove()
    for i = 1, #worldTextPool do
        if worldTextPool[i] == self then
            table.remove(worldTextPool, i)
            break
        end
    end

    if #worldTextPool == 0 then
        drawWorldTextsInterval:toggle(false)
    end

    self = nil
end

---@param coords vector3 | vector4
function WorldText:setCoords(coords)
    self.coords = vector3(coords.x, coords.y, coords.z)
    self.x = coords.x
    self.y = coords.y
    self.z = coords.z
end
