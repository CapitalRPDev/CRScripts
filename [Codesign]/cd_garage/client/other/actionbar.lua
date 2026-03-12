if Config.VehicleKeys.ENABLE and Config.VehicleKeys.Hotwire.ENABLE then

    ActionBarTable = {}

    function ActionBar()
        ActionBarTable.result = nil
        SendNUIMessage({
            action = 'actionbar',
            type = 'start',
            settings = Config.VehicleKeys.Hotwire.ActionBar
        })
        while ActionBarTable.result == nil do Wait(100) end
        return ActionBarTable.result
    end

    RegisterNUICallback('actionbarsuccess', function()
        ActionBarTable.result = true
    end)

    RegisterNUICallback('actionbarfail', function()
        ActionBarTable.result = false
    end)

end