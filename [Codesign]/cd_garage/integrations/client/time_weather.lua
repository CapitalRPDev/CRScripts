function ToggleShellTime(toggle)
    if Config.TimeWeather == 'easytime' then
        if toggle == 'enter' then
            TriggerEvent('cd_easytime:PauseSync', true)
        elseif toggle == 'exit' then
            TriggerEvent('cd_easytime:PauseSync', false)
        end

    elseif Config.TimeWeather == 'qb-weathersync' then
        if toggle == 'enter' then
            TriggerEvent('qb-weathersync:client:DisableSync')
        elseif toggle == 'exit' then
            TriggerEvent('qb-weathersync:client:EnableSync')
        end

    elseif Config.TimeWeather == 'vsync' then
        if toggle == 'enter' then
            TriggerEvent('vSync:toggle',false)
            NetworkOverrideClockTime(23, 00, 00)
        elseif toggle == 'exit' then
            TriggerEvent('vSync:toggle',true)
            TriggerServerEvent('vSync:requestSync')
        end
    end
end