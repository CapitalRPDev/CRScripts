Config = {}

Config.Framework = "auto" -- "auto", "esx", "qbcore", "qbox"
Config.Inventory = "auto" -- "auto", "ox_inventory", "core", "qs-inventory", "tgiann", "esx", "qb-core", "codem", "qb-inventory" (if it doesnt work test "esx" or "qb-core")
Config.TargetSystem = "qtarget" -- "qtarget", "ox_target", "qb-target" and more
Config.Target = "auto" -- "auto", true, false
Config.NotificationSystem = "auto" -- "auto" | "framework" | "ox_lib" | "gta"
Config.MenuSystem = "auto" -- "auto" | "ox_lib_menu" | "ox_lib_context" | "esx_menu_default" | "esx_context"
Config.HelpTextStyle = "auto" -- "auto" | "ox_lib" | "okokTextUI" | "jg-textui" | "cd_drawtextui" | "gta"

Config.Locale = "en"
Config.Debug = false

-- if you change KeyActions the Key must also be avaliable in Keys table.
Config.KeyActions = {
	placeMarker = "E",
	cancel = "BACKSPACE",
	pressToExitIpl = "E",
	openLaunderingMenu = "E",
	startCapturingZone = "E",
	startDefendingZone = "E",
	storeVehicle = "E",
	openGarageMenu = "E",
	openSafeHouseMenu = "E",
	enterIpl = "E",
	plantWeed = "E",
	confirmVehicleSpawnPosition = "E",
	rotateVehicle = "R",
	openGarage = "E",
	stopEscorting = "G",
	openGangShopMenu = "E",
	createDoor = "E",
	openDoor = "E",
	closeDoor = "E",
	placeObject = "E",
	rotateObject = "G",
}

-- make it higher if you want it to be harder for gangs to level up
Config.XpNeededForNextLevel = 100

-- will only include players within this distance (or -1 to select all)
Config.SelectPlayerDist = -1

-- Max number of members in a gang (-1 for unlimited)
Config.MaxMembers = 2

Config.DirtyCashItem = "black_money" -- false (common for esx) or e.g "black_money" or "markedbills"

Config.GangShop = {
	enabled = true,
	coords = { x = 357.22, y = -1809.56, z = 28.6 },
	price = 100000,
	canPurchaseWithoutSafehouse = true,
	priceWithoutSafehouse = 75000,
}

-- this is used to connect zones together and for gangs to capture one zone at a time
Config.ConnectedZones = {
	enable = true, -- enable connected zones
	minNumberOfConnectionBetweenZones = 3, -- recommended 2-3
	maxAngleBetweenConnectedZones = 20, -- if the previous connection and current is less than this value another connection will be created (useful if you want to spread out your connections)
	onlyShowConnectedZones = true, -- only show connected zones
}

Config.Zones = {
	-- If set to false other's safehouses will not be shown on the map
	-- Note: setting this to false will automatically disable safehouse raids
	showSafehousesOnMap = true,
	canTransferZones = true,

	hideZonesFromGangsWithoutSafehouse = false, -- recommended to true if you have connected zones enabled (otherwise it will just show empty map)

	respect = { -- respect is gained every day as long as the gang controlls the zone
		min = 0,
		max = 100,
		gain = 2,
	},
	npcDefenders = {
		randomModels = {
			`g_m_y_famca_01`,
			`g_m_y_famdnf_01`,
			`g_m_y_famfor_01`,
		},
	},
}

Config.Attacks = {
	maxAttacks = 3, -- maximum number of attacks a gang can have active at the same time
	preperationTime = 1, -- time before the raid/capture is going live (in hours)
	durationTime = 60, -- in minutes how long the raid/capture will last
	minimumGangMembersOnline = -1, -- -1 to disable, minimum number of gang members online (defenders) to start an attack
	raid = {
		enable = true, -- enable raids
		doors = {
			requiredItem = "lockpick", -- false to disable required item to open the safe, or set to item e.g. "lockpick"
			breakIntoAction = function()
				return lib.skillCheck({ "easy", "medium" }, { "w", "a", "s", "d" }) -- https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
			end,
		},
		safe = {
			enable = true, -- enable safe in raids
			cashPercentage = { -- random percentage of the safe that can be taken when raided
				min = 0.2, -- minimum percentage of the safe that can be taken
				max = 0.4, -- maximum percentage of the safe that can be taken
			},
			dirtyCashPercentage = {
				min = 0.3,
				max = 0.6,
			},
			requiredItem = "lockpick", -- false to disable required item to open the safe, or set to item e.g. "lockpick"
			breakIntoAction = function()
				return lib.skillCheck({ "easy", "medium", "hard" }, { "w", "a", "s", "d" }) -- https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
			end,
		},
	},
}

