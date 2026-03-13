if Config.GarageInteractMethod ~= 'textui' then return end

local function UpdateTextUIState(state, inZone, text)
    local pauseActive = IsPauseMenuActive()

    if not state.pausemenuopen and pauseActive then
        state.pausemenuopen = true
        DrawTextUI('hide')
    elseif state.pausemenuopen and not pauseActive then
        state.pausemenuopen = false
        if inZone and text then
            DrawTextUI('show', text)
        end
    end

    if not state.pausemenuopen then
        if inZone and not state.alreadyEnteredZone then
            state.alreadyEnteredZone = true
            if text then
                DrawTextUI('show', text)
            end
        end

        if inZone and text and text ~= state.GlobalText_last then
            DrawTextUI('show', text)
        end

        if not inZone and state.alreadyEnteredZone then
            state.alreadyEnteredZone = false
            DrawTextUI('hide')
        end
    end

    state.GlobalText_last = text
    return state
end

--Public Garages
CreateThread(function()
    local ui = {
        pausemenuopen = false,
        alreadyEnteredZone = false,
        GlobalText_last = nil,
    }

    local garageRaidConfig = Config.GarageRaid.ENABLE

    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inZone = false
        local text = nil
        local canRaidGarage = garageRaidConfig and HasGarageRaidingPerms()

        for cd = 1, #Config.Locations do
            local self = Config.Locations[cd]
            local dist = #(coords - vector3(self.x_1, self.y_1, self.z_1))
            if dist <= self.Dist then
                wait = 5
                inZone = true
                text = self.Name

                if canRaidGarage and not self.ImpoundName then
                    text = text..'</p>'..Locale('notif_garage_raid')
                end
                if InVehicle() then
                    text = '<b>'..Locale('garage')..'</b></p>'..Locale('notif_storevehicle')
                end

                if not CooldownActive then
                    if IsControlJustReleased(0, Config.Keys.QuickChoose_Key) then
                        TriggerEvent('cd_garage:EnterGarage_Outside', cd)
                    elseif IsControlJustReleased(0, Config.Keys.EnterGarage_Key) and self.EventName2 == 'cd_garage:EnterGarage' then
                        TriggerEvent('cd_garage:EnterGarage_Inside', cd)
                    elseif IsControlJustReleased(0, Config.Keys.StoreVehicle_Key) then
                        TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                    elseif IsControlJustReleased(0, Config.Keys.GarageRaid_Key) and canRaidGarage and not self.ImpoundName then
                        TriggerEvent('cd_garage:GarageRaid', self.Garage_ID)
                    end
                end

                break
            end
        end

        ui = UpdateTextUIState(ui, inZone, text)
        Wait(wait)
    end
end)


if Config.JobVehicles.ENABLE then
    --Job Garage
    if Config.JobVehicles.ENABLE then
        CreateThread(function()
            local ui = {
                pausemenuopen = false,
                alreadyEnteredZone = false,
                GlobalText_last = nil,
            }

            while true do
                local wait = 5000
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local job = GetJobName()
                local inZone = false
                local text = nil

                if Config.JobVehicles.Locations[job] ~= nil and GetJobDuty() then
                    wait = 1000

                    for cd = 1, #Config.JobVehicles.Locations[job] do
                        local self = Config.JobVehicles.Locations[job][cd]
                        local dist = #(coords - vector3(self.coords.x, self.coords.y, self.coords.z))
                        if dist <= self.distance then
                            wait = 5
                            inZone = true

                            if InVehicle() then
                                text = '<b>'..Locale('job_garage')..'</b></p>'..Locale('notif_storevehicle')
                            else
                                text = '<b>'..Locale('job_garage')..'</b></p>'..Locale('open_garage_1')..'</p>'..Locale('notif_storevehicle')
                            end

                            if not CooldownActive then
                                if IsControlJustReleased(0, Config.Keys.QuickChoose_Key) then
                                    if not InVehicle() then
                                        TriggerEvent('cd_garage:Cooldown', 3000)
                                        if self.method == 'societyowned' then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'owned', job, self.garage_type, true, self.spawn_coords)
                                        elseif self.method == 'personalowned' then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'owned', job, self.garage_type, false, self.spawn_coords)
                                        elseif self.method == 'regular' and Config.JobVehicles.RegularMethod[job] then
                                            TriggerEvent('cd_garage:JobVehicleSpawn', 'not_owned', job, self.garage_type, Config.JobVehicles.RegularMethod[job], self.spawn_coords)
                                        end
                                    else
                                        Notif(3, 'get_out_veh')
                                    end
                                elseif IsControlJustReleased(0, Config.Keys.StoreVehicle_Key) then
                                    TriggerEvent('cd_garage:Cooldown', 1000)
                                    if self.method == 'societyowned' then
                                        TriggerEvent('cd_garage:StoreVehicle_Main', false, job, false)
                                    elseif self.method == 'personalowned' then
                                        TriggerEvent('cd_garage:StoreVehicle_Main', false, false, false)
                                    elseif self.method == 'regular' then
                                        local vehicle = GetClosestVehicleToPlayer(5)
                                        if self.garage_type == 'boat' then
                                            TeleportEntity(ped, self.coords)
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
                                end
                            end

                            break
                        end
                    end
                else
                    if ui.alreadyEnteredZone then
                        ui.alreadyEnteredZone = false
                        ui.pausemenuopen = false
                        ui.GlobalText_last = nil
                        DrawTextUI('hide')
                    end
                end

                ui = UpdateTextUIState(ui, inZone, text)
                Wait(wait)
            end
        end)
    end
