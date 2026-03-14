IS_BETA_VERSION = GetResourceMetadata(GetCurrentResourceName(), "beta", 0) == "yes"

local scriptVersion = (GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "")  .. (IS_BETA_VERSION and "-b" or "")

---@param resource string
function IsResourceStartedOrStarting(resource)
    local state = GetResourceState(resource)

    return state == "started" or state == "starting"
end

function debugprint(...)
    if not Config.Debug then
        return
    end

    local data = { ... }
    local length = #data
    local str = ""

    for i = 1, length do
        if type(data[i]) == "table" then
            str = str .. json.encode(data[i], {
                sort_keys = true,
                indent = true,
                indent_amt = 2,
                exception = function(reason, value)
                    return tostring(value)
                end
            })
        elseif type(data[i]) ~= "string" then
            str = str .. tostring(data[i])
        else
            str = str .. data[i]
        end

        if i ~= length then
            str = str .. " "
        end
    end

    print("^6[LB Racing " .. scriptVersion .. "] ^5[Debug]^7: " .. str)
end

local infoLevels = {
    success = "^2[SUCCESS]",
    info = "^5[INFO]",
    warning = "^3[WARNING]",
    error = "^1[ERROR]"
}

---@param level "success" | "info" | "warning" | "error"
---@param text string
function infoprint(level, text, ...)
    local prefix = infoLevels[level]

    if not prefix then
        prefix = "^5[INFO]^7:"
    end

    print("^6[LB Racing " .. scriptVersion .. "] " .. prefix .. "^7: " .. text, ...)
end

if Config.Framework == "auto" then
    debugprint("Detecting framework")

    if IsResourceStartedOrStarting("es_extended") then
        Config.Framework = "esx"
    elseif IsResourceStartedOrStarting("qbx_core") then
        Config.Framework = "qbox"
    elseif IsResourceStartedOrStarting("qb-core") then
        Config.Framework = "qbcore"
    else
        Config.Framework = "standalone"
    end

    debugprint("Detected framework:", Config.Framework)
end

if Config.NotificationSystem == "auto" then
    debugprint("Detecting notification system")

    if IsResourceStartedOrStarting("ox_lib") then
        Config.NotificationSystem = "ox_lib"
    elseif Config.Framework == "esx" then
        Config.NotificationSystem = "esx"
    elseif Config.Framework == "qbox" or Config.Framework == "qb" then
        Config.NotificationSystem = "qb"
    else
        Config.NotificationSystem = "gta"
    end

    debugprint("Detected notification system:", Config.NotificationSystem)
end

if Config.Standalone.Enabled == "auto" then
    debugprint("Detecting standalone tablet option")

    if not IsResourceStartedOrStarting("lb-phone") and not IsResourceStartedOrStarting("lb-tablet") then
        Config.Standalone.Enabled = true
    else
        Config.Standalone.Enabled = false
    end

    debugprint("Detected standalone tablet option:", Config.Standalone.Enabled)
end

---@param value number
---@param min number
---@param max number
function math.clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end

    return value
end

