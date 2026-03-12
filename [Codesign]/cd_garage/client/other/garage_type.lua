function GetGarageType(value)
    local garage_type = 'car'
    local model = GetVehicleModelHash(value)

    if not model then
        return garage_type
    end

    if IsThisModelAHeli(model) or IsThisModelAPlane(model) then
        garage_type = 'air'
    elseif IsThisModelABoat(model) or IsThisModelAJetski(model) or model == `submersible` or model == `submersible2` or model == `avisa` then
        garage_type = 'boat'
    end

    return garage_type
end

RegisterNetEvent('cd_garage:UpdateGarageType')
AddEventHandler('cd_garage:UpdateGarageType', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if IsPedInAnyVehicle(ped, false) then
        TriggerServerEvent('cd_garage:UpdateGarageType', GetGarageType(vehicle), GetAllPlateFormats(vehicle))
    else
        Notif(3, 'get_inside_veh')
    end
end)