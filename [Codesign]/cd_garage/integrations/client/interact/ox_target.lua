if Config.GarageInteractMethod ~= 'target' then return end

print("^2OX_TARGET FILE RUNNING^7")

local gangZones = {}

function DeleteGarageTargetZone(id)
    exports['CInteraction']:removeZone(id)
end

function CreateInsideGarageExit(shellDoorCoords)
    exports['CInteraction']:createZone(
        vector3(shellDoorCoords.x, shellDoorCoords.y, shellDoorCoords.z + 1),
        vector3(5.0, 5.0, 5.0),
        {
            id = 'garage_exit',
            hideOnSelect = true,
            prompts = {
                {
                    label = Locale('exit_garage'),
                    sublabel = 'Leave this garage',
                    icon = 'fa-solid fa-door-open',
                    action = function()
                        TriggerEvent('cd_garage:Exit')
                    end
                }
            }
        }
    )
end

function CreatePrivateGarageTargetZone(d)
    local index
    for k, v in pairs(Config.Locations) do
        if v.Garage_ID == d.Garage_ID then
            index = k
            break
        end
    end

    exports['CInteraction']:createZone(
        vector3(d.x_1, d.y_1, d.z_1),
        vector3(d.Dist, d.Dist, d.Dist),
        {
            id = 'garage_' .. d.Garage_ID,
            hideOnSelect = true,
            prompts = {
                {
                    label = Locale('open_garage'),
                    sublabel = 'Browse available vehicles',
                    icon = 'fa-solid fa-car',
                    action = function()
                        TriggerEvent('cd_garage:EnterGarage_Outside', index)
                    end
                },
                {
                    label = Locale('enter_garage'),
                    sublabel = 'Go inside the garage',
                    icon = 'fa-solid fa-warehouse',
                    action = function()
                        TriggerEvent('cd_garage:EnterGarage_Inside', index)
                    end,
                    canInteract = function()
                        return Config.InsideGarage.ENABLE
                    end
                },
                {
                    label = Locale('store_vehicle'),
                    sublabel = 'Store your current vehicle',
                    icon = 'fa-solid fa-trash',
                    action = function()
                        TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                    end
                },
                {
                    label = Locale('garage_raid'),
                    sublabel = 'Raid this garage',
                    icon = 'fa-solid fa-handcuffs',
                    action = function()
                        TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
                    end,
                    canInteract = function()
                        return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
                    end
                }
            }
        }
    )
end

