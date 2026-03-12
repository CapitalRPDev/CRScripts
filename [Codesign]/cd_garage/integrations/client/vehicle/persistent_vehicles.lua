function AddPersistentVehicle(vehicle, plate, job_vehicle) --This will be triggered everytime a vehicle is spawned.
    local net_id = NetworkGetNetworkIdFromEntity(vehicle)
    if Config.PersistentVehicles.ENABLE then
        TriggerServerEvent('cd_garage:AddPersistentVehicles', plate, net_id, job_vehicle)

    else
        --Add your own code here if needed.
    end
end

function RemovePersistentVehicle(vehicle, plate) --This will be triggered everytime a vehicle is stored/deleted.
    if Config.PersistentVehicles.ENABLE then
        TriggerServerEvent('cd_garage:RemovePersistentVehicles', plate)
    else
        if GetResourceState('AdvancedParking') == 'started' then
            exports['AdvancedParking']:DeleteVehicle(vehicle)
        end
        --Add your own code here if needed.
    end
end