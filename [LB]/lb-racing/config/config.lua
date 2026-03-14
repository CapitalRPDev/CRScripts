Config = {}

Config.Debug = false
Config.Language = "en"
Config.CurrencyFormat = "$%s"

Config.DatabaseChecker = {}
Config.DatabaseChecker.Enabled = true -- if true, lb-racing will check the database for any issues
Config.DatabaseChecker.AutoFix = true -- if true, lb-racing will automatically fix any issues & add new tables if needed

Config.Convert = true -- convert data from detected race scripts? Supported: rahe-racing

--[[ APP OPTIONS ]]--

Config.Standalone = {}
Config.Standalone.Enabled = true -- enable standalone racing tablet? "auto" = will enable if neither lb-phone nor lb-tablet is installed
Config.Standalone.RequireItem = "racing_tablet"
Config.Standalone.Command = "racingtablet" -- command to open the racing tablet
Config.Standalone.Bind = "F4"
Config.Standalone.Model = `imp_prop_impexp_tablet`
Config.Standalone.Offset = vector3(0.05, -0.005, -0.04)
Config.Standalone.Rotation = vector3(0.0, 0.0, 0.0)
Config.Standalone.AllowAvatar = true -- allow setting an avatar when using standalone?

Config.App = {}

Config.App.Default = true -- automatically install the app?
Config.App.Name = "LB Racing"
Config.App.Description = "Participate in races and win money."
Config.App.RequireItem = false
Config.App.Icon = "icon.jpg"
Config.App.BlacklistedJobs = {
    -- "police",
}

Config.App.LBPhone = true -- add the app to lb-phone?
Config.App.LBTablet = true -- add the app to lb-tablet?

--[[ FRAMEWORK & STYLE OPTIONS ]]--

Config.Framework = "auto"
Config.HelpTextStyle = "default" -- "default", "ox_lib" or "gta". You can customize this further in client/custom/functions/functions.lua, `DrawHelpText` & `ClearHelpText`
Config.NotificationSystem = "auto" -- "auto", "ox_lib", "gta", "esx" or "qb". You can customize this further in client/custom/functions/functions.lua, `Notify`
Config.Units = "auto" -- "imperial", "metric" or "auto" (GTA settings). You can customized this further in client/custom/functions/functions.lua, `ShouldUseImperial`

--[[ HUD OPTIONS ]]--

Config.HUD = {}
Config.HUD.Leaderboard = {}
Config.HUD.Leaderboard.Position = "top-left" -- "top-left", "top-right", "bottom-left", "bottom-right"
Config.HUD.Leaderboard.Offset = { x = 0, y = 0 } -- Offset in percentage from the position corner

Config.HUD.Statistics = {}
Config.HUD.Statistics.Position = "top-right" -- "top-left", "top-right", "bottom-left", "bottom-right"
Config.HUD.Statistics.Offset = { x = 0, y = 0 } -- Offset in percentage from the position corner

--[[ RACE OPTIONS ]]--

Config.MinParticipants = 2
Config.CreateCooldown = 60 -- How many seconds before a player can create another race after just creating one. This does not apply to admins.

Config.CalculatePositionsInterval = 500 -- how often should positions be calculated? (in milliseconds)

Config.AutoStart = 300 -- how many seconds before automatically starting a race
Config.Countdown = 3 -- how many seconds should the countdown be?

Config.DNF = {}
Config.DNF.AfterFinish = 5 -- how many minutes after someone finishes the race should other players are marked as DNF?
Config.DNF.AfterDisconnect = 2 -- how many minutes after a player disconnects before they should be removed from the race?
Config.DNF.NotInCar = 1 -- how many minutes after a player has left their vehicle before they should be marked as DNF?

Config.NoCollision = {}
Config.NoCollision.Enabled = true -- disable collision between players at the start of a race?
Config.NoCollision.Duration = 30 -- how long after the race starts should collision be disabled? can be set to true for infinite, otherwise the number of seconds
Config.NoCollision.Alpha = 254