Config.Capturing = {
	cooldownAfterCapture = 60, -- time in minutes (noone can capture the zone again until the cooldown is over)
	war = {
		requireOnAttackCapture = true, -- require war to attack capture a zone
		requireOnProgressCapture = false, -- require war to progress capture a zone
		goalPoints = 100,
		duration = 48, -- time in hours until it ends
		points = { -- points for each action, set it to 0 if you want to disable any
			drugSelling = 2,
			-- graffiti = 1,
			zoneCapture = 10,
		},
		prize = { -- prize in dirty cash for the winner
			min = 5000,
			max = 10000,
		},
	},
	captureProgressTypes = {
		{
			name = "drugCapture", -- this is the name used when calling the export
			label = "Drug Capture",
			description = "Capture the zone by selling drugs in it.",
		},
		{
			name = "graffiti", -- this is the name used when calling the export
			label = "Graffiti",
			description = "Capture the zone by spraying graffiti in it.",
		},
		-- add more here if you plan to use the exports
	},
}

Config.ShowLogoOnMap = true -- show gang logo on map

Config.Safe = {
	onlyGangCanOpenSafe = true, -- if true, only gang members can open the safe when its opened otherwise anyone can open it
}

Config.GangMenu = { -- ways to open gang menu
	marker = true,
	command = true,
	lbTablet = false,
}

Config.Garage = {
	garageSystem = "jg-advancedgarages", -- "esx_garage", "jg-advancedgarages", "qb-garages", "cd_garage"
	enableGangGarage = true,
	enablePersonalGarage = true,
}

Config.MoneyLaundering = {
	amountPerHour = 500,
	useGangDirtyCash = false, -- use gang dirty cash instead of player dirty cash
}

Config.NumberOfNPCDefendersWaves = 3
Config.RestrictWeedPlantingToZoneGang = false
Config.EnableGangActions = true
Config.NPCDefenderWeapons = "WEAPON_PISTOL"

Config.ActionItems = {
	ziptie = "ziptie", -- item to ziptie someone
	headbag = "headbag", -- item to put a headbag on someone
	remove_ziptie = "WEAPON_KNIFE", -- item to remove ziptie
}

Config.DateLanguage = "en-US"
Config.IncludeSInDate = true
Config.AdminGroupName = "admin"

Config.SafeHouseIpls = {
	{
		id = "bikersClubHouse1",
		name = "Bikers Club House 1",
	},
	{
		id = "bikersClubHouse2",
		name = "Bikers Club House 2",
	},
}

Config.Ipls = {
	["moneyLaundering"] = {
		spawnCoords = { x = 1138.0, y = -3198.8, z = -40.5 },
		menuCoords = { x = 1126.05, y = -3196.83, z = -40.6 },
	},
	["bikersClubHouse1"] = {
		spawnCoords = { x = 1121.09, y = -3152.0, z = -38.0 },
	},
	["bikersClubHouse2"] = {
		spawnCoords = { x = 998.4809, y = -3164.711, z = -38.90733 },
	},
	["warehouse"] = {
		spawnCoords = { x = 1087.94, y = -3099.34, z = -39.95 },
	},
	["weedProcessing"] = {
		spawnCoords = { x = 1088.63, y = -3187.64, z = -39.95 },
	},
}

Config.PoliceJobs = {
	"police",
}

-- this is used to gain/lose reputation points
Config.GangReputation = {
	["captureZone"] = 50,
	["loseZone"] = -50,
	["recruitMember"] = 100,
	["kick"] = -100,
	["sellDrugs"] = 2,
	["lootBoatCrate"] = 5,
	["lootContainer"] = 3,
}

Config.Doors = {
	openDistance = 1.75,
}

Config.Weed = {
	canPlantEverywhere = true, -- if true, you can plant weed anywhere, if false, you can only plant weed in the zone where your gang is located
	maxDistance = 2.0, -- max distance between plants
	maxPlaceDistance = 1.5, -- max place distance
	growthInterval = 1.0, -- in hours
	growth = 10, -- how much the plant will grow each growth interval (default 4% each hour = 100% in 25 hours)
	fertilizer = {
		decrease = 10, -- value that fertilizer will decrease by each hour
		use = {
			fertilizerIncrease = 25, -- how much health will increase when used
			healthIncrease = 10, -- how much health will increase when used
		},
		low = { -- if the plant is under 25% water
			value = 25, -- under 25%
			healthDecrease = 5, -- how much health will decrease each hour
		},
		medium = { -- if the plant is under 50% water
			value = 50, -- under 50%
			healthDecrease = 2, -- how much health will decrease each hour
		},
	},
	water = {
		decrease = 15, -- value that water will decrease by each hour
		use = {
			waterIncrease = 25, -- how much water will increase when used
			healthIncrease = 5, -- how much health will increase when used
		},
		low = { -- if the plant is under 25% water
			value = 25, -- under 25%
			healthDecrease = 5, -- how much health will decrease each hour
		},
		medium = { -- if the plant is under 50% water
			value = 50, -- under 50%
			healthDecrease = 2, -- how much health will decrease each hour
		},
	},
}

if Config.TargetSystem == "ox_target" or Config.TargetSystem == "auto" then -- do not touch this
	Config.TargetSystem = "qtarget"
end
