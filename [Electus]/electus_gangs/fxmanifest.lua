fx_version("cerulean")
author("@electus_scripts (ELECTUS SCRIPTS)")
version("2.0.9")
lua54("yes")

games({
	"gta5",
})

shared_scripts({
	-- "config/config.lua",
	"config/*.lua",
	-- "@loaf_wrapper/load.lua",
	"loaf_wrapper/load.lua",
	"shared/**/*",
	"escrowed/shared/*",
	-- "@ox_lib/init.lua",
	-- "@qbx_core/modules/lib.lua", -- uncomment this if you are using Qbox
})

files({
	"loaf_wrapper/client/**",
	"loaf_wrapper/shared/**",
	"ui/build/index.html",
	"ui/build/**/*",
	"config/locales/*.lua",
})

ui_page("ui/build/index.html")
-- ui_page("http://localhost:5173")

client_scripts({
	-- "@qbx_core/modules/playerdata.lua", -- uncomment this if you are using Qbox
	"client/**/*",
	-- "escrowed/client/main.lua",
	"escrowed/client/**",
})

server_exports({
	"GetGang",
	"GetGangLevel",
	"GetSourceGangId",
	"GetGangFromZoneId",
	"ChangeGangRep",
	"GetGangOwnedZones",
	"GetZoneRespect",
	"GainXP",
})

server_script({
	"server/**/*",
	"escrowed/server/*",
	"@oxmysql/lib/MySQL.lua",
})

escrow_ignore({
	"client/**",
	"server/**",
	"shared/**",
	"config/**",
	"loaf_wrapper/**",
})

dependency("bob74_ipl")

dependency '/assetpacks'