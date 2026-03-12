--- @param vehicle number       The vehicle entity.
--- @param plate string         The vehicle plate.
function RegisterPersistentVehicle(vehicle, plate, cd)
    local net_id = NetworkGetNetworkIdFromEntity(vehicle)

    if Cfg.PersistentVehicles == 'cd_garage' then
        TriggerServerEvent('cd_garage:AddPersistentVehicles', plate, net_id, cd)

    elseif Cfg.PersistentVehicles == 'AdvancedParking' then
        exports['AdvancedParking']:UpdateVehicle(vehicle)

    elseif Cfg.PersistentVehicles == 'other' then
        --Add your own code here if needed.
    end
end

--- @param vehicle number       The vehicle entity.
--- @param plate string         The vehicle plate.
function UnRegisterPersistentVehicle(vehicle, plate)
    if Cfg.PersistentVehicles == 'cd_garage' then
        TriggerServerEvent('cd_garage:RemovePersistentVehicles', plate)

    elseif Cfg.PersistentVehicles == 'AdvancedParking' then
        exports['AdvancedParking']:DeleteVehicle(vehicle)

    elseif Cfg.PersistentVehicles == 'other' then
        --Add your own code here if needed.
    end
end