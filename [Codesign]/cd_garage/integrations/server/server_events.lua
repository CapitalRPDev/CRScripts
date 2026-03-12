RegisterServerEvent('cd_garage:SetGarageState', function(plate, state)
    if not plate or not state then return end
    DB.exec('UPDATE '..FW.vehicle_table..' SET in_garage=? WHERE plate=?', {state and 1 or 0, plate})
end)