Config.ChargeRepeatingRaces = true -- charge money from the original creator for the prize pool of repeated races?
Config.CommissionRepeatedRaces = true -- allow commission from repeated races?

Config.RaceBucket = false -- should race participants be in their own bucket when racing?

Config.RaceObjects = {}

Config.RaceObjects.Checkpoint = {
    Collisions = {
        Racer = false,
        NonRacer = false
    },
    Visible = {
        Racer = true,
        NonRacer = true
    },
}

Config.RaceObjects.Barrier = {
    Collisions = {
        Racer = true,
        NonRacer = false
    },
    Visible = {
        Racer = true,
        NonRacer = true
    },
}

Config.NotSignedUp = {}
Config.NotSignedUp.Waypoint = false -- set a waypoint to a race even if you didn't sign up for it?
Config.NotSignedUp.Blip = false -- add a blip for a race even if you didn't sign up for it?
Config.NotSignedUp.Notification = true -- notify the player that a race is starting, even if they didn't sign up for it?

Config.FlipCar = {}
Config.FlipCar.Enabled = false
Config.FlipCar.Key = "H"
Config.FlipCar.Duration = 2000 -- how long you must hold the key to flip the car (in milliseconds), set to false to instantly flip
Config.FlipCar.AlwaysVisible = false -- always show the flip car control?

Config.TPCheckpoint = {}
Config.TPCheckpoint.Enabled = false
Config.TPCheckpoint.Key = "G"
Config.TPCheckpoint.Duration = 2000 -- how long you must hold the key to tp to the last checkpoint (in milliseconds), set to false to instantly tp
Config.TPCheckpoint.AlwaysVisible = false -- always show the tp checkpoint control?

--[[ PERMISSIONS ]]--

Config.Creator = {}
Config.Creator.Bucket = true -- Use a separate routing bucket when in the creator? You can customize the function to get bucket id in server/custom/functions/creator.lua, `GetEmptyRoutingBucket`
Config.Creator.Vehicle = `tenf2` -- The vehicle to spawn when entering the creator. Set to false to disable

Config.Creator.Weather = {}
Config.Creator.Weather.Freeze = true -- Freeze the weather when creating a track?
Config.Creator.Weather.Type = "EXTRASUNNY"
Config.Creator.Weather.Hour = 12
Config.Creator.Weather.Minute = 0

Config.Permissions = {} -- you can customize permissions further in the permissions.lua files

Config.Permissions.Creator = {
    Everyone = false, -- allow everyone to create tracks?
    Admin = true, -- allow admins to create tracks?

    Freecam = {
        Everyone = false,
        Admin = true
    }
}

Config.Permissions.EditTrack = {
    Everyone = false,
    Admin = true,
    Creator = true
}

Config.Permissions.RemoveTrack = {
    Everyone = false,
    Admin = true,
    Creator = true
}