CreateThread(function()
    print("^2THREAD RUNNING, LOCATIONS COUNT: " .. tostring(#Config.Locations) .. "^7")
    for index, d in pairs(Config.Locations) do
        print("^2CREATING ZONE FOR: " .. tostring(d.Garage_ID) .. "^7")
        exports['CInteraction']:createZone(
            vector3(d.x_1, d.y_1, d.z_1),
            vector3(d.Dist, d.Dist, d.Dist),
            {
                id = 'garage_' .. d.Garage_ID,
                hideOnSelect = true,
                prompts = {
                    {
                        label = Locale('open_garage'),
                        sublabel = 'Browse available vehicles',
                        icon = 'fa-solid fa-car',
                        action = function()
                            TriggerEvent('cd_garage:EnterGarage_Outside', index)
                        end
                    },
                    {
                        label = Locale('enter_garage'),
                        sublabel = 'Go inside the garage',
                        icon = 'fa-solid fa-warehouse',
                        action = function()
                            TriggerEvent('cd_garage:EnterGarage_Inside', index)
                        end,
                        canInteract = function()
                            return Config.InsideGarage.ENABLE
                        end
                    },
                    {
                        label = Locale('store_vehicle'),
                        sublabel = 'Store your current vehicle',
                        icon = 'fa-solid fa-trash',
                        action = function()
                            TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                        end
                    },
                    {
                        label = Locale('garage_raid'),
                        sublabel = 'Raid this garage',
                        icon = 'fa-solid fa-handcuffs',
                        action = function()
                            TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
                        end,
                        canInteract = function()
                            return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
                        end
                    }
                }
            }
        )
    end
end)

if Config.Impound.ENABLE then
    CreateThread(function()
        for _, d in pairs(Config.ImpoundLocations) do
            exports['CInteraction']:createZone(
                vector3(d.coords.x, d.coords.y, d.coords.z),
                vector3(10.0, 10.0, 10.0),
                {
                    id = 'impound_' .. d.ImpoundID,
                    hideOnSelect = true,
                    prompts = {
                        {
                            label = Locale('impound'),
                            sublabel = 'Open the impound menu',
                            icon = 'fa-solid fa-warehouse',
                            action = function()
                                OpenImpound(d.ImpoundID)
                            end,
                            canInteract = function()
                                return IsAllowed_Impound()
                            end
                        }
                    }
                }
            )
        end
    end)
end

if Config.JobVehicles.ENABLE then
    CreateThread(function()
        for c, d in pairs(Config.JobVehicles.Locations) do
            for cc, dd in pairs(d) do
                exports['CInteraction']:createZone(
                    vector3(dd.coords.x, dd.coords.y, dd.coords.z),
                    vector3(dd.distance, dd.distance, dd.distance),
                    {
                        id = 'job_garage:' .. c .. ' - ' .. cc,
                        hideOnSelect = true,
                        prompts = {
                            {
                                label = Locale('open_garage'),
                                sublabel = 'Access job vehicles',
                                icon = 'fa-solid fa-car',
                                action = function()
                                    local job = GetJobName()
                                    local hasJob = HasJob(job)
                                    if hasJob then
                                        if dd.method == 'societyowned' then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'owned', job, dd.garage_type, true, dd.spawn_coords)
                                        elseif dd.method == 'personalowned' then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'owned', job, dd.garage_type, false, dd.spawn_coords)
                                        elseif dd.method == 'regular' then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'not_owned', job, dd.garage_type, Config.JobVehicles.RegularMethod[job], dd.spawn_coords)
                                        end
                                    else
                                        Notif(3, 'no_permissions')
                                    end
                                end,
                                canInteract = function()
                                    return HasJob(c)
                                end
                            },
                            {
                                label = Locale('store_vehicle'),
                                sublabel = 'Store your job vehicle',
                                icon = 'fa-solid fa-trash',
                                action = function()
                                    local ped = PlayerPedId()
                                    local job = GetJobName()
                                    if dd.method == 'societyowned' then
                                        TriggerEvent('cd_garage:StoreVehicle_Main', false, job, false)
                                    elseif dd.method == 'personalowned' then
                                        TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                                    elseif dd.method == 'regular' then
                                        local vehicle = GetClosestVehicleToPlayer(5)
                                        if dd.garage_type == 'boat' then
                                            TeleportEntity(ped, dd.coords)
                                        end
                                        if vehicle then
                                            if IsPedInVehicle(ped, vehicle, true) then
                                                TaskLeaveVehicle(ped, vehicle, 0)
                                                while IsPedInVehicle(ped, vehicle, true) do
                                                    Wait(0)
                                                end
                                            end
                                            DespawnNetworkedVehicle(vehicle)
                                            Notif(1, 'vehicle_stored')
                                        else
                                            Notif(3, 'no_vehicle_found')
                                        end
                                    end
                                end,
                                canInteract = function()
                                    return HasJob(c)
                                end
                            }
                        }
                    }
                )
            end
        end
    end)
end

if Config.GangGarages.ENABLE then
    function CreateGangGarageTargetZone(gang)
        gangZones[gang.garage_id] = true
        exports['CInteraction']:createZone(
            vector3(gang.coords.x, gang.coords.y, gang.coords.z),
            vector3(gang.distance, gang.distance, gang.distance),
            {
                id = 'garage_' .. gang.garage_id,
                hideOnSelect = true,
                prompts = {
                    {
                        label = Locale('open_garage'),
                        sublabel = 'Access gang vehicles',
                        icon = 'fa-solid fa-car',
                        action = function()
                            local gangName = GetGangName()
                            if gangName and gangName == gang.gang then
                                TriggerEvent('cd_garage:GangGarageSpawn', gang.garage_type, gang.spawn_coords, gang.garage_id)
                            else
                                Notif(3, 'no_permissions')
                            end
                        end
                    },
                    {
                        label = Locale('store_vehicle'),
                        sublabel = 'Store a gang vehicle',
                        icon = 'fa-solid fa-trash',
                        action = function()
                            local gangName = GetGangName()
                            if gangName and gangName == gang.gang then
                                TriggerEvent('cd_garage:StoreVehicle_Main', false, false, gang)
                            else
                                Notif(3, 'no_permissions')
                            end
                        end
                    }
                }
            }
        )
    end

    function DeleteAllGangGarageTargetZones()
        for id, _ in pairs(gangZones) do
            DeleteGarageTargetZone('garage_' .. id)
            gangZones[id] = nil
        end
    end
end