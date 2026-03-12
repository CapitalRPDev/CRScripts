-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               BRIDGE                             │
-- └──────────────────────────────────────────────────────────────────┘

local function HandleBridgeStart()
    if Config.VehicleKeys.ENABLE then
        TriggerServerEvent('cd_garage:LoadCachedkeys')
    end
    if Config.PrivateGarages.ENABLE then
        TriggerServerEvent('cd_garage:LoadPrivateGarages')
    end
    TriggerServerEvent('cd_garage:VehicleData')

    if Config.GangGarages.ENABLE then
        local gangName = GetGangName()
        if gangName == 'none' then
            PlayerChangedGang()
        else
            PlayerChangedGang()
        end
    end
end

RegisterNetEvent('cd_bridge:TriggerStartEvents', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    HandleBridgeStart()
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    HandleBridgeStart()
end)


RegisterNetEvent('cd_bridge:OnJobChanged', function(data)

end)

RegisterNetEvent('cd_bridge:OnDutyChanged', function(data)

end)

RegisterNetEvent('cd_bridge:OnGangChanged', function(data)
    if not Config.GangGarages.ENABLE then return end
    if not data then return end

    if data.new.name == 'none' then
        PlayerLeftGang()
        return
    end

    if data.gang_changed then
        PlayerChangedGang()
    end
end)