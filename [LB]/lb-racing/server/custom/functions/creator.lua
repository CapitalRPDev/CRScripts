---@param source number
---@return number
function GetEmptyRoutingBucket(source)
    local bucketId = source

    while not IsRoutingBucketEmpty(bucketId) do
        bucketId += 1
    end

    return bucketId
end
