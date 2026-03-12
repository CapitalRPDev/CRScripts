if not Config.GarageSpace.ENABLE then return end

TriggerEvent('chat:addSuggestion', '/'..Config.GarageSpace.chat_command_main, Locale('chatsuggestion_garagespace'), {{ name=Locale('chatsuggestion_playerid_1'), help=Locale('chatsuggestion_playerid_2')}})
TriggerEvent('chat:addSuggestion', '/'..Config.GarageSpace.chat_command_check, Locale('chatsuggestion_garagespace_check'))