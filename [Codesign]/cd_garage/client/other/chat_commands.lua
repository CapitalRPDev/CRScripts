TriggerEvent('chat:addSuggestion', '/closeui', Locale('chatsuggestion_ui'))
RegisterCommand('closeui', function()
    CloseAllNUI()
end, false)