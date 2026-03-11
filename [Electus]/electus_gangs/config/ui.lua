Config.Ui = {
	showCayoPericoMap = true, -- show cayo perico island in the map
	toggleSidebars = {
		home = true, -- (do not disable)
		events = true, -- (do not disable)
		tasks = true, -- do not disable if you want to see tasks
		members = true, -- do not disable if you want to manage members
		roles = true, -- do not disable if you want to manage roles
		zones = true, -- do not disable if you want to see zones
		wars = true, -- do not disable if you want to see wars
		transfers = true, -- do not disable if you want to see transfers (not recommended when using safe)
		upgrades = true, -- do not disable if you want upgrades
		vehicles = true, -- do not disable if you want vehicles
		logs = true, -- do not disable if you want to see logs
		statistics = true, -- do not disable if you want to see statistics
		scoreboard = true, -- do not disable if you want to see scoreboard
		alerts = true,
		settings = true, -- do not disable if you want to manage settings
	},
	menuSettings = {
		changeColor = false,
		changeName = false,
		transferOwnership = true,
	},
	enterZone = {
		enablePopup = false,
		showOnlyForGangMembers = false, -- show only for gang members
		duration = -1, -- -1 for infinite (time in ms)
		currentZoneCommand = "current_zone", -- command to see current zone owner or false
		popupPosition = "centerTop", -- "topLeft", "topRight", "centerTop", "centerBottom", "bottomLeft", "bottomRight"
	},
	mapConfiguration = {
		image = { 16384, 24576 },
		topLeft = { -4140, 8400 }, -- Game coordinates [X, Y] for top-left pixel (0,0)
		bottomRight = { 4860, -5100 },
		-- I have permission to use Loafs server if you want any custom configuration you'll need to change it yourself
		tileServer = "https://assets.loaf-scripts.com/map-tiles/gtav/main/{layer}/{z}/{x}/{y}.jpg",
	},
theme = {
		{ name = "background", value = "214 35% 4%" },
		{ name = "foreground", value = "0 0% 98%" },
		{ name = "muted", value = "214 25% 10%" },
		{ name = "muted-foreground", value = "214 15% 55%" },
		{ name = "popover", value = "214 35% 4%" },
		{ name = "popover-foreground", value = "0 0% 98%" },
		{ name = "card", value = "214 30% 6%" },
		{ name = "card-foreground", value = "0 0% 98%" },
		{ name = "border", value = "201 100% 40%" },
		{ name = "input", value = "214 25% 10%" },
		{ name = "primary", value = "201 100% 50%" },
		{ name = "primary-foreground", value = "214 35% 4%" },
		{ name = "secondary", value = "214 25% 10%" },
		{ name = "secondary-foreground", value = "0 0% 98%" },
		{ name = "accent", value = "201 100% 40%" },
		{ name = "accent-foreground", value = "0 0% 98%" },
		{ name = "destructive", value = "0 62.8% 30.6%" },
		{ name = "destructive-foreground", value = "0 0% 98%" },
		{ name = "ring", value = "201 100% 50%" },
		{ name = "chart-1", value = "201 100% 50%" },
		{ name = "chart-2", value = "201 80% 40%" },
		{ name = "chart-3", value = "201 60% 30%" },
		{ name = "chart-4", value = "201 100% 65%" },
		{ name = "chart-5", value = "214 50% 70%" },
		{ name = "radius", value = "0.65rem" },
	},
}