# 🛠️ Envi-Zone-Tool

A powerful, easy-to-use development tool for creating zones and placing props in FiveM servers. Perfect for developers who need to quickly set up interaction zones, target zones, and prop placements with copy-paste ready code generation.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Commands](#-commands)
- [Exports API](#-exports-api)
- [Configuration](#-configuration)
- [Controls](#-controls)
- [Code Generation](#-code-generation)
- [Advanced Usage](#-advanced-usage)
- [API Reference](#-api-reference)
- [Examples](#-examples)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- 🎯 **Interactive Zone Placement** - Place circle (sphere) or box zones with real-time preview
- 📦 **Prop Placement** - Place and position props with precise heading rotation
- 🎨 **Modern Dark-Mode UI** - Clean, professional interface for viewing results
- 📋 **Code Generation** - Automatically generates copy-paste ready code for:
  - `ox_lib` zones (sphere and box)
  - `ox_target` zones (sphere and box)
  - `CreateObject` code for props
  - Vector3/Vector4 coordinates
- 🔧 **Export API** - Integrate zone/prop placement into your own scripts
- ⚡ **Real-time Preview** - See exactly what you're placing before confirming
- 🎛️ **Fine-tune Controls** - Precise positioning and sizing with keyboard controls

## 📦 Installation

1. Download and extract `envi-zone-tool` to your `resources` folder
2. Add to your `server.cfg`:
   ```cfg
   ensure envi-zone-tool
   ```
3. Ensure `ox_lib` is installed and running (required dependency)

## 🚀 Quick Start

### Using Commands

The simplest way to use Envi-Zone-Tool is via commands:

```bash
/zone_tool       # Start zone placement (opens UI after placement)
/prop_tool       # Start prop placement (opens UI after placement)
/prop_tool prop_cs_cardbox_01  # Start prop placement with specific model
```

### Using Exports

For integration into your scripts:

```lua
-- Zone placement
exports['envi-zone-tool']:StartZonePlacement({
    title = 'My Zone',
    showUI = true  -- Set to false to skip UI (default: false for exports)
}, function(result)
    if result.success then
        print('Zone placed!', json.encode(result.data))
    end
end)

-- Prop placement
exports['envi-zone-tool']:StartPropPlacement({
    title = 'My Prop',
    model = 'prop_cs_cardbox_01',
    showUI = true  -- Set to false to skip UI (default: false for exports)
}, function(result)
    if result.success then
        print('Prop placed!', json.encode(result))
    end
end)
```

## 🎮 Commands

| Command | Description | Parameters |
|---------|-------------|------------|
| `/zone_tool` | Start interactive zone placement | None |
| `/prop_tool` | Start interactive prop placement | `[model]` (optional) - Prop model name |

**Note:** Commands always show the UI after placement. Exports default to `showUI = false` unless explicitly set.

## 📡 Exports API

### `StartZonePlacement(options, callback)`

Starts an interactive zone placement session.

#### Parameters

**`options` (table):**
- `title` (string, optional) - Title shown in UI and help text. Default: `"Zone Placement"`
- `initialRadius` (number, optional) - Starting radius for sphere zones. Default: `1.0`
- `minRadius` (number, optional) - Minimum allowed radius. Default: `0.5`
- `maxRadius` (number, optional) - Maximum allowed radius. Default: `50.0`
- `initialSize` (vector3, optional) - Starting size for box zones. Default: `vector3(1.0, 1.0, 1.0)`
- `minSize` (vector3, optional) - Minimum allowed size. Default: `vector3(0.5, 0.5, 0.5)`
- `maxSize` (vector3, optional) - Maximum allowed size. Default: `vector3(50.0, 50.0, 50.0)`
- `color` (table, optional) - Zone preview color. Default: `{ r = 0, g = 150, b = 255, a = 120 }`
  - `r` (number) - Red component (0-255)
  - `g` (number) - Green component (0-255)
  - `b` (number) - Blue component (0-255)
  - `a` (number) - Alpha/transparency (0-255)
- `showUI` (boolean, optional) - Whether to show UI after placement. Default: `false` for exports, `true` for commands
- `canPlace` (function, optional) - Validation function called before placement
  - Parameters: `coords` (vector3) - Proposed placement coordinates
  - Returns: `boolean` - `true` to allow placement, `false` to deny

**`callback` (function, optional):**
- Called when placement completes or is cancelled
- Parameters: `result` (table)
  - `success` (boolean) - Whether placement was successful
  - `data` (table, if success) - Zone data:
    - `coords` (vector3) - Zone center coordinates
    - `zoneType` (string) - `"sphere"` or `"box"`
    - `radius` (number, sphere only) - Zone radius
    - `size` (vector3, box only) - Zone dimensions
    - `rotation` (number, box only) - Zone rotation in degrees

#### Example

```lua
exports['envi-zone-tool']:StartZonePlacement({
    title = 'Shop Entrance',
    initialRadius = 2.0,
    minRadius = 1.0,
    maxRadius = 5.0,
    color = { r = 0, g = 255, b = 0, a = 100 },
    showUI = true,
    canPlace = function(coords)
        -- Only allow placement within 50 units of shop
        local shopCoords = vector3(100.0, 200.0, 30.0)
        local distance = #(coords - shopCoords)
        return distance <= 50.0
    end
}, function(result)
    if result.success then
        print('Zone placed at:', result.data.coords)
        print('Type:', result.data.zoneType)
        if result.data.zoneType == 'sphere' then
            print('Radius:', result.data.radius)
        else
            print('Size:', result.data.size)
            print('Rotation:', result.data.rotation)
        end
    else
        print('Zone placement cancelled or failed')
    end
end)
```

### `StartPropPlacement(options, callback)`

Starts an interactive prop placement session.

#### Parameters

**`options` (table):**
- `title` (string, optional) - Title shown in UI and help text. Default: `"Prop Placement"`
- `model` (string/number, required) - Prop model name or hash
- `groundOffset` (number, optional) - Vertical offset from ground. Default: `0.0`
- `placeOnGround` (boolean, optional) - Whether to snap to ground. Default: `true`
- `showUI` (boolean, optional) - Whether to show UI after placement. Default: `false` for exports, `true` for commands
- `canPlace` (function, optional) - Validation function called before placement
  - Parameters: `coords` (vector3) - Proposed placement coordinates
  - Returns: `boolean` - `true` to allow placement, `false` to deny

**`callback` (function, optional):**
- Called when placement completes or is cancelled
- Parameters: `result` (table)
  - `success` (boolean) - Whether placement was successful
  - `coords` (vector3, if success) - Prop coordinates
  - `heading` (number, if success) - Prop heading/rotation in degrees

#### Example

```lua
exports['envi-zone-tool']:StartPropPlacement({
    title = 'Shelf Placement',
    model = 'prop_cs_cardbox_01',
    groundOffset = 0.0,
    placeOnGround = true,
    showUI = true,
    canPlace = function(coords)
        -- Only allow placement inside shop bounds
        local shopMin = vector3(90.0, 190.0, 25.0)
        local shopMax = vector3(110.0, 210.0, 35.0)
        return coords.x >= shopMin.x and coords.x <= shopMax.x and
               coords.y >= shopMin.y and coords.y <= shopMax.y and
               coords.z >= shopMin.z and coords.z <= shopMax.z
    end
}, function(result)
    if result.success then
        print('Prop placed at:', result.coords)
        print('Heading:', result.heading)
    else
        print('Prop placement cancelled or failed')
    end
end)
```

### `IsPlacementActive()`

Checks if a zone or prop placement is currently active.

#### Returns

- `boolean` - `true` if placement is active, `false` otherwise

#### Example

```lua
if exports['envi-zone-tool']:IsPlacementActive() then
    print('A placement is currently active')
end
```

### `CancelPlacement()`

Cancels any active zone or prop placement.

#### Example

```lua
exports['envi-zone-tool']:CancelPlacement()
```

### Drawing Utilities

These exports allow you to draw zone previews in your own scripts:

#### `DrawSphere(coords, radius, r, g, b, a)`

Draws a sphere marker at the specified coordinates.

- `coords` (vector3) - Center coordinates
- `radius` (number) - Sphere radius
- `r, g, b, a` (number, optional) - Color components (0-255). Defaults: `0, 150, 255, 120`

#### `DrawCenterMarker(coords, r, g, b)`

Draws a center point marker.

- `coords` (vector3) - Marker coordinates
- `r, g, b` (number, optional) - Color components (0-255). Defaults: `255, 100, 100`

#### `DrawBoxWireframe(center, size, rotation, r, g, b, a)`

Draws a wireframe box.

- `center` (vector3) - Box center coordinates
- `size` (vector3) - Box dimensions
- `rotation` (number) - Rotation in degrees
- `r, g, b, a` (number, optional) - Color components (0-255). Defaults: `0, 150, 255, 255`

#### Example

```lua
-- In a loop or thread
exports['envi-zone-tool']:DrawSphere(vector3(100.0, 200.0, 30.0), 2.5, 0, 255, 0, 100)
exports['envi-zone-tool']:DrawBoxWireframe(
    vector3(100.0, 200.0, 30.0),
    vector3(2.0, 2.0, 2.0),
    45.0,
    255, 0, 0, 200
)
```

## ⚙️ Configuration

Edit `shared/config.lua` to customize the tool:

### Commands

```lua
Config.ZoneCreateCommand = 'zone_tool'      -- Command to start zone placement
Config.PropPlacementCommand = 'prop_tool'   -- Command to start prop placement
```

### Controls

All controls use FiveM control IDs. You can customize key mappings:

```lua
Config.Controls = {
    confirm = 38,         -- E
    cancel = 73,          -- X
    fastMode = 21,        -- Shift
    moveRight = 175,      -- Right Arrow
    moveLeft = 174,       -- Left Arrow
    moveForward = 172,    -- Up Arrow
    moveBackward = 173,   -- Down Arrow
    moveUp = 10,          -- PgUp
    moveDown = 11,        -- PgDn
    scrollUp = 15,        -- Scroll Up
    scrollDown = 14,      -- Scroll Down
    switchDimension = 74, -- H
}
```

### Default Zone Settings

```lua
Config.DefaultZoneSettings = {
    initialRadius = 1.0,                    -- Starting radius for spheres
    minRadius = 0.5,                        -- Minimum radius
    maxRadius = 50.0,                       -- Maximum radius
    initialSize = vector3(1.0, 1.0, 1.0),   -- Starting size for boxes
    minSize = vector3(0.5, 0.5, 0.5),       -- Minimum size
    maxSize = vector3(50.0, 50.0, 50.0),    -- Maximum size
    color = { r = 0, g = 150, b = 255, a = 120 }  -- Default preview color
}
```

## 🎮 Controls

### Zone/Prop Placement (Step 1: Position)

| Control | Action |
|---------|--------|
| **Arrow Keys** | Fine-tune position (left/right/forward/backward) |
| **PgUp/PgDn** | Adjust height (up/down) |
| **Shift** | Fast movement mode (hold for faster movement) |
| **E** | Confirm placement |
| **X** | Cancel placement |

### Zone Size Adjustment (Step 2: Size)

| Control | Action |
|---------|--------|
| **Scroll Wheel** | Adjust active dimension |
| **H** | Switch dimension (box only: width → length → height → rotation) |
| **Arrow Keys** | Fine-tune position (still available) |
| **PgUp/PgDn** | Adjust height (still available) |
| **E** | Confirm final placement |
| **X** | Cancel |

### Prop Rotation

| Control | Action |
|---------|--------|
| **Scroll Wheel** | Rotate prop |
| **Shift + Scroll** | Fast rotation |
| **Arrow Keys** | Fine-tune position |
| **E** | Confirm placement |
| **X** | Cancel |

## 📋 Code Generation

The UI automatically generates code snippets for common use cases. All code is syntax-highlighted and ready to copy-paste.

### ox_lib Sphere Zone

```lua
local myZone = lib.zones.sphere({
    coords = vec3(100.0, 200.0, 30.0),
    radius = 2.50,
    debug = false,
    onEnter = function(self)
        print('Entered zone')
    end,
    onExit = function(self)
        print('Exited zone')
    end
})
```

### ox_lib Box Zone

```lua
local myZone = lib.zones.box({
    coords = vec3(100.0, 200.0, 30.0),
    size = vec3(2.0, 2.0, 2.0),
    rotation = 45.0,
    debug = false,
    onEnter = function(self)
        print('Entered zone')
    end,
    onExit = function(self)
        print('Exited zone')
    end
})
```

### ox_target Sphere Zone

```lua
exports.ox_target:addSphereZone({
    coords = vec3(100.0, 200.0, 30.0),
    radius = 2.50,
    debug = false,
    options = {
        {
            name = 'my_option',
            icon = 'fa-solid fa-hand',
            label = 'Interact',
            onSelect = function()
                print('Target selected')
            end
        }
    }
})
```

### ox_target Box Zone

```lua
exports.ox_target:addBoxZone({
    coords = vec3(100.0, 200.0, 30.0),
    size = vec3(2.0, 2.0, 2.0),
    rotation = 45.0,
    debug = false,
    options = {
        {
            name = 'my_option',
            icon = 'fa-solid fa-hand',
            label = 'Interact',
            onSelect = function()
                print('Target selected')
            end
        }
    }
})
```

### CreateObject Code

```lua
local model = GetHashKey('prop_cs_cardbox_01')
RequestModel(model)
while not HasModelLoaded(model) do
    Wait(0)
end

-- CreateObject(model, x, y, z, networked, dynamic, door)
-- networked: true = synced across all clients, false = local only
local prop = CreateObject(model, 100.0, 200.0, 30.0, false, false, false)
SetEntityHeading(prop, 90.0)
FreezeEntityPosition(prop, true)
SetModelAsNoLongerNeeded(model)
```

### Vector3/Vector4 Coordinates

```lua
-- Vector3 (position only)
local coords = vector3(100.0, 200.0, 30.0)

-- Vector4 (position + heading)
local coords = vector4(100.0, 200.0, 30.0, 90.0)
```

## 🔧 Advanced Usage

### Integration with Custom Resources

You can integrate Envi-Zone-Tool into your own resources for seamless zone/prop placement:

```lua
-- Example: Shop shelf placement system
RegisterCommand('placeShelf', function(source, args)
    exports['envi-zone-tool']:StartPropPlacement({
        title = 'Place Shelf',
        model = 'prop_shelf_01',
        showUI = true,
        canPlace = function(coords)
            -- Validate placement is within shop bounds
            local shopData = GetShopData()
            return IsWithinShopBounds(coords, shopData)
        end
    }, function(result)
        if result.success then
            -- Save to database
            SaveShelfToDatabase({
                coords = result.coords,
                heading = result.heading,
                model = 'prop_shelf_01'
            })
            lib.notify({
                title = 'Success',
                description = 'Shelf placed successfully!',
                type = 'success'
            })
        end
    end)
end)
```

### Validation Functions

Use `canPlace` to restrict where zones/props can be placed:

```lua
exports['envi-zone-tool']:StartZonePlacement({
    title = 'Restricted Zone',
    canPlace = function(coords)
        -- Only allow placement within 100 units of a specific point
        local centerPoint = vector3(0.0, 0.0, 72.0)
        local distance = #(coords - centerPoint)
        
        if distance > 100.0 then
            lib.notify({
                title = 'Too Far',
                description = 'Zone must be within 100 units of center',
                type = 'error'
            })
            return false
        end
        
        -- Check if zone overlaps with existing zones
        if ZoneOverlaps(coords) then
            lib.notify({
                title = 'Overlap',
                description = 'Zone overlaps with existing zone',
                type = 'error'
            })
            return false
        end
        
        return true
    end
}, function(result)
    -- Handle result
end)
```

### Batch Placement

You can chain multiple placements:

```lua
local placements = {}
local currentIndex = 1

local function PlaceNext()
    if currentIndex > #placements then
        print('All placements complete!')
        return
    end
    
    local placement = placements[currentIndex]
    
    if placement.type == 'zone' then
        exports['envi-zone-tool']:StartZonePlacement({
            title = placement.title,
            showUI = false
        }, function(result)
            if result.success then
                placement.result = result.data
                currentIndex = currentIndex + 1
                PlaceNext()
            end
        end)
    else
        exports['envi-zone-tool']:StartPropPlacement({
            title = placement.title,
            model = placement.model,
            showUI = false
        }, function(result)
            if result.success then
                placement.result = result
                currentIndex = currentIndex + 1
                PlaceNext()
            end
        end)
    end
end

-- Start batch placement
PlaceNext()
```

## 📚 API Reference

### Exports

| Export | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `StartZonePlacement` | Start zone placement | `options` (table), `callback` (function) | None |
| `StartPropPlacement` | Start prop placement | `options` (table), `callback` (function) | None |
| `IsPlacementActive` | Check if placement is active | None | `boolean` |
| `CancelPlacement` | Cancel active placement | None | None |
| `DrawSphere` | Draw sphere marker | `coords`, `radius`, `r`, `g`, `b`, `a` | None |
| `DrawCenterMarker` | Draw center marker | `coords`, `r`, `g`, `b` | None |
| `DrawBoxWireframe` | Draw box wireframe | `center`, `size`, `rotation`, `r`, `g`, `b`, `a` | None |

### Callback Results

#### Zone Placement Result

```lua
{
    success = true,
    data = {
        coords = vector3(100.0, 200.0, 30.0),
        zoneType = "sphere",  -- or "box"
        radius = 2.5,        -- sphere only
        size = vector3(2.0, 2.0, 2.0),  -- box only
        rotation = 45.0      -- box only
    }
}
```

#### Prop Placement Result

```lua
{
    success = true,
    coords = vector3(100.0, 200.0, 30.0),
    heading = 90.0
}
```

## 💡 Examples

### Example 1: Shop Entrance Zone

```lua
RegisterCommand('setupShop', function()
    exports['envi-zone-tool']:StartZonePlacement({
        title = 'Shop Entrance',
        initialRadius = 2.0,
        color = { r = 0, g = 255, b = 0, a = 100 },
        showUI = true
    }, function(result)
        if result.success then
            -- Create ox_lib zone
            local zone = lib.zones.sphere({
                coords = result.data.coords,
                radius = result.data.radius,
                onEnter = function()
                    lib.notify({ title = 'Shop', description = 'Welcome!', type = 'info' })
                end,
                onExit = function()
                    lib.notify({ title = 'Shop', description = 'Goodbye!', type = 'info' })
                end
            })
            print('Shop entrance zone created!')
        end
    end)
end)
```

### Example 2: Multiple Shelf Placement

```lua
local shelfModels = {
    'prop_shelf_01',
    'prop_shelf_02',
    'prop_shelf_03'
}

local function PlaceShelf(index)
    if index > #shelfModels then
        print('All shelves placed!')
        return
    end
    
    exports['envi-zone-tool']:StartPropPlacement({
        title = 'Shelf ' .. index .. ' of ' .. #shelfModels,
        model = shelfModels[index],
        showUI = true
    }, function(result)
        if result.success then
            -- Save shelf
            SaveShelf({
                model = shelfModels[index],
                coords = result.coords,
                heading = result.heading
            })
            -- Place next shelf
            PlaceShelf(index + 1)
        end
    end)
end

RegisterCommand('placeShelves', function()
    PlaceShelf(1)
end)
```

### Example 3: Custom Zone with Validation

```lua
exports['envi-zone-tool']:StartZonePlacement({
    title = 'Restricted Area',
    initialRadius = 5.0,
    maxRadius = 10.0,
    color = { r = 255, g = 0, b = 0, a = 150 },
    canPlace = function(coords)
        -- Check distance from spawn
        local spawn = vector3(-1035.71, -2731.87, 12.86)
        local distance = #(coords - spawn)
        
        if distance < 50.0 then
            lib.notify({
                title = 'Error',
                description = 'Cannot place zone within 50m of spawn',
                type = 'error'
            })
            return false
        end
        
        -- Check if zone would overlap with existing zones
        local existingZones = GetExistingZones()
        for _, zone in ipairs(existingZones) do
            local dist = #(coords - zone.coords)
            if dist < (zone.radius + 5.0) then
                lib.notify({
                    title = 'Error',
                    description = 'Zone overlaps with existing zone',
                    type = 'error'
                })
                return false
            end
        end
        
        return true
    end,
    showUI = true
}, function(result)
    if result.success then
        CreateRestrictedZone(result.data)
    end
end)
```

## 🔍 Troubleshooting

### Issue: Zone/Prop placement not working

**Solution:**
- Ensure `ox_lib` is installed and running
- Check that you're not already in a placement session (use `/zone_tool` or `/prop_tool` to cancel)
- Verify the resource is started: `ensure envi-zone-tool`

### Issue: UI not showing after export

**Solution:**
- Exports default to `showUI = false`. Set `showUI = true` in your options:
  ```lua
  exports['envi-zone-tool']:StartZonePlacement({
      showUI = true  -- Add this
  }, callback)
  ```

### Issue: Prop model not loading

**Solution:**
- Verify the model name is correct (check in-game or use a model viewer)
- Ensure the model exists in your game files
- Try using the model hash instead of name:
  ```lua
  model = GetHashKey('prop_cs_cardbox_01')
  ```

### Issue: Controls not responding

**Solution:**
- Check that no other script is blocking the controls
- Verify control mappings in `shared/config.lua`
- Ensure you're in the correct placement step (position vs. size)

### Issue: Code generation shows wrong format

**Solution:**
- The UI generates code based on the zone type (sphere/box)
- Make sure you selected the correct zone type during placement
- You can manually edit the generated code after copying

## 📝 Tips & Best Practices

1. **Zone Type Selection**
   - **Circle zones** are simpler and better for most use cases (interaction areas, trigger zones)
   - **Box zones** offer more control but require adjusting 4 dimensions (width, length, height, rotation)
   - Use box zones when you need rectangular areas or specific orientations

2. **Validation Functions**
   - Always use `canPlace` to restrict placement areas
   - Provide user feedback via `lib.notify()` when validation fails
   - Check for overlaps with existing zones/props

3. **Code Customization**
   - After copying generated code, customize callbacks and options for your needs
   - Add error handling and edge cases
   - Consider using the generated code as a template

4. **Performance**
   - Don't place too many zones/props in a small area
   - Use appropriate zone sizes (larger zones = more performance impact)
   - Consider using `debug = false` in production

5. **Export Usage**
   - Set `showUI = false` for automated/programmatic placement
   - Set `showUI = true` when you want users to see and copy the code
   - Always handle the callback to know when placement completes

## 📄 License

Created by **Envi Scripts**

This script is included **FREE** as a dependency with any future Envi-Scripts resource that utilizes it, but is also available as a standalone purchase.

## 🤝 Support

For support, feature requests, or bug reports, please join the Envi Scripts Discord server.

---
