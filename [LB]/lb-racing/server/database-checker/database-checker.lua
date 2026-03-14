local shouldGenerateTables = false

if not Config.DatabaseChecker.Enabled and not shouldGenerateTables then
    DatabaseCheckerFinished = true

    return debugprint("Database checker is disabled")
end

MySQL.ready.await()

local database = MySQL.scalar.await("SELECT DATABASE()")

if not database then
    DatabaseCheckerFinished = true

    return infoprint(
        "error",
        "Database checker: Failed to get database name. The script will still work, but database changes will not apply automatically. To disable this warning, set Config.DatabaseChecker.Enabled to false"
    )
end

local databaseVersion = MySQL.scalar.await("SELECT VERSION()") or ""

if not databaseVersion:find("MariaDB") then
    DatabaseCheckerFinished = true

    return infoprint(
        "error",
        "Database checker: Your database is not MariaDB. The script may not work as expected, and database changes will not apply automatically. To disable this warning, set Config.DatabaseChecker.Enabled to false"
    )
end

local major, minor, patch = databaseVersion:match("(%d+)%.(%d+)%.(%d+)")

major = major and tonumber(major)
minor = minor and tonumber(minor)
patch = patch and tonumber(patch)

if not major or not minor or not patch then
    DatabaseCheckerFinished = true
    return infoprint(
        "error",
        "Database checker: Failed to get database version. The script will still work, but database changes will not apply automatically. To disable this warning, set Config.DatabaseChecker.Enabled to false"
    )
end

if major < 10 or (major == 10 and minor < 11) then
    DatabaseCheckerFinished = true

    return infoprint(
        "error",
        "Database checker: Your database version is outdated. Please update to MariaDB 10.11 or newer. The script may not work as expected, and database changes will not apply automatically. To disable this warning, set Config.DatabaseChecker.Enabled to false"
    )
end

---@class DefaultTable
---@field column string
---@field type string
---@field allowNull boolean
---@field isKey boolean
---@field default? string
---@field length? number
---@field unsigned? boolean

---@type { [string]: DefaultTable[] }
local defaultTables = GetDefaultDatabaseTables()

---@class DatabaseTable
---@field type string
---@field allowNull boolean
---@field default? string
---@field length? number
---@field isKey boolean
---@field unsigned boolean
---@field keyType string

---@type { [string]: { [string]: DatabaseTable } }
local tables = {}

local function FetchTables()
    table.wipe(tables)

    local rows = MySQL.query.await(
        "SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_KEY, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME LIKE ?",
        {
            shouldGenerateTables and "generate_lb" or database,
            "lbracing_%",
        }
    )

    for i = 1, #rows do
        local row = rows[i]
        local tableName = row.TABLE_NAME
        local columnName = row.COLUMN_NAME
        local dataType = row.DATA_TYPE
        local length = row.CHARACTER_MAXIMUM_LENGTH
        local isNullable = row.IS_NULLABLE
        local default = row.COLUMN_DEFAULT
        local columnType = row.COLUMN_TYPE
        local unsigned = columnType:find("unsigned") ~= nil
        local isKey = #row.COLUMN_KEY > 0

        if dataType == "tinyint" or dataType == "smallint" or dataType == "mediumint" or dataType == "int" or dataType == "bigint" then
            length = tonumber(columnType:match("%((%d+)%)"))
        end

        if not tables[tableName] then
            tables[tableName] = {}
        end

        tables[tableName][columnName] = {
            type = dataType:upper(),
            allowNull = isNullable == "YES",
            default = default,
            length = length,
            isKey = isKey,
            unsigned = unsigned,
            keyType = row.COLUMN_KEY:upper(),
        }
    end

    return tables
end

FetchTables()

local function GenerateDefaultTables()
    local luaTable = "local defaultTables = {\n"

    for tableName, columns in pairs(tables) do
        luaTable = ("%s\t%s = {\n"):format(luaTable, tableName)

        for columnName, column in pairs(columns) do
            luaTable = luaTable .. ('\t\t{\n\t\t\tcolumn = "%s",\n'):format(columnName)
            luaTable = luaTable .. ('\t\t\ttype = "%s",\n'):format(column.type)
            luaTable = luaTable .. ("\t\t\tallowNull = %s,\n"):format(column.allowNull and "true" or "false")
            luaTable = luaTable .. ("\t\t\tisKey = %s,\n"):format(column.isKey and "true" or "false")

            if column.default then
                luaTable = luaTable .. ('\t\t\tdefault = "%s",\n'):format(column.default)
            end

            if column.length and column.type ~= "LONGTEXT" and column.type ~= "TEXT" then
                luaTable = luaTable .. ("\t\t\tlength = %s,\n"):format(math.floor(column.length))
            end

            if column.unsigned then
                luaTable = luaTable .. ("\t\t\tunsigned = true,\n")
            end

            luaTable = luaTable .. "\t\t},\n"
        end

        luaTable = luaTable .. "\t},\n"
    end

    luaTable = luaTable .. "}"

    SaveResourceFile(GetCurrentResourceName(), "defaultdb.lua", luaTable, -1)
