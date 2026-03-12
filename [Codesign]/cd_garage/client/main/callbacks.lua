-- Server to Client callbacks system
RegisterNetEvent('cd_garage:Client:Callback', function(id, action, ...)
    if action == 'getmodelstring' then
        TriggerServerEvent('cd_garage:Client:Callback', id, GetDisplayNameFromVehicleModel(...):lower())
    elseif action == 'getvehiclelabel' then
        TriggerServerEvent('cd_garage:Client:Callback', id, GetDefaultVehicleLabel(...))
    elseif action == 'getvehicledata' then
        TriggerServerEvent('cd_garage:Client:Callback', id, {model_string = GetDisplayNameFromVehicleModel(...):lower(), label = GetDefaultVehicleLabel(...)})
    end
end)