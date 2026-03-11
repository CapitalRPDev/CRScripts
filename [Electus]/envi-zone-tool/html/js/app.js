let currentData = null;

// Editor Control Panel State
const editorState = {
    zone: { visible: false, extraVisible: true },
    poly: { visible: false },
    point: { visible: false },
    prop: { visible: false, extraVisible: true }
};

window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'showZoneData') {
        showZoneData(data.data);
    } else if (data.action === 'showPropData') {
        showPropData(data.data);
    } else if (data.action === 'zoneControlsShow') {
        showZoneControls(data.data);
    } else if (data.action === 'zoneControlsHide') {
        hideZoneControls();
    } else if (data.action === 'zoneControlsToggle') {
        toggleZoneExtraControls();
    } else if (data.action === 'zoneControlsUpdate') {
        updateZoneControls(data.data);
    } else if (data.action === 'polyControlsShow') {
        showPolyControls(data.data);
    } else if (data.action === 'polyControlsHide') {
        hidePolyControls();
    } else if (data.action === 'polyControlsUpdate') {
        updatePolyControls(data.data);
    } else if (data.action === 'propControlsShow') {
        showPropControls();
    } else if (data.action === 'propControlsHide') {
        hidePropControls();
    } else if (data.action === 'propControlsToggle') {
        togglePropExtraControls();
    } else if (data.action === 'pointControlsShow') {
        showPointControls(data.data);
    } else if (data.action === 'pointControlsHide') {
        hidePointControls();
    } else if (data.action === 'pointControlsUpdate') {
        updatePointControls(data.data);
    }
});

// Zone Controls
function showZoneControls(data) {
    const el = document.getElementById('zoneControls');
    el.style.display = 'block';
    editorState.zone.visible = true;
    if (data) updateZoneControls(data);
}

function hideZoneControls() {
    document.getElementById('zoneControls').style.display = 'none';
    editorState.zone.visible = false;
}

function toggleZoneExtraControls() {
    const el = document.getElementById('zoneExtraControls');
    editorState.zone.extraVisible = !editorState.zone.extraVisible;
    el.style.display = editorState.zone.extraVisible ? 'flex' : 'none';
}

function updateZoneControls(data) {
    if (data.type) {
        document.getElementById('zoneStatusValue').textContent = data.type;
    }
    if (data.editMode) {
        const scrollAction = document.getElementById('zoneScrollAction');
        const statusValue = document.getElementById('zoneStatusValue');
        const scrollMap = {
            'width': 'Width (X)',
            'length': 'Length (Y)',
            'height': 'Height (Z)',
            'rotation': 'Rotation',
            'radius': 'Radius'
        };
        const friendlyName = {
            'width': 'Width',
            'length': 'Length',
            'height': 'Height',
            'rotation': 'Rotation',
            'radius': 'Radius'
        };
        scrollAction.textContent = scrollMap[data.editMode] || 'Size';
        statusValue.textContent = friendlyName[data.editMode] || data.editMode;
    }
}

// Poly Controls
function showPolyControls(data) {
    document.getElementById('polyControls').style.display = 'block';
    editorState.poly.visible = true;
    if (data) updatePolyControls(data);
}

function hidePolyControls() {
    document.getElementById('polyControls').style.display = 'none';
    editorState.poly.visible = false;
}

function updatePolyControls(data) {
    if (data.pointCount !== undefined) {
        document.getElementById('polyPointCount').textContent = data.pointCount;
        const minHint = document.getElementById('polyMinHint');
        if (data.pointCount >= 3) {
            minHint.textContent = '✓';
            minHint.style.color = '#22c55e';
        } else {
            minHint.textContent = '(min 3)';
            minHint.style.color = '';
        }
    }
}

// Prop Controls
function showPropControls() {
    document.getElementById('propControls').style.display = 'block';
    editorState.prop.visible = true;
}

function hidePropControls() {
    document.getElementById('propControls').style.display = 'none';
    editorState.prop.visible = false;
}

function togglePropExtraControls() {
    const el = document.getElementById('propExtraControls');
    editorState.prop.extraVisible = !editorState.prop.extraVisible;
    el.style.display = editorState.prop.extraVisible ? 'flex' : 'none';
}

// Point Controls
function showPointControls(data) {
    document.getElementById('pointControls').style.display = 'block';
    editorState.point.visible = true;
    if (data) updatePointControls(data);
}

function hidePointControls() {
    document.getElementById('pointControls').style.display = 'none';
    editorState.point.visible = false;
}

function updatePointControls(data) {
    if (data.pointCount !== undefined) {
        document.getElementById('pointPointCount').textContent = data.pointCount;
    }
    if (data.maxPoints !== undefined) {
        document.getElementById('pointMaxCount').textContent = data.maxPoints === 0 ? '∞' : data.maxPoints;
    }
}

