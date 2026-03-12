DB = {}
local which = (Cfg and Cfg.Database)

local function _timed(label, fn)
    local t0 = GetGameTimer()
    local ok, res = pcall(fn)
    local dt = GetGameTimer() - t0

    if Cfg.BridgeDebugSQL then
        Citizen.Trace(('^3[DB][%s] Time:^0 %d ms\n'):format(label, dt))
    end

    if not ok then
        Citizen.Trace(('^1[DB][%s] error: %s^0\n'):format(label, tostring(res)))
        return nil, res
    end

    return res, nil
end

local function _debugSQL(label, sql, params)
    if not Cfg.BridgeDebugSQL then return end

    Citizen.Trace(("^3[DB][%s] SQL:^0 %s\n"):format(label, sql))

    if params and next(params) then
        Citizen.Trace(("^3[DB][%s] Params:^0 %s\n"):format(label, json.encode(params)))
    end
end

function DB.fetch(sql, params)
    params = params or {}
    _debugSQL('fetch', sql, params)

    if which == 'oxmysql' then
        return _timed('fetch', function()
            local p = promise.new()
            exports.oxmysql:fetch(sql, params, function(rows)
                p:resolve(rows or {})
            end)
            return Citizen.Await(p)
        end)

    elseif which == 'mysql-async' then
        return _timed('fetch', function()
            local p = promise.new()
            MySQL.Async.fetchAll(sql, params, function(rows)
                p:resolve(rows)
            end)
            return Citizen.Await(p)
        end)

    elseif which == 'ghmattimysql' then
        return _timed('fetch', function()
            local p = promise.new()
            exports['ghmattimysql']:execute(sql, params, function(rows)
                p:resolve(rows)
            end)
            return Citizen.Await(p)
        end)
    end
end

function DB.exec(sql, params)
    params = params or {}
    _debugSQL('exec', sql, params)

    if which == 'oxmysql' then
        return _timed('exec', function()
            local p = promise.new()
            exports.oxmysql:execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)
            return Citizen.Await(p)
        end)

    elseif which == 'mysql-async' then
        return _timed('exec', function()
            local p = promise.new()
            MySQL.Async.execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)
            return Citizen.Await(p)
        end)

    elseif which == 'ghmattimysql' then
        return _timed('exec', function()
            local p = promise.new()
            exports['ghmattimysql']:execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)
            return Citizen.Await(p)
        end)
    end
end

function DB.scalar(sql, params)
    local rows = DB.fetch(sql, params)
    if rows and rows[1] then
        for _, v in pairs(rows[1]) do
            return v
        end
    end
    return nil
end

function DB.single(sql, params)
    local rows = DB.fetch(sql, params)
    return (rows and rows[1]) or nil
end

function DB.count(sql, params)
    local val = DB.scalar(sql, params)
    return tonumber(val) or 0
end

function DB.exists(sql, params)
    local val = DB.scalar(sql, params)
    return val ~= nil
end

function DB.tableExists(tableName)
    local sql = [[
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = ?
        LIMIT 1
    ]]
    return DB.scalar(sql, { tableName }) ~= nil
end

function DB.columnExists(tableName, columnName)
    local sql = [[
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = ?
          AND column_name = ?
        LIMIT 1
    ]]
    return DB.scalar(sql, { tableName, columnName }) ~= nil
end

return DB
