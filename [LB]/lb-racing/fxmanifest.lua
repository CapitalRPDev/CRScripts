fx_version "cerulean"
game "gta5"
lua54 "yes"

title "LB Racing"
description "Racing script with apps for lb-phone & lb-tablet, and a standalone UI"
author "LB Scripts"
version "1.1.2"

shared_scripts {
    "config/config.lua",
    "config/props.lua",
    "lib/shared/**.lua"
}

client_scripts {
    "lib/client/**.lua",
    "client/**.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "lib/server/**.lua",
    "server/**.lua"
}

files {
    "config/**.json",
    "ui/dist/**"
}

escrow_ignore {
    "lib/**",
    "config/**",
    "*/custom/**",
    "server/database-checker/**",
    "server/convert/**",
    "client/race/controls.lua"
}

ui_page "ui/dist/index.html"

dependency '/assetpacks'