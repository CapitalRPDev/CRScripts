if not Config.Debug then return end

RegisterNetEvent('cd_garage:GetVehicleImageFileNames', function(vehicleImagesToAdd)
    print('^3STARTING^0')
    local waitTime = 5000
    for i, cd in ipairs(vehicleImagesToAdd) do
        if not cd.model then
            cd.model = GetDisplayNameFromVehicleModel(tonumber(cd.modelHash)):lower()
        end

        local remaining = (#vehicleImagesToAdd - i) * (waitTime / 1000)
        local mins = math.floor(remaining / 60)
        local secs = remaining % 60

        local eta = ''
        if mins > 0 then
            eta = string.format('%dm %ds', mins, secs)
        else
            eta = string.format('%ds', secs)
        end

        print(('^3[INFO]^0 (^5%d^0/^5%d^0) Saving image for vehicle model: ^2[%s]^0 | ^6Time remaining: %s^0'):format(i, #vehicleImagesToAdd, cd.model, eta))

        ExecuteCommand(('screenshotvehicle %s'):format(cd.model))
        Wait(waitTime)
    end
    print('^3FINISHED^0')
end)
