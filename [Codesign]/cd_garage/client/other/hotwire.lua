if not Config.VehicleKeys.ENABLE or not Config.VehicleKeys.Hotwire.ENABLE then return end

local function startCarAlarm(vehicle)
    CreateThread(function()
        StartVehicleAlarm(vehicle)
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, 1*60*1000) --2 mins
        SetVehicleIndicatorLights(vehicle, 1, true)
        SetVehicleIndicatorLights(vehicle, 0, true)
        for cd = 1, 60 do
            SetVehicleLights(vehicle, 2)
            Wait(500)
            SetVehicleLights(vehicle, 0)
            Wait(500)
        end
        SetVehicleIndicatorLights(vehicle, 1, false)
        SetVehicleIndicatorLights(vehicle, 0, false)
    end)
end

CreateThread(function()
    local result = nil
    local wait = 500
    while true do
        wait = 500
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(vehicle, -1) == ped then
            local plate = GetPlate(vehicle)
            local data = KeysTable[plate]
            if data then
                wait = 5
                if not data.has_key and GetVehicleClass(vehicle) ~= 13 and IsControlJustReleased(0, Config.Keys.StartHotwire_Key) then
                    EnableNuiFocus()
                    startCarAlarm(vehicle)
                    result = ActionBar()
                    DisableNuiFocus()
                end
                if result then
                    AddKey(plate)
                    result = nil
                end
            end
        end
        Wait(wait)
    end
end)