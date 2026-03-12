

local function Normalize(v)
    local len = math.sqrt( (v.x * v.x)+(v.y * v.y)+(v.z * v.z) )
    return vector3(v.x / len, v.y / len, v.z / len)
end

function DrawSpotlight(pos)
    local lightPos = vector3(pos.x,pos.y,pos.z + 5.0)
    local direction = pos - lightPos
    local normal = Normalize(direction)
    DrawSpotLight(lightPos.x,lightPos.y,lightPos.z, normal.x,normal.y,normal.z, 255,255,255, 100.0, 10.0, 0.0, 25.0, 1.0)
end

function Draw2DText(text)
    SetTextFont(4)
    SetTextScale(0.0, 0.4)
    SetTextColour(255, 255, 255, 150)
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.9)
end

function DrawLiveryText(text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry('STRING')
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(0.5, 0.05)
end

function GenerateSpacesInPlate(new_plate)
    local ws = ' '
    if #new_plate ~= 8 then
        if #new_plate == 7 then
            return new_plate..''..ws
        elseif #new_plate == 6 then
            return ws..''..new_plate..''..ws
        elseif #new_plate == 5 then
            return ws..''..ws..''..new_plate..''..ws
        elseif #new_plate == 4 then
            return ws..''..ws..''..new_plate..''..ws..''..ws
        elseif #new_plate == 3 then
            return ws..''..ws..''..new_plate..''..ws..''..ws..''..ws
        elseif #new_plate == 2 then
            return ws..''..ws..''..ws..''..new_plate..''..ws..''..ws..''..ws
        elseif #new_plate == 1 then
            return ws..''..ws..''..ws..''..ws..''..new_plate..''..ws..''..ws..''..ws
        end
    else
        return new_plate
    end
end

function OpenTextBox(generate_whitespaces)
    AddTextEntry('FMMC_KEY_TIP8s', Locale('enter_plate'))
    DisplayOnscreenKeyboard(false, 'FMMC_KEY_TIP8s', '', '', '', '', '', 8)
    while UpdateOnscreenKeyboard() == 0 do DisableAllControlActions(0) Wait(0) end
    if GetOnscreenKeyboardResult() then
        local result = GetOnscreenKeyboardResult()
        if result and (#result > 0 and #result <= 8) then
            local plate = string.gsub(GetCorrectPlateFormat(result:upper()), "^%s*(.-)%s*$", "%1")
            if Config.VehiclePlateFormats.format == 'with_spaces' and #plate ~= 8 and generate_whitespaces then
                return GenerateSpacesInPlate(plate)
            else
                return plate
            end
        end
    else
        return nil
    end
end

function JobRestrictNotif(tbl)
    local text = ''
    for _, d in ipairs(tbl) do
        text = text..' '..d..','
    end
    text = text:sub(1, -2):sub(2)
    Notif(3, 'job_restricted', text)
end

function UsingTarget()
    return Config.GarageInteractMethod == 'qb-target' or Config.GarageInteractMethod == 'ox_target'
end

RegisterNetEvent('cd_garage:Cooldown', function(time)
    CooldownActive = true
    Wait(time)
    CooldownActive = false
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        local ped = PlayerPedId()
        --ClearPedTasks(ped)
        --ClearPedTasksImmediately(ped)
        DrawTextUI('hide')
        if MyCars ~= nil then
            for cd=1, #MyCars do
                if MyCars[cd] ~= nil then
                    SetEntityAsNoLongerNeeded(MyCars[cd].vehicle)
                    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle))
                    DeleteEntity(MyCars[cd].vehicle)
                    DeleteVehicle(MyCars[cd].vehicle)
                end
            end
        end
        if GaragePeds and #GaragePeds > 0 then
            for _, cd in pairs(GaragePeds) do
                if DoesEntityExist(cd.ped) then
                    SetEntityAsNoLongerNeeded(cd.ped)
                    DeleteEntity(cd.ped)
                end
            end
        end
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        if shell and Config.InsideGarage.ENABLE then
            DeleteGarage()
        end
    end
end)