end

if Config.GangGarages.ENABLE then
    --Gang Garage
    if Config.GangGarages.ENABLE then
        CreateThread(function()
            Wait(3000)
            if not IsPlayerInAnyGang() then

                local ui = {
                    pausemenuopen = false,
                    alreadyEnteredZone = false,
                    GlobalText_last = nil,
                }

                while true do
                    local wait = 5000
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    local gang_name = GetGangName()
                    local inZone = false
                    local text = nil
                    local valid_gang_garage = false

                    for cd = 1, #Config.GangGarages.Locations do
                        local self = Config.GangGarages.Locations[cd]
                        if self.gang == gang_name then
                            valid_gang_garage = true
                            local dist = #(coords - vector3(self.coords.x, self.coords.y, self.coords.z))
                            if dist <= self.distance then
                                wait = 5
                                inZone = true

                                if InVehicle() then
                                    text = '<b>'..Locale('gang_garage')..'</b></p>'..Locale('notif_storevehicle')
                                else
                                    text = '<b>'..Locale('gang_garage')..'</b></p>'..Locale('open_garage_1')..'</p>'..Locale('notif_storevehicle')
                                end

                                if not CooldownActive then
                                    if IsControlJustReleased(0, Config.Keys.QuickChoose_Key) then
                                        if not InVehicle() then
                                            TriggerEvent('cd_garage:Cooldown', 3000)
                                            TriggerEvent('cd_garage:GangGarageSpawn', self.garage_type, self.spawn_coords, self.garage_id)
                                        else
                                            Notif(3, 'get_out_veh')
                                        end
                                    elseif IsControlJustReleased(0, Config.Keys.StoreVehicle_Key) then
                                        TriggerEvent('cd_garage:Cooldown', 1000)
                                        TriggerEvent('cd_garage:StoreVehicle_Main', false, false, self)
                                    end
                                end

                                break
                            else
                                wait = 1000
                            end
                        end
                    end

                    if not valid_gang_garage and ui.alreadyEnteredZone then
                        ui.alreadyEnteredZone = false
                        ui.pausemenuopen = false
                        ui.GlobalText_last = nil
                        DrawTextUI('hide')
                    end

                    ui = UpdateTextUIState(ui, inZone, text)
                    Wait(wait)
                end
            end
        end)
    end
end
if Config.PropertyGarages.ENABLE then
    CreateThread(function()
        local ui = {
            pausemenuopen = false,
            alreadyEnteredZone = false,
            GlobalText_last = nil,
        }

        while true do
            local wait = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local inZone = false
            local text = nil

            if next(HouseGarages) and hasGarageKey then
                for _, d in pairs(HouseGarages) do
                    if d.takeVehicle.x and d.takeVehicle.y and d.takeVehicle.z then
                        local dist = #(coords - vector3(d.takeVehicle.x, d.takeVehicle.y, d.takeVehicle.z))
                        if dist <= 5.0 then
                            wait = 5
                            inZone = true

                            if InVehicle() then
                                text = '<b>'..Locale('garage')..'</b></p>'..Locale('notif_storevehicle')
                            else
                                text = '<b>'..Locale('garage')..'</b></p>'..Locale('open_garage_1')..'</p>'..Locale('open_garage_2')..'</p>'..Locale('notif_storevehicle')
                            end

                            if not CooldownActive then
                                if IsControlJustReleased(0, Config.Keys.QuickChoose_Key) then
                                    TriggerEvent('cd_garage:PropertyGarage', 'quick', nil)
                                elseif IsControlJustReleased(0, Config.Keys.EnterGarage_Key) then
                                    TriggerEvent('cd_garage:PropertyGarage', 'inside', nil)
                                elseif IsControlJustReleased(0, Config.Keys.StoreVehicle_Key) then
                                    TriggerEvent('cd_garage:StoreVehicle_Main', 1, false, false)
                                end
                            end

                            break
                        end
                    end
                end
            else
                if ui.alreadyEnteredZone then
                    ui.alreadyEnteredZone = false
                    ui.pausemenuopen = false
                    ui.GlobalText_last = nil
                    DrawTextUI('hide')
                end
            end

            ui = UpdateTextUIState(ui, inZone, text)
            Wait(wait)
        end
    end)
end

if Config.Impound.ENABLE then
    --Impound
    CreateThread(function()
        local ui = {
            pausemenuopen = false,
            alreadyEnteredZone = false,
            GlobalText_last = nil,
        }

        local Dist = 5
        local impoundText = '<b>'..Locale('impound')..'</b></p>'..Locale('open_impound')

        while true do
            local wait = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            local inZone = false
            local text = nil

            for _, d in pairs(Config.ImpoundLocations) do
                local dist = #(coords - vector3(d.coords.x, d.coords.y, d.coords.z))

                if dist <= Dist then
                    wait = 5
                    inZone = true
                    text = impoundText

                    if not CooldownActive then
                        if IsControlJustReleased(0, Config.Keys.QuickChoose_Key) then
                            OpenImpound(d.ImpoundID)
                        end
                    end

                    break
                end
            end

            ui = UpdateTextUIState(ui, inZone, text)
            Wait(wait)
        end
    end)
end
