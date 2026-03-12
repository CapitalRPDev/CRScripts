if not Config.JobVehicles.ENABLE then return end

function GenerateRandomJobVehiclePlate(originalPlate)
    local plate = Trim(originalPlate:upper())
    local length = #plate
    local result = 8-length

    if result ~= 0 then

        for cd = 1, result do
            plate = plate..math.random(0,9)
        end
    end

    if Config.VehicleKeys.ENABLE and KeysTable[plate] then
        return GenerateRandomJobVehiclePlate(originalPlate)
    end

    return plate
end

function SetVehicleMaxMods(vehicle)
    SetVehicleModKit(vehicle, 0)
    SetVehicleMod(vehicle, 11, 3, false)--engine
    SetVehicleMod(vehicle, 12, 2, false)--brakes
    SetVehicleMod(vehicle, 13, 2, false)--transmission
    SetVehicleMod(vehicle, 15, 2, false)--suspension
    SetVehicleMod(vehicle, 16, 4, false)--armor
    ToggleVehicleMod(vehicle,  18, true)--turbo
end

local function ChangeLivery(action, vehicle)
    local liveryCount = GetVehicleLiveryCount(vehicle)
    local livery = GetVehicleLivery(vehicle)
    if action == 'right' then
        livery = livery+1
        if livery == liveryCount then
            livery = 0
        end
        SetVehicleLivery(vehicle, livery)

    elseif action == 'left' then
            livery = livery-1
        if livery == -1 then
            livery = liveryCount-1
        end
        SetVehicleLivery(vehicle, livery)
    end
end

function SetLiverysThread()
    CreateThread(function()
        while true do
            Wait(5)
            local ped = PlayerPedId()
            if InVehicle() then
                local vehicle = GetVehiclePedIsIn(ped, false)
                DrawLiveryText('⬅️ '..Locale('pre_livery')..'. ➡️ '..Locale('next_livery')..'.\n ~b~['..Locale('enter')..']~w~ '..Locale('confirm')..'.')
                if IsControlJustReleased(0, 174) then
                    ChangeLivery('left', vehicle)
                elseif IsControlJustReleased(0, 175) then
                    ChangeLivery('right', vehicle)
                elseif IsControlJustReleased(0, 191) then
                    break
                end
            else
                break
            end
        end
    end)
end

RegisterNetEvent('cd_garage:SetJobOwnedVehicle')
AddEventHandler('cd_garage:SetJobOwnedVehicle', function(action)
    if action == 'personal' or action == 'society' then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if IsPedInAnyVehicle(ped, false) then
            TriggerServerEvent('cd_garage:SetJobOwnedVehicle', action, GetAllPlateFormats(vehicle))
        else
            Notif(3, 'get_inside_veh')
        end
    else
        print('wrong action type - SetJobOwnedVehicle')
    end
end)

--[[
--A chat command for a player to convert their personal vehicle into a personal owned/society owned job vehicle.
--Uncomment this if you want players to be able to use this.
RegisterCommand('JobVehicles', function(source, args)
    if args[1] == 'personal' or args[1] == 'society' then
        TriggerEvent('cd_garage:SetJobOwnedVehicle', args[1])
    else
        print('invalid option')
    end
end)
]]