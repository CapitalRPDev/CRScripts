function GetCustomJobDuty()
    if Cfg.Gang == 'none' then return nil end

    if Cfg.Gang == 'origen_police' then
        return exports['origen_police']:IsOnDuty()
    end

    return nil
end