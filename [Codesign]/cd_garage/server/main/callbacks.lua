--Server to Client callbacks system
local CB = {}
local CB_id = 0

function Callback(source, action, ...)
    CB_id = CB_id + 1
    local id = CB_id

    TriggerClientEvent('cd_garage:Client:Callback', source, id, action, ...)
    Wait(10)

    local timeout = 0
    while CB[id] == nil and timeout <= 100 do
        Wait(0)
        timeout = timeout + 1
    end

    local res = CB[id]
    if res then
        CB[id] = nil
        return res
    else
        print(('Callback timed out: source=%s id=%d action=%s'):format(tostring(source), id, tostring(action)))
        return nil
    end
end

RegisterServerEvent('cd_garage:Client:Callback', function(id, result)
    CB[id] = result
    Wait(5000)
    CB[id] = nil
end)


--Client to Server callbacks system
exports.cd_bridge:RegisterServerCallback('cd_garage:mileage', function(src, ...)
    return GetAdvStats(...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:onstreetscheck', function(src, ...)
    return OnStreetsCheck(...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:getallplayers', function(src, ...)
    return GetAllPlayers(src)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:getimpounddata', function(src, ...)
    return GetImpoundData(src, ...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:getallimpounddata', function(src, ...)
    return GetAllImpoundData(...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:cancivretrivevehicle', function(src, ...)
    return CanCivRetriveVehicle(src, ...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:generate_new_plate', function(src, ...)
    return GenerateRandomPlate()
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:search_vehicle_in_garage', function(src, ...)
    return SearchVehicleInGarage(...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:get_vehicle_info', function(src, ...)
    return GetVehicleInfo(src, ...)
end)

exports.cd_bridge:RegisterServerCallback('cd_garage:has_vehicle_already_spawned', function(src, ...)
    return HasVehicleAlreadySpawned(...)
end)