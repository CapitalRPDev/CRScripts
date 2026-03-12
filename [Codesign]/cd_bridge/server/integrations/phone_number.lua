-- Get a players phone number.
--- @param source number        The player's server ID.
--- @return string|number|nil   --The player's phone number, or nil if not found.
function GetPhoneNumber(source)
    local Player = GetPlayer(source)
    local identifier = GetIdentifier(source)
    if not Player then return end
    if not identifier then return end

    if Cfg.Phone == 'esx_phone' then
        local Result = DatabaseQuery('SELECT phone_number FROM users WHERE identifier=?', {identifier})
        if Result and Result[1] and Result[1].phone_number then
            return Result[1].phone_number
        end

    elseif Cfg.Phone == 'gcphone' then
        return exports.gcphone:getPhoneNumber(source)

    elseif Cfg.Phone == 'gksphone' then
        return exports.gksphone:GetPhoneBySource(source)

    elseif Cfg.Phone == 'lb-phone' then
        return exports['lb-phone']:GetEquippedPhoneNumber(source)

    elseif Cfg.Phone == 'npwd' then
        local phoneData = exports.npwd:getPlayerData({ identifier = identifier })
        if phoneData and phoneData.phoneNumber then
            return phoneData.phoneNumber
        end

    elseif Cfg.Phone == 'okokPhone' then
        return exports.okokPhone:getPhoneNumberFromSource(source)

    elseif Cfg.Phone == 'qb-phone' then
        return Player.PlayerData.charinfo.phone

    elseif Cfg.Phone == 'qbx_npwd' then
        local phoneData = exports.npwd:getPlayerData({ identifier = identifier })
        if phoneData and phoneData.phoneNumber then
            return phoneData.phoneNumber
        end

    elseif Cfg.Phone == '17mov_Phone' then
        return exports['17mov_Phone']:GetNumberFromPlayer(source)

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
        -- Return the player's phone number, or nil if not found.
    end
end

-- Check if a phone number already exists in the database.
--- @param source number        The player's server ID.
--- @param phoneNumber string   The phone number to check.
--- @return boolean             --True if the phone number exists, false otherwise.
function DoesPhoneNumberAlreadyExist(source, phoneNumber)
    if Cfg.Phone == 'esx_phone' then
        local Result = DB.fetch('SELECT phone_number FROM users WHERE phone_number=?', {phoneNumber})
        if Result and Result[1] then
            return true
        end

    elseif Cfg.Phone == 'gcphone' then
        local Result = DB.fetch('SELECT phone_number FROM gcphone_users WHERE phone_number=?', {phoneNumber})
        if Result and Result[1] then
            return true
        end

    elseif Cfg.Phone == 'gksphone' then
        local phoneData = exports.gksphone:GetPhoneDataByNumber(phoneNumber)
        if phoneData then
            return true
        end

    elseif Cfg.Phone == 'lb-phone' then
       local Result = DB.fetch('SELECT phone_number FROM phone_phones WHERE phone_number=?', {phoneNumber})
        if Result and Result[1] then
            return true
        end

    elseif Cfg.Phone == 'npwd' then
        if Cfg.Framework == 'esx' then
            local Result = DB.fetch('SELECT phone_number FROM users WHERE phone_number=?', {phoneNumber})
            if Result and Result[1] then
                return true
            end

        elseif Cfg.Framework == 'qbcore' then
            local Result = DB.fetch('SELECT charinfo FROM players')
            if Result and Result[1] then
                for cd = 1, #Result do
                    if json.decode(Result[cd].charinfo).phone == phoneNumber then
                        return true
                    end
                end
            end
        end

    elseif Cfg.Phone == 'okokPhone' then
        local Result = DB.fetch('SELECT phone_number FROM okokphone_users WHERE phone_number=?', {phoneNumber})
        if Result and Result[1] then
            return true
        end

    elseif Cfg.Phone == 'qb-phone' then
        local Result = DB.fetch('SELECT charinfo FROM players')
        if Result and Result[1] then
            for cd = 1, #Result do
                if json.decode(Result[cd].charinfo).phone == phoneNumber then
                    return true
                end
            end
        end

    elseif Cfg.Phone == 'qbx_npwd' then
        local Result = DB.fetch('SELECT phone_number FROM users WHERE phone_number=?', {phoneNumber})
        if Result and Result[1] then
            return true
        end

    elseif Cfg.Phone == '17mov_Phone' then
        -- Not yet implemented.

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
        -- Return true if the phone number exists, false otherwise.
    end

    return false
end

-- Set a players phone number.
--- @param source number        The player's server ID.
--- @param newNumber string     The new phone number to set.
function SetPhoneNumber(source, newNumber)
    if Cfg.Phone == 'esx_phone' then
        local identifier = GetIdentifier(source)
        DB.exec('UPDATE phone_number SET phone_number = ? WHERE identifier = ?', {newNumber, identifier})

    elseif Cfg.Phone == 'gcphone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'gksphone' then
        local oldNumber = GetPhoneNumber(source)
        local phoneData = exports.gksphone:GetPhoneDataByNumber(oldNumber)
        exports.gksphone:ChangeNumber(phoneData.phoneID, oldNumber, newNumber, true)

    elseif Cfg.Phone == 'lb-phone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'npwd' then
        if Cfg.Framework == 'esx' then
            local identifier = GetIdentifier(source)
            DB.exec('UPDATE users SET phone_number = ? WHERE identifier = ?', {newNumber, identifier})

        elseif Cfg.Framework == 'qbcore' then
            local Player = GetPlayer(source)
            if Player then
                Player.Functions.SetPhoneNumber(newNumber)
                Player.PlayerData.charinfo.phone = newNumber
                Player.Functions.SavePlayerData()
            end
        end

    elseif Cfg.Phone == 'okokPhone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'qb-phone' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.SetPhoneNumber(newNumber)
            Player.PlayerData.charinfo.phone = newNumber
            Player.Functions.SavePlayerData()
        end

    elseif Cfg.Phone == 'qbx_npwd' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.SetPhoneNumber(newNumber)
            Player.PlayerData.charinfo.phone = newNumber
            Player.Functions.SavePlayerData()
        end

    elseif Cfg.Phone == '17mov_Phone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
    end
end