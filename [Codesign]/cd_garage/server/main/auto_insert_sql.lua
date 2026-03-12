local function ensureTable(name, query)
    if not DB.tableExists(name) then
        DB.exec(query)
        Citizen.Trace(('^3[cd_garage]^0 Table ^5%s^0 was ^1missing^0 — created automatically.\n'):format(name))
        return true
    end
    return false
end

local function ensureColumn(table_name, column_name, definition)
    if not DB.columnExists(table_name, column_name) then
        local alter = ('ALTER TABLE `%s` ADD COLUMN `%s` %s;'):format(table_name, column_name, definition)
        DB.exec(alter)
        Citizen.Trace(('^3[cd_garage]^0 Column ^5%s.%s^0 was ^1missing^0 — added automatically.\n'):format(table_name, column_name))
        return true
    end
    return false
end

function InsertSQL()
    local created, fixed = {}, {}
    local vehicleTable = Cfg.FrameworkSQLtables.vehicle_table
    local usersTable = Cfg.FrameworkSQLtables.users_table
    if Config.AutoInsertSQL then
        local columns = {
            {table = vehicleTable, column = "in_garage",         def = "TINYINT(1) NOT NULL DEFAULT 0"},
            {table = vehicleTable, column = "garage_id",         def = "VARCHAR(50) NOT NULL DEFAULT 'A'"},
            {table = vehicleTable, column = "garage_type",       def = "VARCHAR(50) NOT NULL DEFAULT 'car'"},
            {table = vehicleTable, column = "job_personalowned", def = "VARCHAR(50) NOT NULL DEFAULT ''"},
            {table = vehicleTable, column = "property",          def = "INT(10) NOT NULL DEFAULT 0"},
            {table = vehicleTable, column = "impound",           def = "INT(10) NOT NULL DEFAULT 0"},
            {table = vehicleTable, column = "impound_data",      def = "LONGTEXT NOT NULL DEFAULT ''"},
            {table = vehicleTable, column = "adv_stats",         def = "LONGTEXT NOT NULL DEFAULT '{\"plate\":\"nil\",\"mileage\":0.0,\"maxhealth\":1000.0}'"},
            {table = vehicleTable, column = "custom_label",      def = "VARCHAR(30) NULL DEFAULT NULL"},
            {table = vehicleTable, column = "fakeplate",         def = "VARCHAR(8) NULL DEFAULT NULL"},
            {table = usersTable,   column = "garage_limit",      def = "INT(10) NOT NULL DEFAULT 7"},
        }

        for _, c in ipairs(columns) do
            if ensureColumn(c.table, c.column, c.def) then
                table.insert(created, c.table.."."..c.column)
            end
        end

        if Config.VehicleKeys.ENABLE then
            local tableQuery = [[
                CREATE TABLE `cd_garage_keys` (
                    `plate` VARCHAR(8) NOT NULL,
                    `owner_identifier` VARCHAR(50) NOT NULL,
                    `reciever_identifier` VARCHAR(50) NOT NULL,
                    `owner_name` VARCHAR(50) NOT NULL,
                    `reciever_name` VARCHAR(50) NOT NULL,
                    `model` VARCHAR(50) NOT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]

            if ensureTable("cd_garage_keys", tableQuery) then
                table.insert(created, "cd_garage_keys")
            end
        end

        if Config.PrivateGarages.ENABLE then
            local tableQuery = [[
                CREATE TABLE `cd_garage_privategarage` (
                    `identifier` VARCHAR(50) NOT NULL,
                    `data` LONGTEXT NOT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
            if ensureTable("cd_garage_privategarage", tableQuery) then
                table.insert(created, "cd_garage_privategarage")
            end
        end

        if Config.PersistentVehicles.ENABLE then
            local tableQuery = [[
                CREATE TABLE `cd_garage_persistentvehicles` (
                    `persistent` LONGTEXT NOT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]]
            if ensureTable("cd_garage_persistentvehicles", tableQuery) then
                DB.exec("INSERT INTO cd_garage_persistentvehicles (persistent) VALUES ('{}')")
                table.insert(created, "cd_garage_persistentvehicles")
            end
        end
    end

    -- Check and automatically fix data
    if Config.PersistentVehicles.ENABLE then
        local result = DB.fetch("SELECT persistent FROM cd_garage_persistentvehicles LIMIT 1")
        if not result or not result[1] then
            DB.exec("INSERT INTO cd_garage_persistentvehicles (persistent) VALUES ('{}')")
            table.insert(fixed, "cd_garage_persistentvehicles.persistent (missing row -> inserted '{}')")
        else
            local data = result[1].persistent
            if not data or data == "" then
                DB.exec("UPDATE cd_garage_persistentvehicles SET persistent = '{}' ")
                table.insert(fixed, "cd_garage_persistentvehicles.persistent (empty/NULL -> set '{}')")
            end
        end
    end

    -- Auto update keys database since the structure was modified in a recent update.
    if Config.VehicleKeys.ENABLE then
        local dropCharName = false

        if ensureColumn("cd_garage_keys", "owner_name", "VARCHAR(50) NOT NULL") then
            dropCharName = true
            table.insert(fixed, "cd_garage_keys.owner_name")
        end

        if ensureColumn("cd_garage_keys", "reciever_name", "VARCHAR(50) NOT NULL") then
            dropCharName = true
            table.insert(fixed, "cd_garage_keys.reciever_name")
        end

        if dropCharName then
            DB.exec("ALTER TABLE cd_garage_keys DROP COLUMN char_name;")
            DB.exec("TRUNCATE TABLE cd_garage_keys;")
        end

        if ensureColumn("cd_garage_keys", "model", "VARCHAR(50) NOT NULL") then
            table.insert(fixed, "cd_garage_keys.model")
        end
    end

    if #fixed > 0 then
        Citizen.Trace('^5--------------------------^0\n')
        Citizen.Trace('^5[cd_garage]^0 Auto-fixed SQL data:\n')
        for _, cd in ipairs(fixed) do
            Citizen.Trace('  - ^3'..cd..'^0\n')
        end
        Citizen.Trace('^5--------------------------^0\n')
    end

    if #created > 0 then
        Citizen.Trace('^5--------------------------^0\n')
        Citizen.Trace('^5[cd_garage]^0 Created/updated SQL structures:\n')
        for _, cd in ipairs(created) do
            Citizen.Trace('  - ^3'..cd..'^0\n')
        end
        Citizen.Trace('^5--------------------------^0\n')
    else
        if Config.Debug then
            Citizen.Trace('^2[cd_garage]^0 All SQL tables and columns already exist.\n')
        end
    end
end
