Config = {}

-- Commands to use zone helper and see pre-sets to copy and paste into your own scripts!
-- Set to false to disable a command entirely
Config.ZoneCreateCommand = 'zone_tool'        -- Box/Circle zone placement (immersive, in-character)
Config.PolyZoneCreateCommand = 'polyzone_tool' -- Polygon zone placement (uses noclip/freecam - ADMIN ONLY recommended - edit perms in server/open_server.lua)
Config.PropPlacementCommand = 'prop_tool'      -- Prop placement (immersive, in-character)

-- Enable/disable specific commands (set to false to completely disable)
Config.EnableZoneCommand = true
Config.EnablePolyZoneCommand = true  -- WARNING: Uses noclip/freecam - restrict via server/open_server.lua
Config.EnablePropCommand = true

Config.Controls = {
    confirm = 191,        -- Enter
    cancel = 73,          -- X (ESC opens pause menu, X is more reliable)
    fastMode = 21,        -- Shift (speeds up movement/rotation)
    heightMode = 36,      -- Left Ctrl (hold to adjust height with scroll)
    moveRight = 175,      -- Right Arrow
    moveLeft = 174,       -- Left Arrow
    moveForward = 172,    -- Up Arrow
    moveBackward = 173,   -- Down Arrow
    moveUp = 10,          -- PgUp
    moveDown = 11,        -- PgDn
    scrollUp = 15,        -- Scroll Up
    scrollDown = 14,      -- Scroll Down
    switchDimension = 38, -- E (cycle: Width > Length > Height > Rotation)
}

Config.DefaultZoneSettings = {
    initialRadius = 1.0,
    minRadius = 0.5,
    maxRadius = 50.0,
    initialSize = vector3(1.0, 1.0, 1.0),
    minSize = vector3(0.5, 0.5, 0.5),
    maxSize = vector3(50.0, 50.0, 50.0),
    color = { r = 0, g = 150, b = 255, a = 120 }
}

-- Set first person camera when entering placement mode
Config.SetFirstPerson = true


Config.PropGroundPlacementDelay = 100 -- Delay in milliseconds before placing the prop on the ground (to allow map props to load first if placed on top of them)
Config.PropStreamDistance = 30.0 -- Distance in meters at which props are streamed in and out of the player's view