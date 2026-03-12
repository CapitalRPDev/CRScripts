function FakePlateAdded(original_plate, fake_plate) --This is triggered when a player adds a fake plate.
    if GetResourceState('ox_inventory') == 'started' then
        exports['ox_inventory']:UpdateVehicle(original_plate, fake_plate)
    end
    --You can add other events/exports here to update other inventories when a fake plate is added.
end

function FakePlateRemoved(original_plate, fake_plate) --This is triggered when a player removes a fake plate.
    if GetResourceState('ox_inventory') == 'started' then
        exports['ox_inventory']:UpdateVehicle(original_plate, fake_plate)
    end
    --You can add other events/exports here to update other inventories when a fake plate is removed.
end