Config.Permissions.CreateRace = {
    Everyone = true, -- allow everyone to create races?
    Admin = true, -- allow admins to created races?

    RaceOptions = {
        PaymentMethod = {
            Everyone = true,
            Admin = true,

            Default = "bank",
            -- By default, the only option supported is `bank`. You can add more payment methods in server/custom/functions/payment.lua
            Options = {
                {
                    label = "APP.RACES.PAYMENT_METHODS.MONEY",
                    value = "bank",
                }
            }
        },

        PrizeDistribution = {
            Everyone = true,
            Admin = true,

            Default = "defined", -- "auto" or "defined"
            -- The algorithms can be configured in lib/shared/prize-distribution.lua, `GetPrizePoolDistribution`
            Algorithms = {
                {
                    label = "APP.RACES.PRIZE_DISTRIBUTION.ALGORITHMS.EXPONENTIAL",
                    value = "exponential"
                },
                {
                    label = "APP.RACES.PRIZE_DISTRIBUTION.ALGORITHMS.LINEAR",
                    value = "linear"
                }
            }
        },

        Repeat = {
            Everyone = false,
            Admin = true,

            Intervals = {
                30,
                60,
                2 * 60,
                3 * 60,
                4 * 60,
                8 * 60,
                12 * 60,
                16 * 60,
                20 * 60,
                24 * 60, -- 1 day
                2 * 24 * 60,
                3 * 24 * 60,
                4 * 24 * 60,
                5 * 24 * 60,
                6 * 24 * 60,
                7 * 24 * 60, -- 1 week
                2 * 7 * 24 * 60,
                3 * 7 * 24 * 60,
                30 * 24 * 60, -- 1 month
            }
        },

        AssignVehicle = {
            Everyone = true,
            Admin = true,

            Default = false
        },

        Commission = {
            Everyone = true,
            Admin = true,

            Default = 10,
            Min = 0,
            Max = 70
        },

        Ranked = {
            Everyone = true,
            Admin = true,

            Default = true
        },

        RequireSignUp = {
            Everyone = true,
            Admin = true,

            Default = true
        },

        InviteOnly = {
            Everyone = true,
            Admin = true,

            Default = false
        },

        PersonalVehicle = {
            Everyone = true,
            Admin = true,

            Default = false
        },

        Collisions = {
            Everyone = true,
            Admin = true,

            Default = false
        },

        FirstPerson = {
            Everyone = true,
            Admin = true,

            Default = false,
        },

        DisableTraffic = {
            Everyone = true,
            Admin = true,

            Default = false
        },
    }
}

Config.Permissions.CancelRace = {
    Everyone = false,
    Admin = true,
    Creator = true
}

--[[ GRAPHICS ]] --

Config.Graphics = {}

Config.Graphics.JoinRace = {}
Config.Graphics.JoinRace.Enabled = true
Config.Graphics.JoinRace.FollowCamera = true
Config.Graphics.JoinRace.Size = 2.0

Config.Graphics.PlayerBoxes = {}
Config.Graphics.PlayerBoxes.Enabled = true
Config.Graphics.PlayerBoxes.Size = 1.0
Config.Graphics.PlayerBoxes.FollowCamera = true

Config.Graphics.Checkpoints = {}
Config.Graphics.Checkpoints.Enabled = true
Config.Graphics.Checkpoints.Amount = 3
Config.Graphics.Checkpoints.Resolution = 1/5

--[[ BLIP OPTIONS ]]--

Config.Blips = {}

Config.Blips.Participants = {}
Config.Blips.Participants.Enabled = true -- add blips for all participants in a race?
Config.Blips.Participants.Category = 12 -- can be 12-133 (with name) or 134-254 (no name), or false to not set a category
Config.Blips.Participants.Sprite = 1
Config.Blips.Participants.Color = 0
Config.Blips.Participants.Scale = 0.9
Config.Blips.Participants.ShortRange = true
Config.Blips.Participants.ShowHeight = false
Config.Blips.Participants.ShowHeading = true

Config.Blips.Checkpoints = {}
Config.Blips.Checkpoints.Sprite = 1 -- https://docs.fivem.net/docs/game-references/blips/
Config.Blips.Checkpoints.Category = 13 -- can be 12-133 (with name) or 134-254 (no name), or false to not set a category
Config.Blips.Checkpoints.Scale = 0.85
Config.Blips.Checkpoints.ActiveScale = 1.0
Config.Blips.Checkpoints.PreviousScale = 0.7
Config.Blips.Checkpoints.Alpha = 255
Config.Blips.Checkpoints.ActiveAlpha = 255
Config.Blips.Checkpoints.PreviousAlpha = 128
Config.Blips.Checkpoints.Color = 39
Config.Blips.Checkpoints.ActiveColor = 38
Config.Blips.Checkpoints.PreviousColor = 39
Config.Blips.Checkpoints.FutureActiveColor = 1 -- how many blips ahead should be colored as "active"?

