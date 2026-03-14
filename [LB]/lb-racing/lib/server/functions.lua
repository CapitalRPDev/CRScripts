---@param source number
---@param vehicle number
function GetVehicleTier(source, vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local tier = AwaitClientCallback("getVehicleTier", source, netId)

    for i = 1, #Config.VehicleTiers do
        if tier == Config.VehicleTiers[i].value then
            return tier
        end
    end

    debugprint("Player", source, "returned an invalid tier in GetVehicleTier:", tier)

    return Config.VehicleTiers[1].value
end
