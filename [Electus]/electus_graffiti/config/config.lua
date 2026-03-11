Config = {}
Config.Framework = "qbx" -- "esx", "qbx" or "qb"
Config.Inventory = "ox_inventory" -- "esx", "qb", "core", "qs", "tgiann", "ox_inventory", "qb-inventory", "codem"
Config.Locale = "en"
Config.UploadService = "lb-upload" -- "lb-upload" or "fivemanage"

Config.MaxGraffities = 10 -- max amount of graffitis a player can have
Config.MaxVisibleGraffities = 10 -- max amount of graffitis that can be visible at once

Config.GraffitiSprayingDist = 7.5 -- distance at which graffiti can sprayed
Config.RenderDistance = 100.0 -- distance at which graffiti will be rendered
Config.Quality = 0.5 -- image quality 0.0-1.0

-- if you have performance issue make sure to limit then sizes of your graffities
Config.MaxHeight = 500 -- max height of graffiti (in pixels)
Config.MaxWidth = 500 -- max width of graffiti (in pixels)

Config.MinFillPercentage = 5 -- min % of non transparent to create a graffiti

Config.IntegrateElectusGangs = true
Config.ProgressToAdd = 10 -- progress to add to zone capture when graffiti is sprayed

Config.RemoveSprayAfterUse = true -- if true, spray can will be removed after use
Config.RemoveWipeAfterUse = true -- if true, wipe will be removed after use

Config.CallPolice = true -- if true, police will be called when a graffiti is sprayed
Config.HidePlayersWhenSpraying = true -- if true, players will be hidden when spraying, this way there you can't be blocked when spraying (regardless other players will see your spraying)

Config.Scale = {
	min = 0.5, -- minimum scale of graffiti
	max = 5.0, -- maximum scale of graffiti
}

Config.KeyActions = { -- if you change KeyActions the Key must also be avaliable in Keys table.
	place = "E",
	up = "UP",
	down = "DOWN",
	left = "LEFT",
	right = "RIGHT",
	cancel = "BACKSPACE",
	spray = "LEFTMOUSE",
	wipe = "LEFTMOUSE",
	confirmWipe = "E",
}

Config.UrlAllowlist = {
	enabled = false,
	allowSameOrigin = true, -- if enabled, it will allow already created graffitis to be used in graffiti creator
	urls = { -- add urls to this list to allow them to be used in graffiti
	},
}
