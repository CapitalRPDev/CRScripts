if Config.GarageInteractMethod ~= 'ox_target' then return end

local gangZones = {}

function DeleteGarageTargetZone(id)
    exports.ox_target:removeZone(id)
end

function CreateInsideGarageExit(shellDoorCoords)
    exports.ox_target:addSphereZone({
        coords = vector3(shellDoorCoords.x, shellDoorCoords.y, shellDoorCoords.z+1),
        name = 'garage_exit',
        radius = 5.0,
        debug = false,
        drawSprite = false,
        options = {
            {
                label = Locale('exit_garage'),
                name = 'exit_garage',
                icon = 'fa-solid fa-door-open',
                iconColor = 'orange',
                distance = 10.0,
                onSelect = function()
                    TriggerEvent('cd_garage:Exit')
                end
            }
        },
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

    exports.ox_target:addSphereZone({
        coords = vector3(d.x_1, d.y_1, d.z_1),
        name = 'garage_'..d.Garage_ID,
        radius = d.Dist,
        debug = false,
        drawSprite = false,
        options = {
            {
                label = Locale('open_garage'),
                name = 'open_garage',
                icon = 'fa-solid fa-car',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function(data)
                    TriggerEvent('cd_garage:EnterGarage_Outside', index)
                end
            },

            {
                label = Locale('enter_garage'),
                name = 'enter_garage',
                icon = 'fa-solid fa-warehouse',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:EnterGarage_Inside', index)
                end,
                canInteract = function()
                    return Config.InsideGarage.ENABLE
                end,
            },

            {
                label = Locale('store_vehicle'),
                name = 'store_vehicle',
                icon = 'fa-solid fa-trash',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                end
            },

            {
                label = Locale('garage_raid'),
                name = 'store_vehicle',
                icon = 'fa-solid fa-handcuffs',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
                end,
                canInteract = function()
                    return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
                end,
            }
        },
    })
end

for index, d in pairs(Config.Locations) do
    exports.ox_target:addSphereZone({
        coords = vector3(d.x_1, d.y_1, d.z_1),
        name = 'garage_'..d.Garage_ID,
        radius = d.Dist,
        debug = false,
        drawSprite = false,
        options = {
            {
                label = Locale('open_garage'),
                name = 'open_garage',
                icon = 'fa-solid fa-car',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function(data)
                    TriggerEvent('cd_garage:EnterGarage_Outside', index)
                end
            },

            {
                label = Locale('enter_garage'),
                name = 'enter_garage',
                icon = 'fa-solid fa-warehouse',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:EnterGarage_Inside', index)
                end,
                canInteract = function()
                    return Config.InsideGarage.ENABLE
                end,
            },

            {
                label = Locale('store_vehicle'),
                name = 'store_vehicle',
                icon = 'fa-solid fa-trash',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                end
            },

            {
                label = Locale('garage_raid'),
                name = 'store_vehicle',
                icon = 'fa-solid fa-handcuffs',
                iconColor = 'orange',
                distance = d.Dist*2,
                onSelect = function()
                    TriggerEvent('cd_garage:GarageRaid', d.Garage_ID)
                end,
                canInteract = function()
                    return not d.ImpoundName and Config.GarageRaid.ENABLE and HasGarageRaidingPerms()
                end,
            }
        },

    })
end

if Config.Impound.ENABLE then
    for _, d in pairs(Config.ImpoundLocations) do
        exports.ox_target:addSphereZone({
            coords = vector3(d.coords.x, d.coords.y, d.coords.z),
            name = 'impound_'..d.ImpoundID,
            radius = 10.0,
            debug = false,
            drawSprite = false,
            options = {
                {
                    label = Locale('impound'),
                    name = 'impound',
                    icon = 'fa-solid faa-warehouse',
                    iconColor = 'orange',
                    distance = 20.0,
                    onSelect = function()
                        OpenImpound(d.ImpoundID)
                    end,
                    canInteract = function()
                        return IsAllowed_Impound()
                    end,
                }
            },

        })
    end
end

if Config.JobVehicles.ENABLE then
    for c, d in pairs(Config.JobVehicles.Locations) do
        for cc, dd in pairs(d) do
            exports.ox_target:addSphereZone({
                coords = vector3(dd.coords.x, dd.coords.y, dd.coords.z),
                name = 'job_garage:'..c..' - '..cc,
                radius = dd.distance,
                debug = false,
                drawSprite = false,
                options = {
                    {
                        label = Locale('open_garage'),
                        name = 'open_job_garage',
                        icon = 'fa-solid fa-car',
                        iconColor = 'orange',
                        distance = dd.distance*2,
                        onSelect = function()
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
                    },

                    {
                        label = Locale('store_vehicle'),
                        name = 'store_vehicle',
                        icon = 'fa-solid fa-trash',
                        iconColor = 'orange',
                        distance = dd.distance*2,
                        onSelect = function()
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
                    }
                },
            })
        end
    end
end

if Config.GangGarages.ENABLE then
    function CreateGangGarageTargetZone(gang)
        gangZones[gang.garage_id] = true
        exports.ox_target:addSphereZone({
            coords = vector3(gang.coords.x, gang.coords.y, gang.coords.z),
            name = 'garage_'..gang.garage_id,
            radius = gang.distance,
            debug = false,
            drawSprite = false,

            options = {

                {
                    label = Locale('open_garage'),
                    name = 'open_gang_garage',
                    icon = 'fa-solid fa-car',
                    iconColor = 'orange',
                    distance = gang.distance * 2,

                    onSelect = function()
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
                    name = 'store_gang_vehicle',
                    icon = 'fa-solid fa-trash',
                    iconColor = 'orange',
                    distance = gang.distance * 2,

                    onSelect = function()
                        local gang = GetGangName()
                        if gang and gang == dd.gang then
                            TriggerEvent('cd_garage:StoreVehicle_Main', false, false, dd)
                        else
                            Notif(3, 'no_permissions')
                        end
                    end
                },

            }
        })
    end

    function DeleteAllGangGarageTargetZones()
        for id, _ in pairs(gangZones) do
            DeleteGarageTargetZone('garage_'..id)
            gangZones[id] = nil
        end
    end

end