fx_version("cerulean")
author("@electus_scripts (ELECTUS SCRIPTS)")
version("1.2.4")
lua54("yes")

games({
	"gta5",
})

files({
	"ui/build/index.html",
	"ui/build/**/*",
	"config/locales/*.lua",
})

client_scripts({
	-- "@qbx_core/modules/playerdata.lua", -- uncomment this if you are using Qbox
	"client/**/*",
	"escrowed/client/**",
})

server_scripts({
	"server/**/*",
	"server_config/**/*",
	"escrowed/server/*",
	"@mysql-async/lib/MySQL.lua",
})

shared_scripts({
	"config/*.lua",
	"shared/**/*",
	"escrowed/shared/*",
	"@ox_lib/init.lua",
	-- "@qbx_core/modules/lib.lua", -- uncomment this if you are using Qbox
})

-- ui_page("ui/build/index.html")
-- ui_page("http://localhost:5173")
ui_page("ui/build/index.html")

escrow_ignore({
	"client/**",
	"server/**",
	"shared/**",
	"config/**",
	"server_config/**",
})

dependency '/assetpacks'