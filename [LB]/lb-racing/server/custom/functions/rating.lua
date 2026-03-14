---@param selfRating number
---@param opponentRating number
local function ExpectedScore(selfRating, opponentRating)
    return 1 / (1 + 10 ^ ((opponentRating - selfRating) / 400))
end

---@param ratings number[] # The initial ratings of all players
---@param kFactor? number
---@return number[] updatedRatings
function CalculateRatings(ratings, kFactor)
    kFactor = kFactor or 32

    if #ratings < 2 then
        return ratings
    end

    local updatedRatings = table.clone(ratings)

    for i = 1, #updatedRatings do
        for j = i + 1, #updatedRatings do
            local rating1 = updatedRatings[i]
            local rating2 = updatedRatings[j]

            local expected1 = ExpectedScore(rating1, rating2)
            local expected2 = ExpectedScore(rating2, rating1)

            local newRating1 = rating1 + kFactor * (1 - expected1)
            local newRating2 = rating2 + kFactor * (0 - expected2)

            updatedRatings[i] = newRating1
            updatedRatings[j] = newRating2
        end
    end

    for i = 1, #updatedRatings do
        updatedRatings[i] = math.floor(updatedRatings[i] + 0.5)
    end

    return updatedRatings
end
