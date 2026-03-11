function Notify(title, description, type)
    lib.notify({ title = title, description = description, type = type })
end

function GetSizeControlsText(title, zoneType, radius, size, boxEditMode, rotation)
    local txt = {
        '📐 **' .. title .. '**  \n',
        '━━━━━━━━━━━━━  \n',
        '**Step 2:** Adjust Zone Size  \n',
        '━━━━━━━━━━━━━  \n',

    }

    if zoneType == 'sphere' then
        txt[#txt + 1] = '⭕ **CIRCLE** Zone  \n'
        txt[#txt + 1] = '━━━━━━━━━━━━━  \n'
        txt[#txt + 1] = '**Radius:** **' .. string.format('%.2fm', radius) .. '**  \n'
        txt[#txt + 1] = '**[SCROLL]** - *Adjust Radius*  \n'
    else
        txt[#txt + 1] = '📦 **BOX** Zone  \n'
        txt[#txt + 1] = '**[H]** - *Switch Dimension*  \n'
        txt[#txt + 1] = '**[SCROLL]** - *Adjust*  \n'
        if boxEditMode == 'width' then
            txt[#txt + 1] = '**Width:** **' .. string.format('%.2fm', size.x) .. '**  \n'
        elseif boxEditMode == 'length' then
            txt[#txt + 1] = '**Length:** **' .. string.format('%.2fm', size.y) .. '**  \n'
        elseif boxEditMode == 'height' then
            txt[#txt + 1] = '**Height:** **' .. string.format('%.2fm', size.z) .. '**  \n'
        else
            txt[#txt + 1] = '**Rotation:** **' .. string.format('%.0f°', rotation) .. '**  \n'
        end
    end

    txt[#txt + 1] = '━━━━━━━━━━━━━  \n'
    txt[#txt + 1] = '**[ARROWS]** - *Position*  \n'
    txt[#txt + 1] = '**[PGUP/PGDN]** - *Height*  \n'
    txt[#txt + 1] = '━━━━━━━━━━━━━  \n'
    txt[#txt + 1] = '**[E]** - *Confirm*  \n'
    txt[#txt + 1] = '**[X]** - *Cancel*'

    return table.concat(txt)
end

function GetPropPlacementText(title, currentHeading)
    return table.concat({
        '📦 **' .. title .. '**  \n',
        '━━━━━━━━━━━━━  \n',
        '**Position & Rotation**  \n',
        '**[SCROLL]** - *Rotate*  \n',
        '**[ARROWS]** - *Fine-tune Position*  \n',
        '**[SHIFT]** - *Fast mode*  \n',
        '**Heading:** ' .. ('%.1f°'):format(currentHeading) .. '  \n',
        '━━━━━━━━━━━━━  \n',
        '**[E]** - *Confirm*  \n',
        '**[X]** - *Cancel*'
    })
end

function GetZonePlacementStep1Text(title)
    return table.concat({
        '📍 **' .. title .. '**  \n',
        '━━━━━━━━━━━━━  \n',
        '**Step 1:** Place Center Point  \n',
        '**[ARROWS]** - *Fine-tune Position*  \n',
        '**[PGUP/PGDN]** - *Adjust Height*  \n',
        '**[SHIFT]** - *Fast movement*  \n',
        '━━━━━━━━━━━━━  \n',
        '**[E]** - *Confirm*  \n',
        '**[X]** - *Cancel*'
    })
end

Labels = {
    zoneType = {
        confirm = '⭕ Circle (Simple)',
        cancel = '📦 Box (Advanced)'
    }
}

Notifications = {
    placementActiveProp = { title = 'Placement Active', description = 'Already placing a prop', type = 'error' },
    errorLoadModel = { title = 'Error', description = 'Failed to load prop model', type = 'error' },
    tooFarProp = { title = 'Too Far', description = 'Prop must be placed closer', type = 'error' },
    cancelledProp = { title = 'Cancelled', description = 'Prop placement cancelled', type = 'error' },
    placementActiveZone = { title = 'Placement Active', description = 'Already placing a zone', type = 'error' },
    tooFarZone = { title = 'Too Far', description = 'Zone must be placed closer', type = 'error' },
    cancelledZone = { title = 'Cancelled', description = 'Zone placement cancelled', type = 'error' },
    alreadyActive = { title = 'Already Active', description = 'A placement is already active', type = 'error' },
    copied = { title = 'Copied!', description = 'Code copied to clipboard', type = 'success' },
    copyFailed = { title = 'Error', description = 'Failed to copy to clipboard', type = 'error' },
}

Titles = {
    zonePlacement = 'Zone Placement',
    zoneCreator = 'Zone Creator',
    propPlacement = 'Prop Placement',
    polyZonePlacement = 'Poly Zone Creator',
}
