-- server callback (client calls server and waits for response)
local ROUTES = {}

function RegisterServerCallback(action, fn)
    ROUTES[action] = fn
end

RegisterNetEvent('cd_bridge:Callback', function(id, action, ...)
    local src = source
    local handler = ROUTES[action]
    local function respond(success, data, error_message)
        TriggerClientEvent('cd_bridge:Callback', src, id, success, data, error_message)
    end

    if not handler then
        respond(false, nil, 'callback_not_registered')
        return
    end

    local ok_exec, result = pcall(handler, src, ...)
    if not ok_exec then
        respond(false, nil, ('error_in_handler - %s'):format(result))
    else
        respond(true, result, nil)
    end
end)

-- client callback (server calls client and waits for response)
local CB_SEQ = 0
local PENDING = {}

RegisterNetEvent('cd_bridge:ClientCallback')
AddEventHandler('cd_bridge:ClientCallback', function(id, success, data, error_message)
    local entry = PENDING[id]
    if not entry then return end
    if entry.cancel then entry.cancel() end

    PENDING[id] = nil
    entry.promise:resolve({ success = success, data = data, error_message = error_message })
end)

local function setTimeout(ms, fn)
    local active = true
    CreateThread(function()
        local start = GetGameTimer()
        while active and (GetGameTimer() - start) < ms do
            Wait(0)
        end
        if active then fn() end
    end)
    return function() active = false end
end

function Callback(action, source, ...)
    CB_SEQ = CB_SEQ + 1
    local id = CB_SEQ

    local p = promise.new()
    local cancel = setTimeout(5000, function()
        if PENDING[id] then
            local pr = PENDING[id].promise
            PENDING[id] = nil
            pr:resolve({
                success = false,
                data = nil,
                error_message = 'timed_out_after_5000ms',
            })
        end
    end)

    PENDING[id] = { promise = p, cancel = cancel }
    TriggerClientEvent('cd_bridge:ClientCallback', source, id, action, ...)

    local result = Citizen.Await(p)

    if not result.success then
        local err = result.error_message or 'unknown'
        ERROR('1202', 'ClientCallback Failed: ('..action..') - '..err)
        return nil
    end

    return result.data
end





-- server callbacks

RegisterServerCallback('cd_bridge:GetSharedVehicles', function(src, ...)
    return GetSharedVehicles()
end)

RegisterServerCallback('cd_bridge:GetAdminPerms', function(src, ...)
    return GetAdminPerms(src)
end)

RegisterServerCallback('cd_bridge:HasAdminPerms', function(src, ...)
    return HasAdminPerms(src, ...)
end)

RegisterServerCallback('cd_bridge:GetCharacterName', function(src, ...)
    return GetCharacterName(src)
end)

RegisterServerCallback('cd_bridge:HasItem', function(src, ...)
    return HasItem(src, ...)
end)

RegisterServerCallback('cd_bridge:HasItemThenRemove', function(src, ...)
    local HasItem = HasItem(src, ...)
    if HasItem then
        RemoveItem(src, ...)
        return true
    end
    return false
end)

RegisterServerCallback('cd_bridge:KickOutPlayersInVehicle', function(src, ...)
    local players, forceKickout, netID = ...
    local entID = NetworkGetEntityFromNetworkId(netID)
    local vehicle = entID and DoesEntityExist(entID) and entID or nil

    for _, source in pairs(players) do
        local ped = GetPlayerPed(source)
        if not forceKickout and vehicle then
            TaskLeaveVehicle(ped, vehicle, 256)
            TaskLeaveAnyVehicle(ped, 0, 0)
        elseif forceKickout then
            local coords = GetEntityCoords(ped)
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
        end
    end
    if (forceKickout) or (not forceKickout and not vehicle) then return true end

    local timeout = 5000
    local start = GetGameTimer()

    while true do
        Wait(100)
        local allLeft = true

        for _, source in pairs(players) do
            local ped = GetPlayerPed(source)
            if GetVehiclePedIsIn(ped, false) == vehicle then
                allLeft = false
                break
            end
        end

        if allLeft or (GetGameTimer() - start) >= timeout then
            if not allLeft then
                for _, source in pairs(players) do
                    local ped = GetPlayerPed(source)
                    local coords = GetEntityCoords(ped)
                    SetEntityCoords(ped, coords.x, coords.y, coords.z)
                end
            end
            break
        end
    end
    return true
end)