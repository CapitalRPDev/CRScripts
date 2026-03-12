function CheckBlips(EnableBlip, JobRestricted)
    if EnableBlip == false then
        return false
    elseif JobRestricted == nil then
        return true
    elseif JobRestricted ~= nil then
        local myjob = GetJobName()
        for c, d in ipairs(JobRestricted) do
            if myjob == d then
                return true
            end
        end
        return false
    end
end

local function ListRestrictedJobs(c, blip)
    local text = ''
    for _, d in ipairs(c) do
        text = text..' '..d..','
    end
    text = text:sub(1, -2):sub(2)
    return text
end

for c, d in pairs (Config.Locations) do
    if d.Type ~= nil then
        if CheckBlips(d.EnableBlip, d.JobRestricted) then
            local blip = AddBlipForCoord(d.x_1, d.y_1, d.z_1)
            SetBlipSprite(blip, Config.Blip[d.Type].sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blip[d.Type].scale)
            SetBlipColour(blip, Config.Blip[d.Type].colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            if Config.Unique_Blips and not d.JobRestricted then
                AddTextComponentSubstringPlayerName(Config.Blip[d.Type].name:sub(1, -2)..': '..d.Garage_ID)
            elseif d.JobRestricted then
                AddTextComponentSubstringPlayerName(Config.Blip[d.Type].name:sub(1, -2)..': '..d.Garage_ID..' ['..ListRestrictedJobs(d.JobRestricted)..']')
            else
                AddTextComponentSubstringPlayerName(Config.Blip[d.Type].name:sub(1, -2))
            end
            EndTextCommandSetBlipName(blip)
        end
    end
end