function resetScrollbars() {
    const content = document.querySelector('.content');
    if (content) {
        content.scrollTop = 0;
    }
    
    const codeBlocks = document.querySelectorAll('.code-block pre');
    codeBlocks.forEach(block => {
        block.scrollTop = 0;
    });
}

function showZoneData(data) {
    currentData = data;
    const app = document.getElementById('app');
    const zoneInfo = document.getElementById('zoneInfo');
    const propInfo = document.getElementById('propInfo');
    
    document.getElementById('title').textContent = 'Zone Creator';
    app.style.display = 'block';
    zoneInfo.style.display = 'block';
    propInfo.style.display = 'none';
    
    resetScrollbars();
    setNuiFocus(true, true);
    
    let zoneType = '';
    if (data.zoneType === 'sphere') {
        zoneType = '⭕ Circle Zone';
    } else if (data.zoneType === 'box') {
        zoneType = '📦 Box Zone';
    } else if (data.zoneType === 'poly') {
        zoneType = '🔺 Polygon Zone';
    }
    document.getElementById('zoneType').textContent = zoneType;
    
    const coords = `vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)})`;
    document.getElementById('zoneCoords').textContent = coords;
    
    if (data.zoneType === 'sphere') {
        document.getElementById('radiusInfo').style.display = 'flex';
        document.getElementById('sizeInfo').style.display = 'none';
        document.getElementById('rotationInfo').style.display = 'none';
        document.getElementById('pointsInfo').style.display = 'none';
        document.getElementById('zoneRadius').textContent = `${data.radius.toFixed(2)}m`;
    } else if (data.zoneType === 'box') {
        document.getElementById('radiusInfo').style.display = 'none';
        document.getElementById('sizeInfo').style.display = 'flex';
        document.getElementById('rotationInfo').style.display = 'flex';
        document.getElementById('pointsInfo').style.display = 'none';
        document.getElementById('zoneSize').textContent = `${data.size.x.toFixed(2)} × ${data.size.y.toFixed(2)} × ${data.size.z.toFixed(2)}m`;
        document.getElementById('zoneRotation').textContent = `${data.rotation.toFixed(0)}°`;
    } else if (data.zoneType === 'poly') {
        document.getElementById('radiusInfo').style.display = 'none';
        document.getElementById('sizeInfo').style.display = 'none';
        document.getElementById('rotationInfo').style.display = 'none';
        document.getElementById('pointsInfo').style.display = 'flex';
        document.getElementById('zonePoints').textContent = `${data.points.length} points`;
    }
    
    generateOxLibZoneCode(data);
    generateOxTargetZoneCode(data);
    
    setTimeout(() => {
        resetScrollbars();
    }, 10);
}

function showPropData(data) {
    currentData = data;
    const app = document.getElementById('app');
    const zoneInfo = document.getElementById('zoneInfo');
    const propInfo = document.getElementById('propInfo');
    
    document.getElementById('title').textContent = 'Prop Placement';
    app.style.display = 'block';
    zoneInfo.style.display = 'none';
    propInfo.style.display = 'block';
    
    resetScrollbars();
    setNuiFocus(true, true);
    
    document.getElementById('propModel').textContent = data.model;
    
    const coords = `vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)})`;
    document.getElementById('propCoords').textContent = coords;
    
    document.getElementById('propHeading').textContent = `${data.heading.toFixed(2)}°`;
    
    generatePropCreationCode(data);
    
    generatePropVectorCode(data);
    
    setTimeout(() => {
        resetScrollbars();
    }, 10);
}

function generateOxLibZoneCode(data) {
    let code = '';

    if (data.zoneType === 'sphere') {
        code = `local myZone = lib.zones.sphere({
    coords = vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}),
    radius = ${data.radius.toFixed(2)},
    debug = false,
    onEnter = function(self)
        print('Entered zone')
    end,
    onExit = function(self)
        print('Exited zone')
    end,
    inside = function(self)
        -- Called every frame while inside
    end
})`;
    } else if (data.zoneType === 'box') {
        code = `local myZone = lib.zones.box({
    coords = vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}),
    size = vec3(${data.size.x.toFixed(2)}, ${data.size.y.toFixed(2)}, ${data.size.z.toFixed(2)}),
    rotation = ${data.rotation.toFixed(2)},
    debug = false,
    onEnter = function(self)
        print('Entered zone')
    end,
    onExit = function(self)
        print('Exited zone')
    end,
    inside = function(self)
        -- Called every frame while inside
    end
})`;
    } else if (data.zoneType === 'poly') {
        let pointsStr = '';
        data.points.forEach((point, index) => {
            pointsStr += `        vec3(${point.x.toFixed(2)}, ${point.y.toFixed(2)}, ${point.z.toFixed(2)})${index < data.points.length - 1 ? ',' : ''}\n`;
        });

        code = `local myZone = lib.zones.poly({
    points = {\n${pointsStr}    },
    thickness = 2.0,
    debug = false,
    onEnter = function(self)
        print('Entered zone')
    end,
    onExit = function(self)
        print('Exited zone')
    end,
    inside = function(self)
        -- Called every frame while inside
    end
})`;
    }

    document.getElementById('oxLibZone').textContent = code;
}

