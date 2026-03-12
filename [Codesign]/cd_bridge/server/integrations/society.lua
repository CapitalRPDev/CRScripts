--- @param job string           The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param societyLabel string  The label for the society account, only used for esx.
function LoadSocietyAccount(job, societyLabel)
    if Cfg.Society == 'none' then return end

    if Cfg.Society == 'esx_addonaccount' then
        if not exports['esx_addonaccount']:GetSharedAccount('society_'..job) then
            exports['esx_addonaccount']:AddSharedAccount({name = 'society_'..job, label = societyLabel}, 0)
        end

    elseif Cfg.Society == 'okokBankingV2' then
        if not exports['okokBankingV2']:GetAccount(job) then
            ERROR('3485', 'okokBankingV2 account for job '..job..' does not exist.')
        end

    elseif Cfg.Society == 'qb-banking' then
        if not exports['qb-banking']:GetAccount(job) then
            exports['qb-banking']:CreateJobAccount(job, 0)
        end

    elseif Cfg.Society == 'Renewed-Banking' then
        if not exports['Renewed-Banking']:GetJobAccount(job) then
            exports['Renewed-Banking']:CreateJobAccount(job, 0)
        end

    elseif Config.Framework == 'other' then
        -- add your own society loading here, make sure to check if the society already exists before creating it to avoid duplicates.
    end
end

--- @param job string       The job name for the society account, for example 'mechanic' for a mechanic society.
--- @return number|nil 0    The current balance of the society account.
function GetSocietyBalance(job)
    if Cfg.Society == 'none' then return 0 end

    if Cfg.Society == 'esx_addonaccount' then
        local balance = 0
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
            if account then
                balance = account.money
            end
        end)
        return balance

    elseif Cfg.Society == 'okokBankingV2' then
        return exports['okokBankingV2']:GetAccount(job).account_balance

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:GetAccount(job).account_balance

    elseif Cfg.Society == 'Renewed-Banking' then
        return exports['Renewed-Banking']:getAccountMoney(job)

    elseif Config.Framework == 'other' then
        -- add your own society balance retrieval here.
        return 0
    end
end

--- @param job string           The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param amount number        The amount of money to add to the society account.
--- @param reason string|nil    The reason for adding money to the society account.
--- @return boolean true        if the money was added successfully, false otherwise.
function AddSocietyMoney(job, amount, reason)
    if Cfg.Society == 'none' then return false end
    reason = reason or Locale('mechanic')

    if Cfg.Society == 'esx_addonaccount' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
			return account.addMoney(amount)
		end)

    elseif Cfg.Society == 'okokBankingV2' then
        exports['okokBankingV2']:AddMoney(job, amount)
        return true

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:AddMoney(job, amount, reason)

    elseif Cfg.Society == 'Renewed-Banking' then
        return exports['Renewed-Banking']:addAccountMoney(job, amount)

    elseif Config.Framework == 'other' then
        -- add your own society money adding here.
    end
    return false
end

--- @param job string           The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param amount number        The amount of money to remove to the society account.
--- @param reason string|nil    The reason for removing money to the society account.
--- @return boolean true        if the money was removed successfully, false otherwise.
function RemoveSocietyMoney(job, amount, reason)
    if Cfg.Society == 'none' then return false end
    reason = reason or Locale('mechanic')

    local balance = GetSocietyBalance(job)
    if balance <= amount then
        return false
    end

    if Cfg.Society == 'esx_addonaccount' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
            return account.removeMoney(amount)
        end)

    elseif Cfg.Society == 'okokBankingV2' then
        exports['okokBankingV2']:RemoveMoney(job, amount)
        return true

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:RemoveMoney(job, amount, reason)

    elseif Cfg.Society == 'Renewed-Banking' then
        return exports['Renewed-Banking']:removeAccountMoney(job, amount)

    elseif Config.Framework == 'other' then
        -- remove your own society money adding here.
    end
    return false
end