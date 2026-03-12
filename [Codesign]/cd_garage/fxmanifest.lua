fx_version 'cerulean'
game 'gta5'
author 'discord.gg/codesign'
description 'Garage'
version '5.1.13'
lua54 'yes'

dependency 'cd_bridge'

shared_scripts {
    '@cd_bridge/shared/config.lua',
    '@cd_bridge/shared/auto_detect.lua',
    'configs/locales.lua',
    'configs/config.lua',
    'configs/auto_detect.lua'
}

client_scripts {
    '@cd_bridge/client/init.lua',
    'integrations/client/**/*.lua',
    'client/**/*.lua',
}

server_scripts {
    '@cd_bridge/server/init.lua',
    'configs/server_webhooks.lua',
    'integrations/server/**/*.lua',
    'server/**/*.lua'
}

ui_page {
    'html/index.html'
}

files {
    'configs/config_ui.js',
    'configs/locales_ui.js',
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
    'html/assets/*.js',
    'html/assets/*.css',
    'html/assets/*.woff',
    'html/assets/*.woff2',
    'html/images/logos/*.png',
    'html/images/vehicles/*.webp',
    'html/sounds/door_lock.wav'
}

export 'GetGarageType'
export 'GetAdvStats'
export 'GetVehiclesData'
export 'GetKeysData'
export 'DoesPlayerHaveKeys'
export 'GetPlate'
export 'GetConfig'
export 'GetMaxHealth'
export 'GetVehicleMileage'

server_export 'GetGarageLimit'
server_export 'GetGarageCount'
server_export 'GetMaxHealth'
server_export 'CheckVehicleOwner'
server_export 'GetConfig'
server_export 'GetVehiclesData'
server_export 'GetVehicleMileage'
server_export 'IsVehicleImpounded'
server_export 'GetVehicleImpoundData'


dependencies {
    '/server:4960', -- ⚠️PLEASE READ⚠️; Requires at least server build 4960.
    --'cd_garageshell'
}

escrow_ignore {
    'fxmanifest.lua',
    'client/main/callbacks.lua',
    'client/main/error_handling.lua',
    'client/other/*.lua',
    'configs/*.lua',
    'dependencies/cd_garageshell/stream/*.ytyp',
    'dependencies/cd_garageshell/stream/*.ydr',
    'dependencies/cd_garageshell/stream/*.ytd',
    'integrations/**/*.lua',
    'server/main/auto_insert_sql.lua',
    'server/main/callbacks',
    'server/main/error_handling.lua',
    'server/main/version_check.lua',
    'server/other/*.lua'
}

provide 'qb-garage'
dependency '/assetpacks'