--[[ VEHICLE OPTIONS ]]--

Config.BlacklistedVehicleModels = {
    -- `t20`,
}

Config.VehicleTypes = {
    {
        label = "Car",
        type = "car",
        icon = "fa-solid fa-car",
        types = { 0, 6 } -- https://docs.fivem.net/natives/?_0xA273060E
    },
    {
        label = "Motorcycle",
        type = "motorcycle",
        icon = "fa-solid fa-motorcycle",
        types = { 11 }
    },
    {
        label = "Offroad",
        type = "offroad",
        icon = "fa-solid fa-truck-monster",
        types = { 3, 7 }
    },
}

---@type { [string]: { label: string, model: number | string, type: "automobile" | "bike", trackType: "car" | "motorcycle" | "offroad" }[] }
Config.VehicleClasses = {
    ["Super"] = {
        { label = "T20", model = `t20`, type = "automobile", trackType = "car" },
        { label = "Adder", model = `adder`, type = "automobile", trackType = "car" },
        { label = "Krieger", model = `krieger`, type = "automobile", trackType = "car" },
        { label = "Emerus", model = `emerus`, type = "automobile", trackType = "car" },
        { label = "Entity XXR", model = `entity2`, type = "automobile", trackType = "car" },
        { label = "Nero Custom", model = `nero2`, type = "automobile", trackType = "car" },
        { label = "Vagner", model = `vagner`, type = "automobile", trackType = "car" }
    },
    ["Hypercar"] = {
        { label = "Deveste Eight", model = `deveste`, type = "automobile", trackType = "car" },
        { label = "XA-21", model = `xa21`, type = "automobile", trackType = "car" },
        { label = "Zorrusso", model = `zorrusso`, type = "automobile", trackType = "car" },
        { label = "S80RR", model = `s80`, type = "automobile", trackType = "car" },
        { label = "Cyclone", model = `cyclone`, type = "automobile", trackType = "car" }
    },
    ["Sports"] = {
        { label = "Comet S2", model = `comet6`, type = "automobile", trackType = "car" },
        { label = "Itali GTO", model = `italigto`, type = "automobile", trackType = "car" },
        { label = "Jester RR", model = `jester4`, type = "automobile", trackType = "car" },
        { label = "Pariah", model = `pariah`, type = "automobile", trackType = "car" },
        { label = "Elegy Retro", model = `elegy`, type = "automobile", trackType = "car" },
        { label = "Kuruma", model = `kuruma`, type = "automobile", trackType = "car" }
    },
    ["Sports Classic"] = {
        { label = "Turismo Classic", model = `turismo2`, type = "automobile", trackType = "car" },
        { label = "Cheetah Classic", model = `cheetah2`, type = "automobile", trackType = "car" },
        { label = "Infernus Classic", model = `infernus2`, type = "automobile", trackType = "car" },
        { label = "Stirling GT", model = `feltzer3`, type = "automobile", trackType = "car" },
        { label = "GT500", model = `gt500`, type = "automobile", trackType = "car" }
    },
    ["Muscle"] = {
        { label = "Dominator GTX", model = `dominator3`, type = "automobile", trackType = "car" },
        { label = "Gauntlet Hellfire", model = `gauntlet4`, type = "automobile", trackType = "car" },
        { label = "Buffalo STX", model = `buffalo4`, type = "automobile", trackType = "car" },
        { label = "Sabre Turbo", model = `sabregt`, type = "automobile", trackType = "car" },
        { label = "Ellie", model = `ellie`, type = "automobile", trackType = "car" }
    },
    ["Tuner"] = {
        { label = "Calico GTF", model = `calico`, type = "automobile", trackType = "car" },
        { label = "Jester RR", model = `jester4`, type = "automobile", trackType = "car" },
        { label = "ZR350", model = `zr350`, type = "automobile", trackType = "car" },
        { label = "Euros", model = `euros`, type = "automobile", trackType = "car" },
    },
    ["Offroad"] = {
        { label = "Trophy Truck", model = `trophytruck`, type = "automobile", trackType = "offroad" },
        { label = "Desert Raid", model = `trophytruck2`, type = "automobile", trackType = "offroad" },
        { label = "Brawler", model = `brawler`, type = "automobile", trackType = "offroad" },
        { label = "Kamacho", model = `kamacho`, type = "automobile", trackType = "offroad" },
        { label = "Everon", model = `everon`, type = "automobile", trackType = "offroad" }
    },
    ["Rally"] = {
        { label = "Sultan RS", model = `sultanrs`, type = "automobile", trackType = "offroad" },
        { label = "Tropos Rallye", model = `tropos`, type = "automobile", trackType = "offroad" },
        { label = "Flash GT", model = `flashgt`, type = "automobile", trackType = "offroad" },
        { label = "Omnis", model = `omnis`, type = "automobile", trackType = "offroad" }
    },
    ["SUV"] = {
        { label = "Toros", model = `toros`, type = "automobile", trackType = "car" },
        { label = "Rebla GTS", model = `rebla`, type = "automobile", trackType = "car" },
        { label = "Novak", model = `novak`, type = "automobile", trackType = "car" },
        { label = "Baller ST", model = `baller7`, type = "automobile", trackType = "car" }
    },
    ["Sedan"] = {
        { label = "Tailgater S", model = `tailgater2`, type = "automobile", trackType = "car" },
        { label = "Schafter V12", model = `schafter3`, type = "automobile", trackType = "car" },
        { label = "Super Diamond", model = `superd`, type = "automobile", trackType = "car" }
    },
    ["Motorcycles"] = {
        { label = "Bati 801", model = `bati`, type = "bike", trackType = "motorcycle" },
        { label = "Shotaro", model = `shotaro`, type = "bike", trackType = "motorcycle" },
        { label = "Hakuchou Drag", model = `hakuchou2`, type = "bike", trackType = "motorcycle" },
        { label = "Sanchez", model = `sanchez`, type = "bike", trackType = "motorcycle" }
    },
    ["Drag"] = {
        { label = "Pariah", model = `pariah`, type = "automobile", trackType = "car" },
        { label = "Itali GTO", model = `italigto`, type = "automobile", trackType = "car" },
        { label = "Cyclone", model = `cyclone`, type = "automobile", trackType = "car" },
        { label = "Buffalo STX", model = `buffalo4`, type = "automobile", trackType = "car" }
    },
    ["Monster Truck"] = {
        { label = "Liberator", model = `monster`, type = "automobile", trackType = "offroad" },
        { label = "Sasquatch", model = `monster3`, type = "automobile", trackType = "offroad" },
    },
    ["Open Wheel"] = {
        { label = "PR4 (Open Wheel 1)", model = `openwheel1`, type = "automobile", trackType = "car" },
        { label = "R88 (Open Wheel 2)", model = `openwheel2`, type = "automobile", trackType = "car" },
        { label = "Formula", model = `formula`, type = "automobile", trackType = "car" },
        { label = "Formula 2", model = `formula2`, type = "automobile", trackType = "car" },
    }
}

-- The calculation can be modified in client/custom/vehicle.lua, `GetVehicleTier`
Config.VehicleTiers = {
    {
        label = "S-tier",
        value = "S",
        score = 1000,
    },
    {
        label = "A-tier",
        value = "A",
        score = 750,
    },
    {
        label = "B-tier",
        value = "B",
        score = 600,
    },
    {
        label = "C-tier",
        value = "C",
        score = 300,
    },
    {
        label = "D-tier",
        value = "D",
        score = 200,
    },
    {
        label = "E-tier",
        value = "E",
        score = 0,
    }
}
