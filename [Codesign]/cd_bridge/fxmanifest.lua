fx_version 'cerulean'
game 'gta5'
author 'discord.gg/codesign'
description 'Codesign bridge'
version '1.0.23'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/auto_detect.lua',
    'shared/locales.lua',
    'shared/functions.lua',
}

client_scripts {
    'client/**/*.lua',
}

server_scripts {
   'server/**/*.lua',
   'server/core/read_directory.js'
}

exports {
    'Callback',
    'RegisterClientCallback',
    'StoreError',
    'GetErrors',
}

server_exports {
    'Callback',
    'RegisterServerCallback',
    'StoreError',
    'GetErrors',
    'ReadDirectory'
}

escrow_ignore {
    'client/**/*.lua',
    'server/**/*.lua',
    'shared/**/*.lua'
}
dependency '/assetpacks'