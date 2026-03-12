function SpawnVehicle(data, jobspawn, jobspawn_owned, tp_invehicle, persistent)
    InGarage = false
    TriggerEvent('cd_garage:Exit', false)

    local ped = PlayerPedId()
    local props
    local model
    if not jobspawn then
        props = data.vehicle
        model = props.model
    else
        model = data.model
    end

    local plate = data.plate
    local adv_stats
    if Config.Mileage.ENABLE and not jobspawn and data.adv_stats then
        adv_stats = data.adv_stats
    end

    if not IsModelValid(model) then
        CloseAllNUI()
        Notif(3, 'invalid_model')
        return
    end

    LoadModel(model)
    if not HasModelLoaded(model) then
        CloseAllNUI()
        Notif(3, 'loading_failed')
        return
    end

    if jobspawn then
        plate = GenerateRandomJobVehiclePlate(plate)
    end

    if (not jobspawn) or (jobspawn_owned) then
        if exports.cd_bridge:Callback('cd_garage:has_vehicle_already_spawned', data.plate, persistent)then
            print('^1[cd_garage] ^3Vehicle with plate '..plate..' has already been spawned! Aborting spawn.^0')
            CloseAllNUI()
            return
        end
    end

    local vehicle = CreateVehicle(model, ExitLocation.x, ExitLocation.y, ExitLocation.z, ExitLocation.h, true, false)
    SetVehicleNumberPlateText(vehicle, plate)

    -- network vehicle.
    EnsureNetworkControl(vehicle)
    RequestEntityCollision(vehicle)
    SetModelAsNoLongerNeeded(model)

    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    if tp_invehicle then
        SetPedIntoVehicle(ped, vehicle, -1)
    end
    SetVehicleDirtLevel(vehicle, 0.0)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehRadioStation(vehicle, 'OFF')
    NetworkFadeInEntity(vehicle, true)

    if not jobspawn then
        if props.fuelLevel == nil then
            props.fuelLevel = 100.0
        end

        SetVehicleProperties(vehicle, props)
        SetFuel(vehicle, plate, props.fuelLevel)

        if Config.Mileage.ENABLE and adv_stats then
            if adv_stats.mileage == nil then
                adv_stats.mileage = 0
            end
            if adv_stats.maxhealth == nil then
                adv_stats.maxhealth = 1000.0
            end
            if adv_stats.plate == nil then
                adv_stats.plate = plate
            end

            local max_health = GetMaxHealth(adv_stats.mileage)

            AdvStatsFunction(plate, adv_stats.mileage, max_health)

            if GetVehicleEngineHealth(vehicle) > max_health then
                SetVehicleEngineHealth(vehicle, max_health+0.0)
            end
        end
    end

    if Config.Mileage.ENABLE and not jobspawn then
        TriggerServerEvent('cd_garage:UpdateAdvStatsTable', plate, AdvStatsTable[plate])
    end

    TeleportVehicleToSafeCoords(vehicle, vector3(ExitLocation.x, ExitLocation.y, ExitLocation.z))
    VehicleSpawned(vehicle, plate, props, jobspawn and 'regular' or jobspawn_owned and 'owned' or nil)

    if jobspawn then
        SetFuel(vehicle, plate, 100.0)
        if data.spawn_max then
            SetVehicleMaxMods(vehicle)
        end
    end

    if jobspawn or jobspawn_owned then
        TriggerServerEvent('cd_garage:JobVehicleCacheKeys', plate, {model_string = GetDisplayNameFromVehicleModel(model):lower(), label = GetDefaultVehicleLabel(model)})
        if Config.JobVehicles.choose_liverys then
            SetLiverysThread()
        end
    end
    ExitLocation = nil
    return vehicle
end



function VehicleSpawned(vehicle, plate, props, job_vehicle) --This will be triggered when you spawn a vehicle.
    GiveVehicleKeys(plate, vehicle) -- in cd_bridge.
    RegisterPersistentVehicle(vehicle, plate, job_vehicle) -- in cd_bridge.
    TriggerServerEvent('cd_mechanic:OwnedVehicleSpawned', plate, NetworkGetNetworkIdFromEntity(vehicle)) -- in cd_mechanic statebags.lua, sets cache for owned vehicles when spawned.
    --Add your own code here if needed.
end

function VehicleStored(vehicle, plate, props) --This will be triggered just before a vehicle is stored.
    local ped = PlayerPedId()
    DespawnNetworkedVehicle(vehicle) -- in cd_bridge.
    TriggerServerEvent('cd_mechanic:OwnedVehicleStored', plate) -- in cd_mechanic server/statebags.lua.
    Notif(1, 'vehicle_stored')
    --Add your own code here if needed.
end