---@param value number
---@param numDecimalPlaces? number
function math.round(value, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    local rounded = math.floor(value * mult + 0.5) / mult

    if numDecimalPlaces and numDecimalPlaces > 0 then
        return rounded
    end

    return math.floor(rounded)
end

---@param t table
---@param value any
function table.contains(t, value)
    for i = 1, #t do
        if t[i] == value then
            return true
        end
    end

    return false
end

---@param vectors vector3 | vector4 | vector3[] | vector4[]
---@return vector3
function GetCenterVector(vectors)
    if type(vectors) == "vector3" or type(vectors) == "vector4" then
        return vector3(vectors.x, vectors.y, vectors.z)
    end

    local sumX = 0.0
    local sumY = 0.0
    local sumZ = 0.0
    local amountVectors = 0

    for i = 1, #vectors do
        local vector = vectors[i]
        local vectorType = type(vector)

        if vectorType == "vector3" or vectorType == "vector4" then
            amountVectors += 1
            sumX += vector.x
            sumY += vector.y
            sumZ += vector.z
        end
    end

    return vector3(
        sumX / amountVectors,
        sumY / amountVectors,
        sumZ / amountVectors
    )
end

---@alias Vector2Array [number, number]
---@alias Vector3Array [number, number, number]
---@alias Vector4Array [number, number, number, number]
---@alias VectorArray Vector2Array | Vector3Array | Vector4Array

---@param vector vector
---@return VectorArray
function VectorToArray(vector)
    local x, y, z, w = table.unpack(vector)

    x = x and math.round(x, 2) or nil
    y = y and math.round(y, 2) or nil
    z = z and math.round(z, 2) or nil
    w = w and math.round(w, 2) or nil

    return { x, y, z, w }
end

---@param array VectorArray
---@return vector?
function ArrayToVector(array)
    if #array == 2 then
        return vector2(array[1], array[2])
    elseif #array == 3 then
        return vector3(array[1], array[2], array[3])
    elseif #array == 4 then
        return vector4(array[1], array[2], array[3], array[4])
    end
end

---@param trackType TrackType
---@param checkpointCenterPositions vector3[]
---@return number length The track length in meters
function GetTrackLength(trackType, checkpointCenterPositions)
    local trackLength = 0

    for i = 1, #checkpointCenterPositions do
        local nextCheckpoint = checkpointCenterPositions[i + 1]

        if not nextCheckpoint and trackType == "circuit" then
            nextCheckpoint = checkpointCenterPositions[1]
        end

        if nextCheckpoint then
            trackLength = trackLength + #(checkpointCenterPositions[i] - nextCheckpoint)
        end
    end

    return trackLength
end

---@param coords vector3
---@param lineCoordsA vector3
---@param lineCoordsB vector3
function GetPerpendicularHeading(coords, lineCoordsA, lineCoordsB)
    local checkpointLine = lineCoordsA - lineCoordsB
    local perpendicular = vector3(-checkpointLine.y, checkpointLine.x, 0)
    local lineCenter = (lineCoordsA + lineCoordsB) / 2.0
    local center = lineCenter - coords
    local dotProduct = (perpendicular.x * center.x) + (perpendicular.y * center.y)

    if dotProduct < 0 then
        perpendicular = perpendicular * -1.0
    end

    local heading = GetHeadingFromVector_2d(perpendicular.x, perpendicular.y)

    return heading
end

---@param point vector3
---@param origin vector3
---@param rotation vector3
function RotateVector3(point, origin, rotation)
    local radX, radY, radZ = math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z)
    local x, y, z = point.x - origin.x, point.y - origin.y, point.z - origin.z

    local cosX, sinX = math.cos(radX), math.sin(radX)
    local y1 = y * cosX - z * sinX
    local z1 = y * sinX + z * cosX

    local cosY, sinY = math.cos(radY), math.sin(radY)
    local x2 = x * cosY + z1 * sinY
    local z2 = -x * sinY + z1 * cosY

    local cosZ, sinZ = math.cos(radZ), math.sin(radZ)
    local x3 = x2 * cosZ - y1 * sinZ
    local y3 = x2 * sinZ + y1 * cosZ

    return vector3(x3 + origin.x, y3 + origin.y, z2 + origin.z)
end

function IsDatabaseValueTruthy(value)
    if not value or value == 0 then
        return false
    end

    return true
end

---@param number number
function GetOrdinal(number)
    local ordinal = "OTHER"
    local absolute = math.abs(number)
    local lastTwoDigits = absolute % 100
    local lastDigit = absolute % 10

    if lastTwoDigits >= 11 and lastTwoDigits <= 13 then
        ordinal = "OTHER"
    elseif lastDigit == 1 then
        ordinal = "ONE"
    elseif lastDigit == 2 then
        ordinal = "TWO"
    elseif lastDigit == 3 then
        ordinal = "FEW"
    else
        ordinal = "OTHER"
    end

    return L("ORDINAL." .. ordinal)
end

---@param number number
---@param decimals number
---@return number
function LimitDecimals(number, decimals)
    if math.floor(number) == number then
        return math.floor(number)
    end

    local mult = 10 ^ decimals
    local value = math.floor(number * mult + 0.5) / mult

    if decimals == 0 then
        return math.floor(value + 0.5)
    end

    return value
end
