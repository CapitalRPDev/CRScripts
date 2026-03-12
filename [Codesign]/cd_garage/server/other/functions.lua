AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        if Config.Mileage.ENABLE then
            TriggerClientEvent('cd_garage:SaveAllMiles', -1)
        end
        if Config.Impound.ENABLE then
            TriggerEvent('cd_garage:SaveImpoundTimers')
        end
        if Config.VehicleKeys.ENABLE then
            TriggerClientEvent('cd_garage:SaveAllVehicleDamage', -1)
        end
        if Config.PersistentVehicles.ENABLE then
            TriggerEvent('cd_garage:SavePersistentVehicles')
        end
    end
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    if Config.Mileage.ENABLE then
        TriggerClientEvent('cd_garage:SaveAllMiles', -1)
    end
    if Config.Impound.ENABLE then
        TriggerEvent('cd_garage:SaveImpoundTimers')
    end
    if Config.VehicleKeys.ENABLE then
        TriggerClientEvent('cd_garage:SaveAllVehicleDamage', -1)
    end
    if Config.PersistentVehicles.ENABLE then
        TriggerEvent('cd_garage:SavePersistentVehicles')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if Config.Mileage.ENABLE then
        TriggerClientEvent('cd_garage:SaveAllMiles', -1)
    end
    if Config.Impound.ENABLE then
        TriggerEvent('cd_garage:SaveImpoundTimers')
    end
    if Config.VehicleKeys.ENABLE then
        TriggerClientEvent('cd_garage:SaveAllVehicleDamage', -1)
    end
    -- if Config.PersistentVehicles.ENABLE then
    --     TriggerEvent('cd_garage:SavePersistentVehicles')
    -- end
end)

function GetAllPlayers(source)
    local players = {}
    local AllPlayers = GetPlayers()
    for _, src in ipairs(AllPlayers) do
        src = tonumber(src)
        if src ~= source then
            players[#players+1] = {}
            if Config.PlayerListMethod == 'both' or Config.PlayerListMethod == 'charname' then
                players[#players].name = GetCharacterName(src)
            end
            players[#players].source = src
        end
    end
    return players
end

function IsAllowed_Impound(source)
    if Config.Impound.Authorized_Jobs[GetJobName(source)] and GetJobDuty(source) then
        return true
    else
        return false
    end
end