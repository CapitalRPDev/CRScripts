if not Config.FlipCar.Enabled and not Config.TPCheckpoint.Enabled then
    return
end

---@type number?
local currentVehicle

local flipCarVisible = false
---@type KeyBind?
local flipCarBind = Config.FlipCar.Enabled and AddKeyBind({
    defaultKey = Config.FlipCar.Key,
    description = L("HUD.CONTROLS.FLIP_CAR_DESCRIPTION"),
    name = "flip_car"
}) or nil

local function ShowFlipCarControl()
    if not flipCarBind then
        return
    end

    local duration = Config.FlipCar.Duration
    local locale = (duration and duration > 0 and "HUD.CONTROLS.HOLD_FLIP_CAR") or "HUD.CONTROLS.FLIP_CAR"

    SendNUIAction("hud:addControl", {
        id = "flip_car",
        control = GetControlKey(flipCarBind.hash),
        text = L(locale),
        duration = duration
    })
end

if flipCarBind then
    function flipCarBind:onPress()
        if not currentVehicle then
            return
        elseif not Config.FlipCar.AlwaysVisible and not flipCarVisible then
            return
        end

        if not flipCarVisible then
            ShowFlipCarControl()
        end

        SendNUIAction("hud:startControlProgressBar", "flip_car")

        local finishedTimer = GetGameTimer() + (Config.FlipCar.Duration or 0)

        while self.pressed and finishedTimer > GetGameTimer() do
            Wait(100)
        end

        SendNUIAction("hud:stopControlProgressBar", "flip_car")

        if not self.pressed then
            if not flipCarVisible and not Config.FlipCar.AlwaysVisible then
                return SendNUIAction("hud:removeControl", "flip_car")
            end

            return
        end

        if not Config.FlipCar.AlwaysVisible then
            SendNUIAction("hud:removeControl", "flip_car")
            Wait(50)
        end

        SetVehicleOnGroundProperly(currentVehicle)

        flipCarVisible = false
    end
end

local flipCarInterval = Interval:new(function()
    if not currentVehicle then
        return
    end

    if IsVehicleStuckOnRoof(currentVehicle) then
        if flipCarVisible then
            return
        end

        SetNuiZindex(99)
        ShowFlipCarControl()

        flipCarVisible = true
    elseif flipCarVisible then
        if not Config.FlipCar.AlwaysVisible then
            SendNUIAction("hud:removeControl", "flip_car")
        end

        flipCarVisible = false
    end
end, 500, true)

local tpCheckpointVisible = false
local previousDistanceCovered = 0.0
local timeSinceDistanceIncrease = 0
---@type KeyBind?
local tpCheckpointBind = Config.TPCheckpoint.Enabled and AddKeyBind({
    defaultKey = Config.TPCheckpoint.Key,
    description = L("HUD.CONTROLS.TP_CHECKPOINT_DESCRIPTION"),
    name = "tp_checkpoint"
}) or nil

local function ShowTPCheckpointControl()
    if not tpCheckpointBind then
        return
    end

    local duration = Config.TPCheckpoint.Duration
    local locale = (duration and duration > 0 and "HUD.CONTROLS.HOLD_TP_CHECKPOINT") or "HUD.CONTROLS.TP_CHECKPOINT"

    SendNUIAction("hud:addControl", {
        id = "tp_checkpoint",
        control = GetControlKey(tpCheckpointBind.hash),
        text = L(locale),
        duration = duration
    })
end

---@param entity number
---@param coords vector3
local function Teleport(entity, coords)
    SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)

    while not HasCollisionLoadedAroundEntity(entity) do
        Wait(0)
        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
    end

    SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
end

if tpCheckpointBind then
    function tpCheckpointBind:onPress()
        if not currentVehicle then
            return
        elseif not tpCheckpointVisible and not Config.TPCheckpoint.AlwaysVisible then
            return
        end

        local raceData = GetCurrentRace()

        if not raceData then
            return
        end

        SendNUIAction("hud:startControlProgressBar", "tp_checkpoint")

        local finishedTimer = GetGameTimer() + (Config.TPCheckpoint.Duration or 0)

        while self.pressed and finishedTimer > GetGameTimer() do
            Wait(100)
        end

        SendNUIAction("hud:stopControlProgressBar", "tp_checkpoint")

        if not self.pressed then
            if not tpCheckpointVisible and not Config.TPCheckpoint.AlwaysVisible then
                return SendNUIAction("hud:removeControl", "tp_checkpoint")
            end

            return
        end

        if not Config.TPCheckpoint.AlwaysVisible then
            SendNUIAction("hud:removeControl", "tp_checkpoint")
            Wait(50)
        end

        local currentCheckpointIndex = raceData.currentCheckpointIndex
        local currentCheckpointCenter = raceData.checkpointCenters[currentCheckpointIndex]
        local previousCoords = currentCheckpointIndex == 1 and raceData.track.startPosition or raceData.checkpointCenters[currentCheckpointIndex - 1]
        local heading = GetHeadingFromVector_2d(
            currentCheckpointCenter.x - previousCoords.x,
            currentCheckpointCenter.y - previousCoords.y
        )

        Teleport(currentVehicle, previousCoords + vector3(0.0, 0.0, 3.0))

        SetVehicleOnGroundProperly(currentVehicle)
        SetEntityHeading(currentVehicle, heading)
    end
end

local tpCheckpointInterval = Interval:new(function(self)
    if not currentVehicle then
        return
    end

    local currentRace = GetCurrentRace()

    if not currentRace then
        return
    end

    if currentRace.distanceCovered > previousDistanceCovered then
        timeSinceDistanceIncrease = 0
    else
        timeSinceDistanceIncrease = timeSinceDistanceIncrease + self.interval
    end

    if timeSinceDistanceIncrease >= 3000 then
        if not tpCheckpointVisible then
            SetNuiZindex(99)
            ShowTPCheckpointControl()

            tpCheckpointVisible = true
        end
    else
        if tpCheckpointVisible then
            tpCheckpointVisible = false
        end

        if not Config.TPCheckpoint.AlwaysVisible then
            SendNUIAction("hud:removeControl", "tp_checkpoint")
        end
    end

    previousDistanceCovered = currentRace.distanceCovered
end, 250, false)

AddEventHandler("lb-racing:raceStarted", function(raceId, vehicle)
    currentVehicle = vehicle

    if Config.FlipCar.Enabled then
        AddVehicleUpsidedownCheck(vehicle)

        if not Config.FlipCar.AlwaysVisible then
            flipCarInterval:toggle(true)
        end

        if Config.FlipCar.AlwaysVisible then
            ShowFlipCarControl()
        end
    end

    if Config.TPCheckpoint.Enabled then
        previousDistanceCovered = 0.0
        timeSinceDistanceIncrease = 0

        if Config.TPCheckpoint.AlwaysVisible then
            ShowTPCheckpointControl()
        else
            tpCheckpointInterval:toggle(true)
        end
    end
end)

AddEventHandler("lb-racing:raceFinished", function()
    if not currentVehicle then
        return
    end

    if Config.FlipCar.Enabled then
        RemoveVehicleUpsidedownCheck(currentVehicle)
        SendNUIAction("hud:removeControl", "flip_car")

        flipCarInterval:toggle(false)
    end

    if Config.TPCheckpoint.Enabled then
        SendNUIAction("hud:removeControl", "tp_checkpoint")

        tpCheckpointInterval:toggle(false)
    end

    currentVehicle = nil
end)
