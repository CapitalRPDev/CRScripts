if not Config.GangGarages.ENABLE then return end

local GangBlips = {}
local playerInGang = false

local function DeleteGangBlips()
    for _, blip in ipairs(GangBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end

local function ValidateGangGarageConfig()
    for _, normal in pairs(Config.Locations) do
        for _, gang in pairs(Config.GangGarages.Locations) do
            if normal.Garage_ID == gang.garage_id then
                DisableGangGarages()
                return false
            end
        end
    end
    return true
end

function DisableGangGarages()
    Config.GangGarages.ENABLE = false
    ERROR('4575', 'cd_garage: Gang garages have been disabled due to a Garage_ID conflict with normal garages.')
    PlayerLeftGang()
end

function IsPlayerInAnyGang()
    return playerInGang
end

function PlayerChangedGang()
    if UsingTarget() then
        DeleteAllGangGarageTargetZones()
    end
    DeleteGangBlips()
    UpdateGangGarageBlips()
    playerInGang = true
end

function PlayerLeftGang()
    DeleteGangBlips()
    playerInGang = false
    if UsingTarget() then
        DeleteAllGangGarageTargetZones()
    end
end

function UpdateGangGarageBlips()
    local gangName = GetGangName()

    for _, gang in pairs(Config.GangGarages.Locations) do
        if gang.gang == gangName then
            local blip = AddBlipForCoord(gang.coords.x, gang.coords.y, gang.coords.z)
            GangBlips[#GangBlips + 1] = blip

            SetBlipSprite(blip, Config.GangGarages.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.GangGarages.Blip.scale)
            SetBlipColour(blip, Config.GangGarages.Blip.colour)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.GangGarages.Blip.name .. gang.garage_id)
            EndTextCommandSetBlipName(blip)

            if UsingTarget() then
                CreateGangGarageTargetZone(gang)
            end
        end
    end
end

if not ValidateGangGarageConfig() then return end
UpdateGangGarageBlips()