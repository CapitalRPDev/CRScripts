fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'envi-zone-tool'
author 'Envi-Scripts'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client_open.lua',
    'client/freecam.lua',
    'client/main.lua',
    'client/permanent_props.lua',
    'client/gizmo.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/open_server.lua',
    'server/permanent_props.lua'
}

escrow_ignore {
    'client/client_open.lua',
    'shared/config.lua',
    'server/open_server.lua',
    'install.sql'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}
dependency '/assetpacks'