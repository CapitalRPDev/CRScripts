if true then return end
local gangZones = {}

function DeleteGarageTargetZone(id)
    print('deleting  '..id)
    exports['qb-target']:RemoveZone(id)
end

function CreateInsideGarageExit(shellDoorCoords)
    exports['qb-target']:AddCircleZone('garage_exit', vector3(shellDoorCoords.x, shellDoorCoords.y, shellDoorCoords.z+1), 5.0, {
        name = 'garage_exit',
        debugPoly = false,
        useZ = true
    }, {
    options = {
        {
            num = 1,
            type = "client",
            icon = "fa-solid fa-door-open",
            label = Locale('exit_garage'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:Exit')
            end,
            drawDistance = 10.0,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },
    },
    distance = 5.0
    })
end

function CreatePrivateGarageTargetZone(d)
    local index
    for k, v in pairs(Config.Locations) do
        if v.Garage_ID == d.Garage_ID then
            index = k
            break
        end
    end

    exports['qb-target']:AddCircleZone('garage_'..d.Garage_ID, vector3(d.x_1, d.y_1, d.z_1), d.Dist, {
        name = 'garage_'..d.Garage_ID,
        debugPoly = false,
        useZ = true
    }, {
    options = {
        {
            num = 1,
            type = "client",
            icon = "fa-solid fa-car",
            label = Locale('open_garage'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:EnterGarage_Outside', index)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 2,
            type = "client",
            icon = "fa-solid fa-warehouse",
            label = Locale('enter_garage'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:EnterGarage_Inside', index)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 3,
            type = "client",
            icon = "fa-solid fa-trash",
            label = Locale('store_vehicle'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 4,
            type = "client",
            icon = "fa-solid fa-handcuffs",
            label = Locale('garage_raid'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
            end,
            canInteract = function()
                return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255},
        }
    },
    distance = d.Dist
    })
end

for index, d in pairs(Config.Locations) do
    exports['qb-target']:AddCircleZone('garage_'..d.Garage_ID, vector3(d.x_1, d.y_1, d.z_1), d.Dist, {
        name = 'garage_'..d.Garage_ID,
        debugPoly = false,
        useZ = true
    }, {
    options = {
        {
            num = 1,
            type = "client",
            icon = "fa-solid fa-car",
            label = Locale('open_garage'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:EnterGarage_Outside', index)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 2,
            type = "client",
            icon = "fa-solid fa-warehouse",
            label = Locale('enter_garage'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:EnterGarage_Inside', index)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 3,
            type = "client",
            icon = "fa-solid fa-trash",
            label = Locale('store_vehicle'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255}
        },

        {
            num = 4,
            type = "client",
            icon = "fa-solid fa-handcuffs",
            label = Locale('garage_raid'),
            targeticon = "fa-solid fa-car",
            action = function()
                TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
            end,
            canInteract = function()
                return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
            end,
            drawDistance = d.Dist*2,
            drawColor = {255, 255, 255, 255},
            successDrawColor = {0, 255, 0, 255},
        }
    },
    distance = d.Dist
    })
end

if Config.Impound.ENABLE then
    for _, d in pairs(Config.ImpoundLocations) do
        exports['qb-target']:AddCircleZone('impound_'..d.ImpoundID, vector3(d.coords.x, d.coords.y, d.coords.z), 10.0, {
            name = 'impound_'..d.ImpoundID,
            debugPoly = false,
            useZ = true
        }, {
        options = {
            {
                num = 1,
                type = "client",
                icon = "fa-solid fa-car",
                label = Locale('impound'),
                targeticon = "fa-solid fa-car",
                action = function()
                    OpenImpound(d.ImpoundID)
                end,
                canInteract = function()
                    return IsAllowed_Impound()
                end,
                drawDistance = 20.0,
                drawColor = {255, 255, 255, 255},
                successDrawColor = {0, 255, 0, 255}
            },
        },
        distance = 10.0
        })
    end
end

if Config.JobVehicles.ENABLE then
    for c, d in pairs(Config.JobVehicles.Locations) do
        for cc, dd in pairs(d) do
            exports['qb-target']:AddCircleZone('job_garage:'..c..' - '..cc, vector3(dd.coords.x, dd.coords.y, dd.coords.z), dd.distance, {
                name = 'job_garage:'..c..' - '..cc,
                debugPoly = false,
                useZ = true
            }, {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = "fa-solid fa-car",
                    label = Locale('open_garage'),
                    targeticon = "fa-solid fa-car",
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
                    end,
                    drawDistance = dd.distance*2,
                    drawColor = {255, 255, 255, 255},
                    successDrawColor = {0, 255, 0, 255}
                },

                {
                    num = 2,
                    type = "client",
                    icon = "fa-solid fa-car",
                    label = Locale('store_vehicle'),
                    targeticon = "fa-solid fa-trash",
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
                    end,
                    drawDistance = dd.distance*2,
                    drawColor = {255, 255, 255, 255},
                    successDrawColor = {0, 255, 0, 255}
                },
            },
            distance = dd.distance
            })
        end
    end
end

if Config.GangGarages.ENABLE then
    function CreateGangGarageTargetZone(gang)
        gangZones[gang.garage_id] = true
        exports['qb-target']:AddCircleZone('garage_'..gang.garage_id, vector3(gang.coords.x, gang.coords.y, gang.coords.z), gang.distance, {
            name = 'garage_'..gang.garage_id,
            debugPoly = false,
            useZ = true
        }, {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = "fa-solid fa-car",
                    label = Locale('open_garage'),
                    targeticon = "fa-solid fa-car",
                    action = function()
                        local gangName = GetGangName()
                        if gangName and gangName == gang.gang then
                            TriggerEvent('cd_garage:GangGarageSpawn', gang.garage_type, gang.spawn_coords, gang.garage_id)
                        else
                            Notif(3, 'no_permissions')
                        end
                    end,
                    drawDistance = gang.distance * 2,
                    drawColor = {255, 255, 255, 255},
                    successDrawColor = {0, 255, 0, 255}
                },
                {
                    num = 2,
                    type = "client",
                    icon = "fa-solid fa-trash",
                    label = Locale('store_vehicle'),
                    targeticon = "fa-solid fa-car",
                    action = function()
                        local gang = GetGangName()
                        if gang and gang == gang.gang then
                            TriggerEvent('cd_garage:StoreVehicle_Main', false, false, dd)
                        else
                            Notif(3, 'no_permissions')
                        end
                    end,
                    drawDistance = gang.distance * 2,
                    drawColor = {255, 255, 255, 255},
                    successDrawColor = {0, 255, 0, 255}
                },
            },
            distance = gang.distance
        })
    end

     function DeleteAllGangGarageTargetZones()
        for id, _ in pairs(gangZones) do
            DeleteGarageTargetZone('garage_'..id)
            gangZones[id] = nil
        end
    end

end