-- will be moved to cd_bridge soon.
local LoadingDots = {}
LoadingDots.Dot, LoadingDots.Timer = '.', 0

function AddWaitingDots()
    LoadingDots.Timer = LoadingDots.Timer+1
    if LoadingDots.Timer == 50 then
        if LoadingDots.Dot == '.' then
            LoadingDots.Dot = '..'
        elseif LoadingDots.Dot == '..' then
            LoadingDots.Dot = '...'
        elseif LoadingDots.Dot == '...' then
            LoadingDots.Dot = '.'
        end
        LoadingDots.Timer = 0
        return LoadingDots.Dot
    else
        return LoadingDots.Dot
    end
end

-- will be moved to cd_bridge soon.
function LoadModel(model)
    LoadingDots.Timer = 0
    if not HasModelLoaded(model) and IsModelInCdimage(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
            Draw2DText(Locale('loading_model')..' : '..GetDefaultVehicleLabel(model)..' '..AddWaitingDots())
        end
    end
end

-- will be moved to cd_bridge soon.
function RegisterEntity(vehicle)
    timeout = 0
    LoadingDots.Timer = 0
    while not DoesEntityExist(vehicle) and timeout <= 1000 do 
        Wait(0)
        Draw2DText(Locale('registering_entity')..' '..AddWaitingDots())
    end
    if not DoesEntityExist(vehicle) then
        DespawnNetworkedVehicle(vehicle)
        Notif(3, 'registering_entity_failed')
    end
end

-- will be moved to cd_bridge soon.
function RequestNetworkControl(vehicle)
    timeout = 0
    LoadingDots.Timer = 0
    while not NetworkHasControlOfEntity(vehicle) and timeout <= 1000 do 
        Wait(0)
        NetworkRequestControlOfEntity(vehicle)
        Draw2DText(Locale('registering_network')..' '..AddWaitingDots())
    end
    if not NetworkHasControlOfEntity(vehicle) then
        DespawnNetworkedVehicle(vehicle)
        Notif(3, 'registering_network_failed')
    end
end

-- will be moved to cd_bridge soon.
function RegisterEntityNetworked(vehicle)
    timeout = 0
    LoadingDots.Timer = 0
    while not NetworkGetEntityIsNetworked(vehicle) and timeout <= 1000 do 
        Wait(0)
        NetworkRegisterEntityAsNetworked(vehicle)
        Draw2DText(Locale('registering_entitynetwork')..' '..AddWaitingDots())
    end
    if not NetworkGetEntityIsNetworked(vehicle) then
        DespawnNetworkedVehicle(vehicle)
        Notif(3, 'registering_entitynetwork_failed')
    end
end

-- will be moved to cd_bridge soon.
function RequestNetworkId(vehicle)
    local timeout = 0
    LoadingDots.Timer = 0
    local netID = NetworkGetNetworkIdFromEntity(vehicle)
    while not NetworkHasControlOfNetworkId(netID) and timeout <= 1000 do 
        Wait(0)
        NetworkRequestControlOfNetworkId(netID)
        Draw2DText(Locale('requesting_netid')..AddWaitingDots())
    end
end

-- will be moved to cd_bridge soon.
function RequestCollision(coords, vehicle)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(vehicle) do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
    end
end

-- will be moved to cd_bridge soon.
function Teleport(ped, x, y, z, h, freeze)
    RequestEntityCollision(ped, vector3(x, y, z))
    DoScreenFadeOut(950)
    Wait(1000)
    SetEntityCoords(ped, x, y, z)
    SetEntityHeading(ped, h)
    if freeze then
        FreezeEntityPosition(ped, true)
    end
    Wait(1000)
    DoScreenFadeIn(3000)
end