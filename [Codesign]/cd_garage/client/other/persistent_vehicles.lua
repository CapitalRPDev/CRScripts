if not Config.PersistentVehicles.ENABLE then return end

RegisterNetEvent('cd_garage:PersistentVehicles_GetVehicleProperties')
AddEventHandler('cd_garage:PersistentVehicles_GetVehicleProperties', function(plate, netid)
    TriggerServerEvent('cd_garage:PersistentVehicles_GetVehicleProperties', plate, GetVehicleProperties(NetworkGetEntityFromNetworkId(netid)))
end)

local RespawnWaitngList = 0
RegisterNetEvent('cd_garage:PersistentVehicles_SpawnVehicle')
AddEventHandler('cd_garage:PersistentVehicles_SpawnVehicle', function(data)
    while RespawnWaitngList > 0 do Wait(100) end
    RespawnWaitngList = RespawnWaitngList + 1
    ExitLocation = {x = data.coords.x, y = data.coords.y, z = data.coords.z, h = data.heading}
    local vehicle = SpawnVehicle({plate = data.plate, vehicle = data.props}, false, false, false, true)
    RespawnWaitngList = RespawnWaitngList - 1
    if RespawnWaitngList < 0 then RespawnWaitngList = 0 end
    if data.lock_state ~= nil and (data.lock_state == 2 or data.lock_state == 4) then
        LockVehicle(vehicle, false, false, false)
    end
end)