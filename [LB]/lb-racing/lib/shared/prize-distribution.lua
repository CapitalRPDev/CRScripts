---@param algorithm string
---@param prizePool number
---@param winners number
---@return number[]
function GetPrizePoolDistribution(algorithm, prizePool, winners)
    local distribution = {}

    if algorithm == "linear" then
        local sum = (winners * (winners + 1)) / 2

        for i = 1, winners do
            local share = (prizePool * (winners - i + 1)) / sum

            distribution[i] = math.floor(share + 0.5)
        end
    elseif algorithm == "exponential" then
        local distributionFactor = 2.0
        local weights = {}
        local totalWeight = 0.0

        for i = 1, winners do
            local weight = distributionFactor ^ (winners - i)

            weights[i] = weight
            totalWeight += weight
        end

        for i = 1, winners do
            local share = (prizePool * weights[i]) / totalWeight

            distribution[i] = math.floor(share + 0.5)
        end
    else
        infoprint("warning", "Unknown prize pool distribution algorithm: " .. tostring(algorithm) .. ". Defaulting to linear.")

        return GetPrizePoolDistribution("linear", prizePool, winners)
    end

    return distribution
end