end

if shouldGenerateTables then
    DatabaseCheckerFinished = true

    return GenerateDefaultTables()
end

---@param sqlFile string
---@return string[]
local function GetQueries(sqlFile)
    local queries = {}

    for query in sqlFile:gmatch("[^;]+") do
        query = query:gsub("%-%-[^\n]*", ""):gsub("/%*.-%*/", ""):gsub("^%s+", ""):gsub("%s+$", "")
        query = query:sub(1, -1)

        if #query > 0 then
            queries[#queries + 1] = query
        end
    end

    return queries
end

local function InsertTracks()
    local sqlFile = LoadResourceFile(GetCurrentResourceName(), "default-tracks.sql")

    if not sqlFile then
        return infoprint("error", "Database checker: Failed to load default-tracks.sql")
    end

    if MySQL.transaction.await(GetQueries(sqlFile)) then
        infoprint("success", "Database checker: Inserted default tracks successfully")
    else
        infoprint("error", "Database checker: Failed to insert default tracks")
    end
end

---@param insertTracks boolean
local function RunSQLFile(insertTracks)
    local sqlFile = LoadResourceFile(GetCurrentResourceName(), "racing.sql")

    if not sqlFile then
        DatabaseCheckerFinished = true

        return infoprint("error", "Database checker: Failed to load racing.sql")
    end

    if not MySQL.transaction.await(GetQueries(sqlFile)) then
        DatabaseCheckerFinished = true

        return infoprint(
            "error",
            "Database checker: Failed to create tables, please run racing.sql manually using HeidiSQL"
        )
    else
        infoprint("success", "Database checker: Created tables successfully")
    end

    if insertTracks then
        InsertTracks()
    end

    FetchTables()
end

if not tables.lbracing_races and not Config.DatabaseChecker.AutoFix then
    DatabaseCheckerFinished = true

    return infoprint("error", "Database checker: Missing table lbracing_races. Please run racing.sql manually using HeidiSQL")
end

for tableName, columns in pairs(defaultTables) do
    if not tables[tableName] then
        infoprint("warning", ("The table ^5%s^7 is missing in the database. Automatically running the sql file."):format(tableName))
        RunSQLFile(not tables["lbracing_tracks"])

        break
    end
end

local fixQueries = {}
local missingTables = {}
local madeChanges = false

local function AddTrackLength()
    MySQL.rawExecute.await("ALTER TABLE lbracing_tracks ADD COLUMN track_length INT UNSIGNED NOT NULL DEFAULT 0")
    MySQL.rawExecute.await("ALTER TABLE lbracing_tracks ADD COLUMN has_calculated_track_length TINYINT(1) NOT NULL DEFAULT 0")

    while true do
        ---@type { id: number, track_type: TrackType, checkpoints: string }[]
        local rawTracks = MySQL.query.await("SELECT id, track_type, checkpoints FROM lbracing_tracks WHERE has_calculated_track_length = 0 LIMIT 100")

        if #rawTracks == 0 then
            break
        end

        local params = {}

        for i = 1, #rawTracks do
            local rawTrack = rawTracks[i]
            local checkpoints = json.decode(rawTrack.checkpoints)

            ---@type vector3[]
            local checkpointCenterPositions = {}

            for j = 1, #checkpoints do
                local checkpoint = checkpoints[j]

                if type(checkpoint[1]) == "number" then -- the checkpoint is just a vector
                    checkpointCenterPositions[j] = ArrayToVector(checkpoint) --[[@as vector3]]
                else
                    checkpointCenterPositions[j] = GetCenterVector({
                        ArrayToVector(checkpoint[1]) --[[@as vector3]],
                        ArrayToVector(checkpoint[2]) --[[@as vector3]],
                    })
                end
            end

            params[#params+1] = {
                GetTrackLength(rawTrack.track_type, checkpointCenterPositions),
                rawTrack.id
            }
        end

        MySQL.rawExecute.await("UPDATE lbracing_tracks SET track_length = ?, has_calculated_track_length = 1 WHERE id = ?", params)
    end

    MySQL.rawExecute.await("ALTER TABLE lbracing_tracks DROP COLUMN has_calculated_track_length")
end

if not tables.lbracing_tracks.track_length then
    AddTrackLength()

    madeChanges = true
end

local function ChangeRepeatingRaceToMinutes()
    MySQL.rawExecute.await("ALTER TABLE lbracing_repeating_races ADD COLUMN repeat_minute_interval MEDIUMINT UNSIGNED NOT NULL DEFAULT 0")
    MySQL.rawExecute.await("UPDATE lbracing_repeating_races SET repeat_minute_interval = repeat_hour_interval * 60")
    MySQL.rawExecute.await("ALTER TABLE lbracing_repeating_races DROP COLUMN repeat_hour_interval")
end

if not tables.lbracing_repeating_races.repeat_minute_interval then
    ChangeRepeatingRaceToMinutes()

    madeChanges = true
end

if madeChanges then
    FetchTables()
end

---@param column DefaultTable
local function GetLastArg(column)
    local lastArg = column.type

    if column.length and column.type ~= "LONGTEXT" and column.type ~= "TEXT" then
        lastArg = lastArg .. ("(%s)"):format(column.length)
    end

    if column.unsigned then
        lastArg = lastArg .. " UNSIGNED"
    end

    if not column.allowNull then
        lastArg = lastArg .. " NOT NULL"
    end

    if column.default then
        lastArg = lastArg .. (" DEFAULT %s"):format(column.default)
    end

    return lastArg
end

for tableName, columns in pairs(defaultTables) do
    local checkTable = tables[tableName]

    if not checkTable then
        infoprint("error", ("Missing table ^5%s^7 in the database. Please re-run the racing.sql file."):format(tableName))

        missingTables[#missingTables+1] = tableName

        goto continue
    end

    for i = 1, #columns do
        local defaultColumn = columns[i]
        local column = checkTable[defaultColumn.column]

        if not checkTable[defaultColumn.column] then
            infoprint("warning", ("Missing column ^5%s^7 in the table ^5%s^7."):format(defaultColumn.column, tableName))

            if not defaultColumn.isKey then
                fixQueries[#fixQueries+1] = ("ALTER TABLE `%s` ADD COLUMN `%s` %s"):format(tableName, defaultColumn.column, GetLastArg(defaultColumn))
            else
                infoprint("error", ("Column ^5%s^7 in the table ^5%s^7 is a key and cannot be added automatically. Check the #updates channel for a query to run, or ask in #customer-support"):format(defaultColumn.column, tableName))
            end

            goto continueColumns
        end

        if defaultColumn.type ~= column.type then
            infoprint("warning", ("Column ^5%s^7 in the table ^5%s^7 has the wrong data type."):format(defaultColumn.column, tableName))

            if not defaultColumn.isKey and not column.isKey then
                fixQueries[#fixQueries+1] = ("ALTER TABLE `%s` MODIFY COLUMN `%s` %s"):format(tableName, defaultColumn.column, GetLastArg(defaultColumn))
            else
                infoprint("error", ("Column ^5%s^7 in the table ^5%s^7 is a key and cannot be modified automatically. Check the #updates channel for a query to run, or ask in #customer-support"):format(defaultColumn.column, tableName))
            end

            goto continueColumns
        end

        if defaultColumn.length and defaultColumn.length ~= column.length then
            infoprint("warning", ("Column ^5%s^7 in the table ^5%s^7 has the wrong length."):format(defaultColumn.column, tableName))

            if not defaultColumn.isKey and not column.isKey then
                fixQueries[#fixQueries+1] = ("ALTER TABLE `%s` MODIFY COLUMN `%s` %s"):format(tableName, defaultColumn.column, GetLastArg(defaultColumn))
            else
                infoprint("error", ("Column ^5%s^7 in the table ^5%s^7 is a key and cannot be modified automatically. Check the #updates channel for a query to run, or ask in #customer-support"):format(defaultColumn.column, tableName))
            end

            goto continueColumns
        end

        ::continueColumns::
    end

    ::continue::
end

local changes = #fixQueries
local missingAnyTables = #missingTables > 0

if changes > 0 then
    if Config.DatabaseChecker.AutoFix then
        infoprint("info", ("Fixing database, applying %i changes..."):format(changes))

        local success = MySQL.transaction.await(fixQueries)

        if success then
            infoprint("success", "Database has been fixed.")
        else
            infoprint("error", "Failed to fix the database.")
        end
    else
        local fixQuery = ""

        for i = 1, #fixQueries do
            fixQuery = fixQuery .. fixQueries[i] .. ";\n"
        end

        SaveResourceFile(GetCurrentResourceName(), "fix.sql", fixQuery, -1)
        infoprint("warning", ("Database has %i changes that need to be fixed. Try running lb-racing/fix.sql"):format(changes))
    end
end

DatabaseCheckerFinished = true

while (changes > 0 and not Config.DatabaseChecker.AutoFix) or missingAnyTables do
    if changes > 0 and not Config.DatabaseChecker.AutoFix then
        infoprint("warning", ("Database has %i changes that need to be fixed. Try running lb-racing/fix.sql"):format(changes))
    end

    if missingAnyTables then
        infoprint("error", "The database is missing the table" .. (missingAnyTables == 1 and "s^5 " or "^5 ") ..  table.concat(missingTables, "^7,^5 ") .. "^7. Please re-run the racing.sql file.")
    end

    Wait(5000)
end
