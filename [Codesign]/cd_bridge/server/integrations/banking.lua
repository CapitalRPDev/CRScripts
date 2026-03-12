function LogTransaction(source, amount, money_type, reason, transaction_type)
    local identifier = GetIdentifier(source)
    local resourceName = GetCurrentResourceName()
    local characterName = GetCharacterName(source)

    if Cfg.Banking == 'Renewed-Banking' then
        local playerName = GetCharacterName(source)

        exports['Renewed-Banking']:handleTransaction(
            identifier, -- account (player citizenid)
            'Personal Account / ' .. identifier, -- title
            amount, -- amount
            reason, -- message
            transaction_type == 'deposit' and resourceName or characterName, -- sender
            transaction_type == 'deposit' and characterName or resourceName, -- receiver
            transaction_type -- deposit | withdraw
        )


    elseif Cfg.Banking == 'okokBankingV2' then
        local data = {
            sender_identifier = transaction_type == 'deposit' and resourceName or identifier,
            sender_name = transaction_type == 'deposit' and resourceName or characterName,
            receiver_identifier = transaction_type == 'deposit' and identifier or resourceName,
            receiver_name = transaction_type == 'deposit' and characterName or resourceName,
            value = amount,
            type = transaction_type,
            reason = reason
        }
        exports['okokBankingV2']:AddTransaction(identifier, data, source)
    end
end

