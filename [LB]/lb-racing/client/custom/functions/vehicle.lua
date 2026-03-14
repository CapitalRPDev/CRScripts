---@param vehicle number
function GetVehicleTier(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local acceleration = GetVehicleModelAcceleration(vehicleModel)
    local maxSpeed = GetVehicleModelEstimatedMaxSpeed(vehicleModel)
    local braking = GetVehicleModelMaxBraking(vehicleModel)
    local traction = GetVehicleModelMaxTraction(vehicleModel)

    debugprint("Raw Vehicle stats:", acceleration, maxSpeed, braking, traction)

    braking += 1
    acceleration += 1
    maxSpeed /= 8

    acceleration = acceleration ^ 8.5
    maxSpeed = maxSpeed ^ 2.8
    braking = braking ^ 1.8
    traction = traction ^ 1.6

    acceleration *= 25
    maxSpeed *= 3
    braking *= 24
    traction *= 25

    debugprint("Modified Vehicle stats:", acceleration, maxSpeed, braking, traction)

    local score = (acceleration + maxSpeed + braking + traction)
    local tier = Config.VehicleTiers[#Config.VehicleTiers].value

    for i = 1, #Config.VehicleTiers do
        local tierData = Config.VehicleTiers[i]

        if score >= tierData.score then
            tier = tierData.value
            break
        end
    end

    debugprint("^6Vehicle Tier:^4", tier, "-", score)

    return tier
end

---@param netId number
RegisterClientCallback("getVehicleTier", function(netId)
    local vehicle = WaitForNetId(netId, 5000)

    if not vehicle or not DoesEntityExist(vehicle) then
        debugprint("Invalid vehicle?", netId)

        return Config.VehicleTiers[1].value
    end

    return GetVehicleTier(vehicle)
end)

---@param model number
---@return string
function GetVehicleModelName(model)
    local vehicleLabel = GetDisplayNameFromVehicleModel(model):lower()

    if not vehicleLabel or vehicleLabel == "null" or vehicleLabel == "carnotfound" then
        return "Unknown"
    end

    local labelText = GetLabelText(vehicleLabel)

    if labelText and labelText:lower() ~= "null" then
        vehicleLabel = labelText:gsub("µ", " ")
    end

    return vehicleLabel
end
