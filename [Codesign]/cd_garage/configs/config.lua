Config = {}

for c, d in pairs(Cfg) do
    Config[c] = d
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            IMPORTANT                             │
-- └──────────────────────────────────────────────────────────────────┘

-- WHAT DOES 'auto_detect' DO?
-- Automatically detects key resources and manages all events, exports, and data handling.

Config.AutoInsertSQL = true --Recommended to enable before updating the script.
Config.Debug = false --To enable debug prints.
Config.VehicleDataDebugPrints = false --Enable to see debug prints related to vehicle data fetching.
Config.GarageInteractMethod = 'target' --[ 'textui', 'target' ]Config.IdentifierType = 'license' --[ 'steamid' / 'license' ] Choose the identifier type that your server uses.
Config.PlayerListMethod = 'both' --[ 'both' / 'charname' / 'source' ] --Choose how you want the player list to be displayed in the garage UI. 'both' will show both character name and source, 'charname' will only show character name, and 'source' will only show source.

Config.VehiclePlateFormats = {
    format = 'mixed', --[ 'trimmed',  'with_spaces', 'mixed' ] --Mixed is generally the one your server will use.
    new_plate_format = 'AAAA1111' --Customise the plate formats of newly generated plates. ['A'] = Random Letter, ['1'] = Random Number, [' '] = Whitespace, ['-'] = Dash. Maximun length is 8 including symbols and whitespaces.
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                             MAIN                                 │
-- └──────────────────────────────────────────────────────────────────┘

Config.Keys = {
    QuickChoose_Key = Config.Keys['E'], --The key to open the quick garage (default E).
    EnterGarage_Key = Config.Keys['H'], --The key to open the inside garage (default H).
    StoreVehicle_Key = Config.Keys['G'], --The key to store your vehicle (default G).
    GarageRaid_Key = Config.Keys['K'], --The key to raid a garage (default K).
    StartHotwire_Key = Config.Keys['E'] --The key to start hotwiring a vehicle (default E).
}

Config.UniqueGarages = true --Do you want to only be able to get your car from the garage you last put it in?
Config.SaveAdvancedVehicleDamage = true --Do you want to save poped tyres, broken doors and broken windows and re-apply them all when spawning a vehicle?
Config.UseExploitProtection = false --Do you want to enable the cheat engine protection to check the vehicle hashes when a vehicle is stored?
Config.ResetGarageState = false --Do you want vehicles to be returned to the garage when the script starts/restarts? Auto disabled if using persistent vehicles.
Config.SpawnGaragePeds = true -- Do you want peds to spawn in the area where a garage is located?
Config.CanSpawnWhenDestroyed = false --Do you want to allow players to spawn their vehicle from the garage if the vehicle is destroyed?.

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          VEHICLES DATA                           │
-- └──────────────────────────────────────────────────────────────────┘

Config.GarageTax = {
    ENABLE = false, --Do you want to enable the vehicle tax system? (each vehicle will be taxed 1 time per server restart).
    method = 'default', --[ 'default' / 'vehicles_data' ] Read below for more info on each on these 2 options.
    default_price = 1000, --If 'default' method is chosen, then it will be a set price to return any vehicle. (eg., $500 fee).
    vehiclesdata_price_multiplier = 1 --If 'vehicles_data' method is chosen, the return vehicle price will be a % of the vehcles value. (eg., 1% of a $50,000 car would be a $500 fee).
}

Config.Return_Vehicle = {
    ENABLE = true, --Do you want to allow players to return their vehicle if it has despawned?
    method = 'default', --[ 'default' / 'vehicles_data' ] Read below for more info on each on these 2 options.
    default_price = 500, --If 'default' method is chosen, then it will be a set price to return any vehicle. (eg., $500 fee).
    vehiclesdata_price_multiplier = 1 --If 'vehicles_data' method is chosen, the return vehicle price will be a % of the vehcles value. (eg., 1% of a $50,000 car would be a $500 fee).
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          IMPOUND                                 │
-- └──────────────────────────────────────────────────────────────────┘ 

Config.Impound = {
    ENABLE = true, --Do you want to use the built in impound system?
    chat_command = 'impound', --Customise the chat command to impound vehicles.

    Authorized_Jobs = { --Only jobs inside this table can impound vehicles or unimpound vehicles.
        ['police'] = true,
        ['mechanic'] = true,
        --['add_more_here'] = true,
    },

    Impound_Fee = { --This is the price players pay for their vehicle to be unimpounded.
        method = 'default', --[ 'default' / 'vehicles_data' ] Read below for more info on each of these 2 options.
        default_price = 1000, --If 'default' method is chosen, then it will be a set price to unimpounded any vehicle. (eg., $1000 fee).
        vehiclesdata_price_multiplier = 1 --If 'vehicles_data' method is chosen, the unimpounded vehicle price will be a % of the vehcles value. (eg., 1% of a $50,000 car would be a $500 fee).
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                        TRANSFER VEHICLE                          │
-- └──────────────────────────────────────────────────────────────────┘

Config.TransferVehicle = {
    ENABLE = true, --Do you want to use the built features to transfer vehicles to another player?
    chat_command = 'transfervehicle', --Customise the chat command to transfer vehicles.

    Transfer_Blacklist = { --Vehicles inside this table will not be able to be transfered to another player. Use the vehicles spawn name. eg., `adder`.
        [`dump`] = true,
        --[`add_more_here`] = true,
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         TRANSFER GARAGE                          │
-- └──────────────────────────────────────────────────────────────────┘

Config.TransferGarage = {
    ENABLE = true, --Do you want to allow players to pay for their vehicles to be transferred to another garage?
    transfer_to_property_garage = true, --Do you want to allow players to transfer their vehicles to their property garage?
    transfer_fee = 750 --The cost per vehicle garage transfer ^.
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         PRIVATE GARAGE                           │
-- └──────────────────────────────────────────────────────────────────┘

Config.PrivateGarages = {
    ENABLE = false, --Do you want to use the built private garages?
    create_chat_command = 'privategarage', --Customise the chat command to create a private garage to sell to a player.
    delete_chat_command = 'privategaragedelete', --Customise the chat command to delete a players private garage.

    Authorized_Jobs = { --Only jobs inside this table can use the command above.
        ['police'] = true,
        --['add_more_here'] = true,
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           FAKE PLATES                            │
-- └──────────────────────────────────────────────────────────────────┘

Config.FakePlates = {
    ENABLE = false, --Do you want to use the built in fake plate system?
    item_name = 'fakeplate', --The name of the usable item to add a fake plate.

    RemovePlate = {
        chat_command = 'removefakeplate', --Customise the chat command to remove a fake plate from a vehicle.
        allowed_jobs = {
            ENABLE = false, --Do you want to allow certain jobs to remove a fake plate? (the vehicles owner will always be able to remove plates).
            table = { --The list of jobs who can remove a fake plate.
                ['police'] = true,
                --['add_more_here'] = true,
            }
        }
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                             KEYS                                 │
-- └──────────────────────────────────────────────────────────────────┘

Config.VehicleKeys = {
    ENABLE = false, --Do you want to use the built in vehicle keys system?
    allow_shared_vehicles = false, --If this is enabled, when you give another player a "saved" key to one of your vehicles, it will allow them to spawn your vehicles from their garage.
    command = 'keys', --Command to view the keys UI where you can view, add or remove keys.
    give_key_command = 'givekey', --Command to give a player keys to a vehicle you own.

    Hotwire = {
        ENABLE = true, --Do you want players to only be able to drive vehicles they have the keys for?

        --seconds: (1-10) How many seconds it takes for the bar to reach from 1 side to the other. (less is faster).
        --size: (10-100) How wide the target bar is. (100 is widest and easiest to hit).
        --chances: How many chances you have on each action bar. (1 means if you fail the first time it cancels, 2 means if you fail the first and second time it cancels).
        ActionBar = {
            [1] = {seconds = 6, size = 30, chances = 3}, --Choose how many seperate action bars you will need to complete to hotwire a vehicle you do not have keys for.
            [2] = {seconds = 3, size = 20, chances = 2},
            [3] = {seconds = 2, size = 10, chances = 1}, --This is the 3rd action bar.
            --[4] = {seconds = 1, size = 10, chances = 1},
        }
    },

    Lock = {
        ENABLE = true, --Do you want to use the vehicle locking system?
        lock_from_inside = true, --Do you want to also lock the vehicle from the inside when the vehicle is locked? (meaning when the vehicle is locked players can not exit).
        command = 'vehlock', --Customise the chat command.
        key = 'm' --Customise the key.
    },

    Lockpick = {
        ENABLE = true, --Do you want to use the vehicle lockpick system?
        command = { --Do you want players to use a chat command to start lockpicking a vehicle?
            ENABLE = true,
            chat_command = 'lockpick' --Customise the chat command.
        },
        usable_item = { --Do you want players to use a usable item to lockpick a vehicle?
            ENABLE = true,
            item_name = 'lockpick' --The name of the usable item to start lockpicking a vehicle.
        }
    },
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            MILEAGE                               │
-- └──────────────────────────────────────────────────────────────────┘

Config.Mileage = {
    ENABLE = true, --Do you want to use the built in vehicle mileage system? The higher the miles the lower the vehicles max health will be. (or you can repurpose this for any other use).
    chat_command = 'checkmiles', --Customise the chat command to check your vehicles miles and max health.
    mileage_multiplier = 1.0, --If you increase this number it will increase how fast vehicles gain miles. (decrease to lower).
    speed_metrics = 'miles', --(miles/kilometers) Choose what you want the mileage to display as.
    show_maxhealth = false --Do you want to show the max health of the vehicle you are in when you use the /checkmiles command?
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                       PERSISTENT VEHICLES                        │
-- └──────────────────────────────────────────────────────────────────┘

Config.PersistentVehicles = { --Requires OneSync to use.
    ENABLE = false, --Do you want to use the built-in persistent vehicle feature?
    SaveAfterRestart = {
        ENABLE = true, --Do you want vehicles to be saved and restored after a server restart?
        save_regular_job_vehicles = true, --Do you want regular job vehicles spawned from cd_garage to be saved and restored after a server restart?
        save_owned_job_vehicles = true --Do you want personal or society owned job vehicles to be saved and restored after a server restart?
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         GARAGE RAID                              │
-- └──────────────────────────────────────────────────────────────────┘

Config.GarageRaid = {
    ENABLE = false, --Allow police to search by plate for a vehicle in a garage.
    required_perms = {
        ['police'] = 0, --The job and minimum grade required to raid a garage. (eg., ['police'] = { 1 } means police job, grade 1 or higher).
        ['sheriff'] = 1,
        --['add_more_here'] = 1,
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          JOB VEHICLES                            │
-- └──────────────────────────────────────────────────────────────────┘

Config.JobVehicles = {
    ENABLE = true, --Do you want players with defined jobs (below) to be able to use the garage ui to spawn job vehicles? (if disabled none of the options below will be used).
    choose_liverys = false, --Do you want players to be able to change liverys when they spawn a vehicle at a job garage?
    share_job_keys = true, --Do you want job vehicle keys to be automatically shared with other players with the same job? (requires you to be using the built in cd_garage keys feature).

    Locations = {
        --coords: Where the job garage can be accessed from.
        --spawn_coords: Where the chosen vehicle will spawn.
        --distance: If the player is within the 'distance' of these coords ^, they can open the job garage UI.
        --garage_type: The type of vehicles that can be accessed from this location.
        --method: There are 3 different methods you can use (all 3 are explained below).

            --'regular' = This will use the vehicles from the Config.JobVehicles.RegularMethod table below. These are spawned in vehicles and are not owned by anyone.
            --'personalowned' = This will use your personal job vehicles that you have purchased from the cardealer and only you can only access from your job spawn location. Vehicles in your owned_vehicles database table which have job_personalowned set to a players "job name" (not "job label") will be classed as personal owned job vehicles.
            --'societyowned' = This will use society owned vehicles. This will search for your job instead of your steam/license identifier in the owned_vehicles database table and allow you to use all of the vehicles your job owns.

        ['police'] = { --If you choose to add more tables here for more jobs, they must be the jobs name, not the label.
            --MISSION ROW PD
            [1] = {coords = vector3(451.27, -1016.05, 28.48), spawn_coords = vector4(450.19, -1021.18, 28.4, 93.47), distance = 10, garage_type = 'car', method = 'regular'}, --Mission Row PD (cars)
            [2] = {coords = vector3(449.27, -981.24, 43.69), spawn_coords = vector4(449.27, -981.24, 43.69, 94.13), distance = 5, garage_type = 'air', method = 'regular'}, --Mission Row PD (helipad)
            --SANDY PD
            [3] = {coords = vector3(1868.33, 3686.05, 33.78), spawn_coords = vector4(1872.68, 3687.19, 33.65, 211.34), distance = 10, garage_type = 'car', method = 'regular'}, --Sandy PD (cars)
            [4] = {coords = vector3(1866.09, 3655.66, 33.9), spawn_coords = vector4(1866.09, 3655.66, 33.9, 27.07), distance = 5, garage_type = 'air', method = 'regular'}, --Sandy PD (helipad)
            --PALETO PD
            [5] = {coords = vector3(-463.43, 6039.67, 31.34), spawn_coords = vector4(-459.3, 6042.86, 31.34, 134.85), distance = 10, garage_type = 'car', method = 'regular'}, --Paleto PD (cars)
            [6] = {coords = vector3(-466.82, 5997.14, 31.25), spawn_coords = vector4(-475.41, 5988.47, 31.34, 318.3), distance = 5, garage_type = 'air', method = 'regular'}, --Paleto PD (helipad)
            --BOATS
            [7] = {coords = vector3(-1598.49, -1201.4, 0.82), spawn_coords = vector4(-1609.96, -1210.83, -0.03, 134.45), distance = 20, garage_type = 'boat', method = 'regular'}, --Vespucci Beach (boats)
            [8] = {coords = vector3(1426.31, 3750.12, 31.76), spawn_coords = vector4(1430.37, 3771.52, 29.86, 336.36), distance = 20, garage_type = 'boat', method = 'regular'}, --Sandy Lake (boats)
        },
        ['ambulance'] = {
            --PILLBOX HOSPITAL
            [1] = {coords = vector3(294.35, -607.89, 43.33), spawn_coords = vector4(294.35, -607.89, 43.33, 74.04), distance = 10, garage_type = 'car', method = 'regular'}, --Pillbox Hospital (cars)
            [2] = {coords = vector3(352.22, -588.03, 74.17), spawn_coords = vector4(352.22, -588.03, 74.17, 74.5), distance = 10, garage_type = 'air', method = 'regular'}, --Pillbox Hospital (helipad)
            --Sandy MEDICAL
            [3] = {coords = vector3(1808.53, 3677.7, 34.28), spawn_coords = vector4(1805.42, 3681.13, 34.22, 298.45), distance = 10, garage_type = 'car', method = 'regular'}, --Sandy Medical (cars)
            [4] = {coords = vector3(1830.74, 3634.77, 34.39), spawn_coords = vector4(1830.74, 3634.77, 34.39, 29.63), distance = 10, garage_type = 'air', method = 'regular'}, --Sandy Medical (helipad)
        },
    },

    --This will only be used if any of the 'method'(s) in the table above are set to use 'regular' job vehicles.
    RegularMethod = {
        --job: The job name, not job label.
        --spawn_max: Do you want the vehicles to spawn fully upgraded (performance wise)?.
        --plate: The script fills in the rest of the plate characters with random numbers (up to 8 characters max), so for example 'PD' would be 'PD425424'.
        --job_grade: The minimum a players job grade must be to have access to this vehicle.
        --garage_type: What type of vehicle this is ('car' / 'boat', 'air').
        --model: The spawn name of this vehicle. (this is not supposed to be a string, these symbols get the hash key of this vehicle).

        ['police'] = {
            [1] = {job = 'police', spawn_max = true, plate = 'PD', job_grade = 0, garage_type = 'car', model = `police`},
            [2] = {job = 'police', spawn_max = true, plate = 'PD', job_grade = 0, garage_type = 'car', model = `police2`},
            [3] = {job = 'police', spawn_max = true, plate = 'PD', job_grade = 0, garage_type = 'car', model = `police3`},

            [4] = {job = 'police', spawn_max = true, plate = 'PD', job_grade = 0, garage_type = 'air', model = `polmav`},

            [5] = {job = 'police', spawn_max = true, plate = 'PD', job_grade = 0, garage_type = 'boat', model = `predator`},
        },
        ['ambulance'] = {
            [1] = {job = 'ambulance', spawn_max = true, plate = 'EMS', job_grade = 0, garage_type = 'car', model = `ambulance`},
            [2] = {job = 'ambulance', spawn_max = true, plate = 'EMS', job_grade = 0, garage_type = 'air', model = `polmav`},
        },
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GANG GARAGES                           │
-- └──────────────────────────────────────────────────────────────────┘

Config.GangGarages = {
    ENABLE = false, --Do you want players in defined gangs to be able to use this specific gang garage?
    not_in_gang_name = 'none', --What's the "gang" name if a player isn't part of a gang? (eg., when a player dosnt have a job, their job name is usually "unemployed"). ("none" is the default on qbcore).

    Blip = { --You can find more info on blips here - https://docs.fivem.net/docs/game-references/blips.
        sprite = 84, --Icon of the blip.
        scale = 0.6, --Size of the blip.
        colour = 22, --Colour of the blip.
        name = Locale('gang_garage')..': ' --You dont need to change this.
    },

    Locations = {
        --gang: The gang name, not gang label.
        --garage_id: The unique id of the garage (this can not be named same as other normal garages).
        --coords: Where the gang garage can be accessed from.
        --spawn_coords: Where the chosen vehicle will spawn.
        --distance: If the player is within the 'distance' of these coords ^, they can open the gang garage UI.
        --garage_type: The type of vehicles that can be accessed from this location ('car' / 'boat', 'air').

        [1] = {gang = 'ballas', garage_id = 'Ballas', coords = vector3(102.48, -1955.1, 20.73), spawn_coords = vector4(104.51, -1954.2, 20.27, 336.53), distance = 10, garage_type = 'car'}, --GROVE STREET
        --[2] = {gang = 'CHANGE_ME', garage_id = 'CHANGE_ME', coords = vector3(0.0, 0.0, 0.0), spawn_coords = vector4(0.0, 0.0, 0.0, 0.0), distance = 10, garage_type = 'car'},
    },
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         PROPERTY GARAGE                          │
-- └──────────────────────────────────────────────────────────────────┘

Config.PropertyGarages = {
    ENABLE = true, --Do you want to use built in property garages?
    only_showcars_inpropertygarage = false --Do you want the inside garage to only show the vehicles which are currently stored in a property garage. (this works for inside garage only, even with this enabled all the cars will show in the outside UI).
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         GARAGE SPACE                             │
-- └──────────────────────────────────────────────────────────────────┘

Config.GarageSpace = {
    ENABLE = false, --Do you want to limit the amount of cars each player can hold?
    chat_command_main = 'garagespace', --Customise the chat command to purchase extra garage space.
    chat_command_check = 'checkgaragespace', --Customise the chat command to check how many garage slots you have.

    Garagespace_Table = { --If Config.TransferGarage.ENABLE is enabled, this is the max amount of cars each player can own. To allow people to own more vehicles, add them to the table.
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 25000,
        [9] = 50000,
        [10] = 75000,
        --[11] = 100000, --The number 11 would be the 11th garage slot, and the 100000 number would be the price for the 11th garage slot.
    },

    Authorized_Jobs = { --Only jobs inside this table can sell extra garage slots to players.
        ['cardealer'] = true,
        --['add_more_here'] = true,
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         INSIDE GARAGE                            │
-- └──────────────────────────────────────────────────────────────────┘

Config.InsideGarage = {
    ENABLE = false, --Do you want to allow players to use the inside garage?
    only_showcars_inthisgarage = false, --Do you want the inside garage to only show the vehicles which are currently stored at that garage (eg., garage A).  (this works for inside garage only, even with this enabled all the cars will show in the outside UI).
    shell_z_axis = 30, --This is how low under the ground the garage shell will spawn.
    engines_on = false, --Do you want the vehicles engine will be turned on when you enter the inside garage?
    lights_on = false, --Do you want the vehicles headlights will be turned on when you enter the inside garage?
    use_spotlight = true, --Do you want the spotlight to shine on the closest vehicle?

    Insidegarage_Blacklist = { --Vehicles inside this table will not be spawned inside the garage, this is used for large vehicles that will not fit.
        [`flatbed`] = true,
        --[`add_more_here`] = true,
    },

    Car_Offsets = { --This is the offsets of the vehicles inside the garage.
        ['10cargarage_shell'] = {
            [1] = {x = -4, y = 6.5, z = 0.0, h = 135.0},--1
            [2] = {x = -4, y = 10.8, z = 0.0, h = 135.0},--2
            [3] = {x = -4, y = 15.1, z = 0.0, h = 135.0},--3
            [4] = {x = -4, y = 19.4, z = 0.0, h = 135.0},--4
            [5] = {x = -4, y = 23.7, z = 0.0, h = 135.0},--5

            [6] = {x = -12, y = 23.7, z = 0.0, h = 225.0},--6
            [7] = {x = -12, y = 19.4, z = 0.0, h = 225.0},--7
            [8] = {x = -12, y = 15.1, z = 0.0, h = 225.0},--8
            [9] = {x = -12, y = 10.8, z = 0.0, h = 225.0},--9
            [10] = {x = -12, y = 6.5, z = 0.0, h = 225.0}--10
        },

        ['40cargarage_shell'] = {
            [1] = {x = 7.0, y = -7.0, z = 0.0, h = 352.0},--1
            [2] = {x = 11.0, y = -8.0, z = 0.0, h = 352.0},--2
            [3] = {x = 15.0, y = -9.0, z = 0.0, h = 352.0},--3
            [4] = {x = 19.0, y = -10.0, z = 0.0, h = 352.0},--4
            [5] = {x = 23.0, y = -11.0, z = 0.0, h = 352.0},--5
            [6] = {x = 27.0, y = -12.0, z = 0.0, h = 352.0},--6
            [7] = {x = 31.0, y = -13.0, z = 0.0, h = 352.0},--7
            [8] = {x = 35.0, y = -14.0, z = 0.0, h = 352.0},--8
            [9] = {x = 39.0, y = -15.0, z = 0.0, h = 352.0},--9
            [10] = {x = 43.0, y = -16.0, z = 0.0, h = 352.0},--10

            [11] = {x = 7.0, y = 5.0, z = 0.0, h = 162.0},--11
            [12] = {x = 11.0, y = 4.0, z = 0.0, h = 162.0},--12
            [13] = {x = 15.0, y = 3.0, z = 0.0, h = 162.0},--13
            [14] = {x = 19.0, y = 2.0, z = 0.0, h = 162.0},--14
            [15] = {x = 23.0, y = 1.0, z = 0.0, h = 162.0},--15
            [16] = {x = 27.0, y = 0.0, z = 0.0, h = 162.0},--16
            [17] = {x = 31.0, y = -1.0, z = 0.0, h = 162.0},--17
            [18] = {x = 35.0, y = -2.0, z = 0.0, h = 162.0},--18
            [19] = {x = 39.0, y = -3.0, z = 0.0, h = 162.0},--19
            [20] = {x = 43.0, y = -4.0, z = 0.0, h = 162.0},--20

            [21] = {x = -7.0, y = 5.0, z = 0.0, h = 192.0},--21
            [22] = {x = -11.0, y = 4.0, z = 0.0, h = 192.0},--22
            [23] = {x = -15.0, y = 3.0, z = 0.0, h = 192.0},--23
            [24] = {x = -19.0, y = 2.0, z = 0.0, h = 192.0},--24
            [25] = {x = -23.0, y = 1.0, z = 0.0, h = 192.0},--25
            [26] = {x = -27.0, y = 0.0, z = 0.0, h = 192.0},--26
            [27] = {x = -31.0, y = -1.0, z = 0.0, h = 192.0},--27
            [28] = {x = -35.0, y = -2.0, z = 0.0, h = 192.0},--28
            [29] = {x = -39.0, y = -3.0, z = 0.0, h = 192.0},--29
            [30] = {x = -43.0, y = -4.0, z = 0.0, h = 192.0},--30

            [31] = {x = -7.0, y = -7.0, z = 0.0, h = 13.0},--31
            [32] = {x = -11.0, y = -8.0, z = 0.0, h = 13.0},--32
            [33] = {x = -15.0, y = -9.0, z = 0.0, h = 13.0},--33
            [34] = {x = -19.0, y = -10.0, z = 0.0, h = 13.0},--34
            [35] = {x = -23.0, y = -11.0, z = 0.0, h = 13.0},--35
            [36] = {x = -27.0, y = -12.0, z = 0.0, h = 13.0},--36
            [37] = {x = -31.0, y = -13.0, z = 0.0, h = 13.0},--37
            [38] = {x = -35.0, y = -14.0, z = 0.0, h = 13.0},--38
            [39] = {x = -39.0, y = -15.0, z = 0.0, h = 13.0},--39
            [40] = {x = -43.0, y = -16.0, z = 0.0, h = 13.0},--40
        }
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                             BLIPS                                │
-- └──────────────────────────────────────────────────────────────────┘

Config.Unique_Blips = true --Do you want each garage to be named by its unique id, for example: 'Garage A'? (If disabled all garages will be called 'Garage').
Config.Blip = { --You can find more info on blips here - https://docs.fivem.net/docs/game-references/blips.
    ['car'] = {
        sprite = 357, --Icon of the blip.
        scale = 0.6, --Size of the blip.
        colour = 9, --Colour of the blip.
        name = Locale('garage')..' ' --You dont need to change this.
    },

    ['boat'] = {
        sprite = 357,
        scale = 0.6,
        colour = 9,
        name = Locale('harbor')..' '
    },

    ['air'] = {
        sprite = 357,
        scale = 0.6,
        colour = 9,
        name = Locale('hangar')..' '
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         STAFF COMMANDS                           │
-- └──────────────────────────────────────────────────────────────────┘

Config.StaffPerms = {
    ['add'] = {
        ENABLE = true, --Do you want to allow staff to add vehicles to a players garage?
        chat_command = 'vehicle-add', --Customise the chat commands.
        perms = {
            ['esx'] = {'superadmin', 'admin'}, --You decide which permission groups can use the staff commands.
            ['qbcore'] = {'god', 'admin'},
            ['qbox'] = {'god', 'admin'},
            ['other'] = {'change_me'}
        }
    },

    ['delete'] = {
        ENABLE = true, --Do you want to allow staff to delete vehicles from the database?
        chat_command = 'vehicle-delete',
        perms = {
            ['esx'] = {'superadmin', 'admin'},
            ['qbcore'] = {'god', 'admin'},
            ['qbox'] = {'god', 'admin'},
            ['other'] = {'change_me'}
        }
    },

    ['plate'] = {
        ENABLE = true, --Do you want to allow staff to change a vehicles plate?
        chat_command = 'vehicle-plate',
        perms = {
            ['esx'] = {'superadmin', 'admin'},
            ['qbcore'] = {'god', 'admin'},
            ['qbox'] = {'god', 'admin'},
            ['other'] = {'change_me'}
        }
    },

    ['keys'] = {
        ENABLE = true, --Do you want to allow staff to give theirself keys to a vehicle?
        chat_command = 'vehicle-keys',
        perms = {
            ['esx'] = {'superadmin', 'admin'},
            ['qbcore'] = {'god', 'admin'},
            ['qbox'] = {'god', 'admin'},
            ['other'] = {'change_me'}
        }
    }
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          GARAGE LOCATIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

local UIText
if Config.InsideGarage.ENABLE then
    UIText = '<b>'..Locale('garage')..'</b></p>'..Locale('open_garage_1')..'</p>'..Locale('open_garage_2').. '</p>'..Locale('notif_storevehicle')
else
    UIText = '<b>'..Locale('garage')..'</b></p>'..Locale('open_garage_1')
end

Config.Locations = {
    {
        Garage_ID = 'A', --The very first car garage's `garage_id` must be the same as the default value of the `garage_id` in the database as when a vehicle is purchased it gets sent to this garage. You can change the garage id's to what ever you like but make sure to also change the default garage_id in the database.
        Type = 'car', --The type of vehicles which use this garage. ('car'/'boat'/'air').
        Dist = 10, --The distance that you can use this garage.
        x_1 = 215.09, y_1 = -805.17, z_1 = 30.81, --This is the location of the garage, where you press e to open for example.
        EventName1 = 'cd_garage:QuickChoose', --DONT CHANGE THIS.
        EventName2 = 'cd_garage:EnterGarage', --DONT CHANGE THIS.
        Name = UIText, --You dont need to change this.
        x_2 = 212.42, y_2 = -798.77, z_2 = 30.88, h_2 = 336.61, --This is the location where the vehicle spawns.
        EnableBlip = true, --If disabled, this garage blip will not show on the map.
        JobRestricted = nil, --This will allow only players with certain jobs to use this. This is not a job garage, its still a normal garage. (SINGLE JOB EXAMPLE:  JobRestricted = {'police'},  MULTIPLE JOBS EXAMPLE:  JobRestricted = {'police', 'ambulance'}, )
        ShellType = '10cargarage_shell', --[ '10cargarage_shell' / '40cargarage_shell' / nil ] --You can choose the shell which is loaded when you enter the inside garage from this location. If you set it to nil the script will load a shell based on the amount of cars you own.
    },

    {
        Garage_ID = 'B', --PINK MOTEL
        Type = 'car',
        Dist = 10,
        x_1 = 273.0, y_1 = -343.85, z_1 = 44.91,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 270.75, y_2 = -340.51, z_2 = 44.92, h_2 = 342.03,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'C', --GROVE
        Type = 'car',
        Dist = 10,
        x_1 = -71.46, y_1 = -1821.83, z_1 = 26.94,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = -66.51, y_2 = -1828.01, z_2 = 26.94, h_2 = 235.64,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'D', --MIRROR
        Type = 'car',
        Dist = 10,
        x_1 = 1032.84, y_1 = -765.1, z_1 = 58.18,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 1023.2, y_2 = -764.27, z_2 = 57.96, h_2 = 319.66,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'E', --BEACH
        Type = 'car',
        Dist = 10,
        x_1 = -1248.69, y_1 = -1425.71, z_1 = 4.32,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = -1244.27, y_2 = -1422.08, z_2 = 4.32, h_2 = 37.12,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'F', --G O HIGHWAY
        Type = 'car',
        Dist = 10,
        x_1 = -2961.58, y_1 = 375.93, z_1 = 15.02,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = -2964.96, y_2 = 372.07, z_2 = 14.78, h_2 = 86.07,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'G', --SANDY WEST
        Type = 'car',
        Dist = 10,
        x_1 = 217.33, y_1 = 2605.65, z_1 = 46.04,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 216.94, y_2 = 2608.44, z_2 = 46.33, h_2 = 14.07,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'H', --SANDY MAIN
        Type = 'car',
        Dist = 10,
        x_1 = 1878.44, y_1 = 3760.1, z_1 = 32.94,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 1880.14, y_2 = 3757.73, z_2 = 32.93, h_2 = 215.54,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'I', --VINEWOOD
        Type = 'car',
        Dist = 10,
        x_1 = 365.21, y_1 = 295.65, z_1 = 103.46,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 364.84, y_2 = 289.73, z_2 = 103.42, h_2 = 164.23,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'J', --GRAPESEED
        Type = 'car',
        Dist = 10,
        x_1 = 1713.06, y_1 = 4745.32, z_1 = 41.96,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 1710.64, y_2 = 4746.94, z_2 = 41.95, h_2 = 90.11,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },

    {
        Garage_ID = 'K', --PALETO
        Type = 'car',
        Dist = 10,
        x_1 = 107.32, y_1 = 6611.77, z_1 = 31.98,
        EventName1 = 'cd_garage:QuickChoose',
        EventName2 = 'cd_garage:EnterGarage',
        Name = UIText,
        x_2 = 110.84, y_2 = 6607.82, z_2 = 31.86, h_2 = 265.28,
        EnableBlip = true,
        JobRestricted = nil,
        ShellType = '10cargarage_shell',
    },






    {   --THIS IS A BOAT GARAGE, YOU CAN REMOVE OR ADD NEW BOAT GARAGES IF YOU WISH.
        Garage_ID = 'A', --The very first boat garage's `garage_id` must be the same as the default value of the garage_id in the database as when a vehicle is purchased it gets sent to this garage.
        Type = 'boat',
        Dist = 20,
        x_1 = -806.22, y_1 = -1496.7, z_1 = 1.6,
        EventName1 = 'cd_garage:QuickChoose',
        Name = '<b>'..Locale('harbor')..'</b></p>'..Locale('open_garage_3'),
        x_2 = -811.54, y_2 = -1509.42, z_2 = -0.47, h_2 = 130.14,
        EnableBlip = true,
        JobRestricted = nil,
    },

    {   --THIS IS AN AIR GARAGE, YOU CAN REMOVE OR ADD NEW AIR GARAGES IF YOU WISH.
        Garage_ID = 'A', --The very first air garage's `garage_id` must be the same as the default value of the `garage_id` in the database as when a vehicle is purchased it gets sent to this garage.
        Type = 'air',
        Dist = 10,
        x_1 = -982.55, y_1 = -2993.94, z_1 = 13.95,
        EventName1 = 'cd_garage:QuickChoose',
        Name = '<b>'..Locale('hangar')..'</b></p>'..Locale('open_garage_4'),
        x_2 = -989.59, y_2 = -3004.93, z_2 = 13.94, h_2 = 58.15,
        EnableBlip = true,
        JobRestricted = nil,
    },
}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                        IMPOUND LOCATIONS                         │
-- └──────────────────────────────────────────────────────────────────┘

Config.ImpoundLocations = { --DO NOT CHANGE THE TABLE IDENTIFIERSs, for example - ['car_2'], if you wish to add more, then name the next one ['car_3']. It must have either 'car'/'boat'/'air' in the name and also be unique.
    ['car_1'] = {
        ImpoundID = 1, --The unique id of the impound.
        coords = {x = 401.28, y = -1631.44, z = 29.29}, --This is the location of the garage, where you press e to open for example.
        spawnpoint = {x = 404.66, y = -1642.03, z = 29.29, h = 225.5}, --This is the location where the vehicle spawns.
        blip = {
            sprite = 357, --Icon of the blip.
            scale = 0.5, --Size of the blip.
            colour = 3, --Colour of the blip.
            name = Locale('car_city_impound'), --This can be changed in the Locales.
        }
    },

    ['car_2'] = {
        ImpoundID = 2,
        coords = {x = 1893.48, y = 3713.50, z = 32.77},
        spawnpoint = {x = 1887.123, y = 3710.348, z = 31.92, h = 212.0},
        blip = {
            sprite = 357,
            scale = 0.5,
            colour = 3,
            name = Locale('car_sandy_impound'),
        }
    },

    ['boat_1'] = {
        ImpoundID = 3,
        coords = {x = -848.8, y = -1368.42, z = 1.6},
        spawnpoint = {x = -848.4, y = -1362.8, z = -0.47, h = 113.0},
        blip = {
            sprite = 357,
            scale = 0.5,
            colour = 3,
            name = Locale('boat_impound'),
        }
    },

    ['air_1'] = {
        ImpoundID = 4,
        coords = {x = -956.49, y = -2919.74, z = 13.96},
        spawnpoint = {x = -960.22, y = -2934.4, z = 13.95, h = 153.0},
        blip = {
            sprite = 357,
            scale = 0.5,
            colour = 3,
            name = Locale('air_impound'),
        }
    },
}