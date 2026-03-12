if Config.GarageSpace.ENABLE then

    RegisterCommand(Config.GarageSpace.chat_command_check, function(source, args)
        local identifier = GetIdentifier(source)
        local result = DB.fetch('SELECT garage_limit FROM '..FW.users_table..' WHERE '..FW.users_identifier..'="'..identifier..'"')
        if result and result[1] and result[1].garage_limit then
            Notif(source, 2, 'garage_space_check', result[1].garage_limit)
        end
    end, false)

    RegisterCommand(Config.GarageSpace.chat_command_main, function(source, args)
        if Config.GarageSpace.Authorized_Jobs[GetJobName(source)] ~= nil then
            if args[1] then
                local target = tonumber(args[1])
                local identifier = GetIdentifier(target)
                if GetPlayerName(target) then
                    local result = DB.fetch('SELECT garage_limit FROM '..FW.users_table..' WHERE '..FW.users_identifier..'="'..identifier..'"')
                    if result and result[1] and result[1].garage_limit then
                        local limit = tonumber(result[1].garage_limit)
                        local price
                        if Config.GarageSpace.Garagespace_Table then
                            if limit < #Config.GarageSpace.Garagespace_Table then
                                for cd=1, #Config.GarageSpace.Garagespace_Table do
                                    if cd == limit then
                                        price = Config.GarageSpace.Garagespace_Table[cd]
                                        break
                                    end
                                end
                                local playerMoney = GetPlayerMoney(source, 'bank')
                                if playerMoney > price then
                                    RemovePlayerMoney(source, price, 'bank', 'garage_space')
                                    local new_limit = limit+1
                                    DB.exec('UPDATE '..FW.users_table..' SET garage_limit="'..new_limit..'" WHERE '..FW.users_identifier..'="'..identifier..'"')
                                    Notif(source, 1, 'add_garageslot', target)
                                    Notif(target, 1, 'recieve_garageslot', new_limit)
                                    GarageSpaceLogs(source, new_limit, price, target)
                                else
                                    Notif(source, 3, 'not_enough_money')
                                end
                            else
                                Notif(source, 3, 'garage_full')
                            end
                        end
                    end
                else
                    Notif(source, 3, 'incorrect_id')
                end
            else
                Notif(source, 3, 'invalid_format')
            end
        else
            Notif(source, 3, 'no_permissions')
        end
    end, false)
end