function generateOxTargetZoneCode(data) {
    let code = '';

    if (data.zoneType === 'sphere') {
        code = `exports.ox_target:addSphereZone({
    coords = vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}),
    radius = ${data.radius.toFixed(2)},
    debug = false,
    options = {
        {
            name = 'my_option',
            icon = 'fa-solid fa-hand',
            label = 'Interact',
            onSelect = function()
                print('Target selected')
            end,
            canInteract = function(entity, distance, coords, name)
                return true
            end
        }
    }
})`;
    } else if (data.zoneType === 'box') {
        code = `exports.ox_target:addBoxZone({
    coords = vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}),
    size = vec3(${data.size.x.toFixed(2)}, ${data.size.y.toFixed(2)}, ${data.size.z.toFixed(2)}),
    rotation = ${data.rotation.toFixed(2)},
    debug = false,
    options = {
        {
            name = 'my_option',
            icon = 'fa-solid fa-hand',
            label = 'Interact',
            onSelect = function()
                print('Target selected')
            end,
            canInteract = function(entity, distance, coords, name)
                return true
            end
        }
    }
})`;
    } else if (data.zoneType === 'poly') {
        let pointsStr = '';
        data.points.forEach((point, index) => {
            pointsStr += `        vec3(${point.x.toFixed(2)}, ${point.y.toFixed(2)}, ${point.z.toFixed(2)})${index < data.points.length - 1 ? ',' : ''}\n`;
        });

        code = `exports.ox_target:addPolyZone({
    points = {\n${pointsStr}    },
    thickness = 2.0,
    debug = false,
    options = {
        {
            name = 'my_option',
            icon = 'fa-solid fa-hand',
            label = 'Interact',
            onSelect = function()
                print('Target selected')
            end,
            canInteract = function(entity, distance, coords, name)
                return true
            end
        }
    }
})`;
    }

    document.getElementById('oxTargetZone').textContent = code;
}

function generatePropCreationCode(data) {
    const code = `local model = GetHashKey('${data.model}')
RequestModel(model)
while not HasModelLoaded(model) do
    Wait(0)
end

-- CreateObject(model, x, y, z, networked, dynamic, door)
-- networked: true = synced across all clients, false = local only
local prop = CreateObject(model, ${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}, false, false, false)
SetEntityHeading(prop, ${data.heading.toFixed(2)})
FreezeEntityPosition(prop, true)
SetModelAsNoLongerNeeded(model)`;
    
    document.getElementById('propCreationCode').textContent = code;
}

function generatePropVectorCode(data) {
    const code = `-- Vector3 (position only)
vec3(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)})

-- Vector4 (position + heading)
vec4(${data.coords.x.toFixed(2)}, ${data.coords.y.toFixed(2)}, ${data.coords.z.toFixed(2)}, ${data.heading.toFixed(2)})

-- Table format
{ x = ${data.coords.x.toFixed(2)}, y = ${data.coords.y.toFixed(2)}, z = ${data.coords.z.toFixed(2)}, w = ${data.heading.toFixed(2)} }`;
    
    document.getElementById('propVectorCode').textContent = code;
}

function closeUI() {
    const app = document.getElementById('app');
    app.style.display = 'none';
    setNuiFocus(false, false);
    
    fetch(`https://envi-zone-tool/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

function copyCode(elementId) {
    const code = document.getElementById(elementId).textContent;
    const copyBtn = document.querySelector(`button[onclick="copyCode('${elementId}')"]`);
    
    fetch(`https://envi-zone-tool/copyToClipboard`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: code })
    }).then((response) => {
        if (copyBtn) {
            const originalText = copyBtn.innerHTML;
            copyBtn.classList.add('copied');
            copyBtn.innerHTML = '✓ Copied';
            
            setTimeout(() => {
                copyBtn.classList.remove('copied');
                copyBtn.innerHTML = originalText;
            }, 2000);
        }
    }).catch((err) => {
        console.error('Fetch failed:', err);
    });
}

function setNuiFocus(hasFocus, hasCursor) {
    fetch(`https://envi-zone-tool/setNuiFocus`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ hasFocus, hasCursor })
    }).catch(() => {});
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});