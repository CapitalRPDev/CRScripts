Config.Events = {
	boatCrates = {
		enabled = true,
		policeDispatch = true,
		minPolice = 0, -- minimum police required to start the event (0 to disable)
		ladders = {
			{ coords = vector4(-326.81, -4078.35, -3.9, 40.0) },
		},
		npcs = {
			accuracy = 75,
		},
		hostileNpcs = {
			{
				spawnCoords = vector4(-397.27, -4120.15, 29.69, 40.0),
				pedModel = "csb_mweather",
				weapon = "WEAPON_PISTOL",
			},
			{
				spawnCoords = vector4(-302.87, -4043.33, 14.3, 40.0),
				pedModel = "csb_mweather",
				weapon = "WEAPON_PISTOL",
			},
			{
				spawnCoords = vector4(-322.39, -4055.41, 11.13, 40.0),
				pedModel = "csb_mweather",
				weapon = "WEAPON_PISTOL",
			},
			{
				spawnCoords = vector4(-364.79, -4074.82, 9.32, 40.0),
				pedModel = "csb_mweather",
				weapon = "WEAPON_PISTOL",
			},
			{
				spawnCoords = vector4(-349.32, -4093.53, 9.32, 40.0),
				pedModel = "csb_mweather",
				weapon = "WEAPON_PISTOL",
			},
		},
		crates = {
			{
				unlockTime = 1, -- minutes
				coords = vector4(-305.01, -4040.63, 13.3, 130.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 15 },
					{ item = "WEAPON_SMG", chance = 10 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				unlockTime = 1, -- minutes
				coords = vector4(-424.4, -4140.98, 8.32, 128.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 15 },
					{ item = "WEAPON_SMG", chance = 10 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				unlockTime = 1, -- minutes
				coords = vector4(-393.99, -4123.29, 28.69, 208.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 15 },
					{ item = "WEAPON_SMG", chance = 10 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
		},
		days = { "mon", "tue", "thu" },
		starts = "12:56",
		ends = "20:00",
	},
	harbourContainers = {
		enabled = true,
		policeDispatch = true,
		minPolice = 0, -- minimum police required to start the event (0 to disable)
		containerAction = function()
			Wait(500) -- to prevent target still being open
			return lib.skillCheck("hard")
		end,
		containers = {
			{
				coords = vector4(931.03, -2987.06, 4.9, 90.0),
				crate = vector4(931.03, -2987.06, 5.2, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 5 },
					{ item = "WEAPON_SMG", chance = 2 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				coords = vector4(1042.91, -2979.13, 4.9, 90.0),
				crate = vector4(1042.91, -2979.13, 5.2, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 5 },
					{ item = "WEAPON_SMG", chance = 2 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				coords = vector4(1055.73, -3042.41, 4.9, 90.0),
				crate = vector4(1055.73, -3042.41, 5.3, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 5 },
					{ item = "WEAPON_SMG", chance = 2 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				coords = vector4(1115.16, -3031.55, 4.9, 90.0),
				crate = vector4(1115.16, -3031.55, 5.2, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 5 },
					{ item = "WEAPON_SMG", chance = 2 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				coords = vector4(1171.4, -2979.07, 4.9, 90.0),
				crate = vector4(1171.4, -2979.07, 5.2, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 5 },
					{ item = "WEAPON_SMG", chance = 2 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 50, min = 2, max = 10 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
			{
				coords = vector4(1115.62, -2968.2, 13.33, 90.0),
				crate = vector4(1115.62, -2968.2, 13.63, 90.0),
				items = {
					{ item = "WEAPON_PISTOL", chance = 10 },
					{ item = "WEAPON_SMG", chance = 5 },
					{ item = "lockpick", chance = 75 },
					{ item = "ammo-9", chance = 75, min = 5, max = 25 },
					{ item = "money", chance = 100, min = 100, max = 500 },
				},
			},
		},
		days = { "sat", "tue", "wed", "sun" },
		starts = "15:44",
		ends = "23:50",
	},
	-- train = {
	-- 	enabled = true,
	-- 	policeDispatch = true,
	-- 	minPolice = 0,
	-- 	trainSpeed = 20.0,

	-- 	spawnLocations = {
	-- 		vector3(2440.6, 5823.19, 60.68),
	-- 	},

	-- 	-- train only fits 3 containers
	-- 	containers = {
	-- 		{
	-- 			--attach offset
	-- 			coords = vector3(0.0, 0.0, -0.2),
	-- 			crate = vector3(0.0, 0.0, -0.3),
	-- 			items = {
	-- 				{ item = "WEAPON_PISTOL", chance = 10 },
	-- 				{ item = "WEAPON_SMG", chance = 5 },
	-- 				{ item = "lockpick", chance = 75 },
	-- 				{ item = "ammo-9", chance = 75, min = 5, max = 25 },
	-- 				{ item = "money", chance = 100, min = 100, max = 500 },
	-- 			},
	-- 		},
	-- 		{
	-- 			coords = vector3(0.0, 0.0, -0.2),
	-- 			crate = vector3(0.0, 0.0, -0.3),
	-- 			items = {
	-- 				{ item = "WEAPON_PISTOL", chance = 10 },
	-- 				{ item = "WEAPON_SMG", chance = 5 },
	-- 				{ item = "lockpick", chance = 75 },
	-- 				{ item = "ammo-9", chance = 75, min = 5, max = 25 },
	-- 				{ item = "money", chance = 100, min = 100, max = 500 },
	-- 			},
	-- 		},
	-- 		{
	-- 			coords = vector3(0.0, 0.0, -0.2),
	-- 			crate = vector3(0.0, 0.0, -0.3),
	-- 			items = {
	-- 				{ item = "WEAPON_PISTOL", chance = 10 },
	-- 				{ item = "WEAPON_SMG", chance = 5 },
	-- 				{ item = "lockpick", chance = 75 },
	-- 				{ item = "ammo-9", chance = 75, min = 5, max = 25 },
	-- 				{ item = "money", chance = 100, min = 100, max = 500 },
	-- 			},
	-- 		},
	-- 	},
	-- 	days = { "sat", "tue", "wed", "sun" },
	-- 	starts = "15:44",
	-- 	ends = "23:50",
	-- },
	-- airDrop = {
	-- 	enabled = true,
	-- 	policeDispatch = true,
	-- 	minPolice = 0,
	-- 	numberOfAirDrops = 1,

	-- 	airDrops = {
	-- 		{
	-- 			coords = vector3(709.0, 6469.0, 100.0),
	-- 			radius = 20.0,
	-- 			items = {
	-- 				{ item = "WEAPON_PISTOL", chance = 10 },
	-- 				{ item = "WEAPON_SMG", chance = 5 },
	-- 				{ item = "lockpick", chance = 75 },
	-- 				{ item = "ammo-9", chance = 75, min = 5, max = 25 },
	-- 				{ item = "money", chance = 100, min = 100, max = 500 },
	-- 			},
	-- 		},
	-- 	},
	-- },
}
