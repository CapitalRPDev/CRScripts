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
	theme = { -- keep HSL (value) format to pick new colors use e.g. (https://hslpicker.com/)
		{ name = "background", value = "0 0% 3.9%" },
		{ name = "foreground", value = "0 0% 98%" },
		{ name = "muted", value = "0 0% 14.9%" },
		{ name = "muted-foreground", value = "0 0% 63.9%" },
		{ name = "popover", value = "0 0% 3.9%" },
		{ name = "popover-foreground", value = "0 0% 98%" },
		{ name = "card", value = "0 0% 5.0%" },
		{ name = "card-foreground", value = "0 0% 98%" },
		{ name = "border", value = "0 0% 14.9%" },
		{ name = "input", value = "0 0% 14.9%" },
		{ name = "primary", value = "210.57 63.44% 48.95%" },
		{ name = "primary-foreground", value = "203.77 0% 100%" },
		{ name = "secondary", value = "0 0% 14.9%" },
		{ name = "secondary-foreground", value = "0 0% 98%" },
		{ name = "accent", value = "0 0% 14.9%" },
		{ name = "accent-foreground", value = "0 0% 98%" },
		{ name = "destructive", value = "0 62.8% 30.6%" },
		{ name = "destructive-foreground", value = "0 0% 98%" },
		{ name = "ring", value = "0 0% 83.1%" },
		{ name = "chart-1", value = "224.15 92.28% 50.19%" },
		{ name = "chart-2", value = "140.38 50.5% 47.54%" },
		{ name = "chart-3", value = "0 46.35% 52.69%" },
		{ name = "chart-4", value = "253.58 74.19% 55.29%" },
		{ name = "chart-5", value = "61.13 55.54% 58.47%" },
		{ name = "radius", value = "0.65rem" }, -- radius for buttons, inputs, etc.
	},
}
