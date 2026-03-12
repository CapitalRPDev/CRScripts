if not Config.FakePlates.ENABLE then return end

RegisterUsableItem(Config.FakePlates.item_name, function(source)
    TriggerClientEvent('cd_garage:FakePlate', source, 'add', GenerateRandomPlate())
end)

function GenerateRandomPlate()
    local plate = ''
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local numbers = '0123456789'
    for cd = 1, #Config.VehiclePlateFormats.new_plate_format do
        local char = string.sub(Config.VehiclePlateFormats.new_plate_format, cd, cd)
        if char == 'A' then
            local random_index = math.random(1, #letters)
            local random_char = string.sub(letters, random_index, random_index)
            plate = plate..random_char
        elseif char == '1' then
            local random_index = math.random(1, #numbers)
            local random_char = string.sub(numbers, random_index, random_index)
            plate = plate..random_char
        else
            plate = plate..char
        end
    end
    local Result = DB.fetch('SELECT plate FROM '..FW.vehicle_table..' WHERE plate="'..plate..'"')
    if Result and Result[1] == nil then
        return plate
    else
        return GenerateRandomPlate()
    end
end

function GetOriginalPlateFromFakePlate(plate)
    if FakePlateTable[plate] ~= nil and FakePlateTable[plate].originalplate ~= nil then
        return FakePlateTable[plate].originalplate
    else
        return plate
    end
end

RegisterServerEvent('cd_garage:FakePlate')
AddEventHandler('cd_garage:FakePlate', function(action, current_plate, vehicle, new_plate)
    local _source = source
    if action == 'add' then
        if FakePlateTable[current_plate] == nil then
            if CheckVehicleOwner(_source, current_plate) then
                FakePlateTable[new_plate] = {}
                FakePlateTable[new_plate].fakeplate = new_plate
                FakePlateTable[new_plate].originalplate = current_plate
                DB.exec('UPDATE '..FW.vehicle_table..' SET fakeplate="'..new_plate..'" WHERE plate="'..current_plate..'"')
                SetVehicleNumberPlateText(vehicle, new_plate)
                TriggerClientEvent('cd_garage:FakePlate_change', _source, action, vehicle, new_plate)
                RemoveItem(_source, Config.FakePlates.item_name, count)
                if Config.PersistentVehicles.ENABLE then
                    PersistentVehicle_FakePlate(current_plate, new_plate)
                end
                if Config.VehicleKeys.ENABLE then
                    Keys_FakePlate(current_plate, new_plate)
                end
                FakePlateAdded(current_plate, new_plate)
                Notif(_source, 1, 'fakeplate_add_success')
            else
                Notif(_source, 3, 'dont_own_vehicle')
            end
        else
            Notif(_source, 3, 'already_has_fakeplate')
        end
    elseif action == 'remove' then
        if FakePlateTable[current_plate] ~= nil then
            local originalPlate = FakePlateTable[current_plate].originalplate
            if CheckVehicleOwner(_source, originalPlate) or (Config.FakePlates.RemovePlate.allowed_jobs.ENABLE and Config.FakePlates.RemovePlate.allowed_jobs.table[GetJobName(_source)]) then
                DB.exec('UPDATE '..FW.vehicle_table..' SET fakeplate=@fakeplate WHERE plate=@plate',{
                    ['@fakeplate'] = nil,
                    ['@plate'] = originalPlate
                })
                TriggerClientEvent('cd_garage:FakePlate_change', _source, action, vehicle, originalPlate)
                if Config.PersistentVehicles.ENABLE then
                    PersistentVehicle_FakePlate(current_plate, originalPlate)
                end
                if Config.VehicleKeys.ENABLE then
                    Keys_FakePlate(current_plate, originalPlate)
                end
                FakePlateRemoved(current_plate, originalPlate)
                FakePlateTable[current_plate] = nil
                Notif(_source, 1, 'fakeplate_remove_success')
            else
                Notif(_source, 3, 'dont_own_vehicle')
            end
        else
            Notif(_source, 3, 'no_fakeplate')
        end
    end
end)