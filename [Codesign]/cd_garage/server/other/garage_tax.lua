if Config.GarageTax.ENABLE then

    RegisterServerEvent('cd_garage:GarageTax')
    AddEventHandler('cd_garage:GarageTax', function(serverid)
        if GarageTaxTable == nil or GarageTaxTable.unique_ids == nil then return end

        if serverid == nil then
            _source = source
        elseif type(serverid) == 'number' then
            _source = serverid
        end
        
        local identifier = GetIdentifier(_source)
        if GarageTaxTable.check[_source] == nil then
            local MY_unique_id = GetUniqueIdentifier(_source, identifier)
            local cantax = true
            for c, d in pairs(GarageTaxTable.unique_ids) do
                if d and d == MY_unique_id then
                    cantax = false
                    break
                end
            end

            if cantax then
                GarageTaxTable.check[_source] = true
                table.insert(GarageTaxTable.unique_ids, MY_unique_id)
                local TaxDisShit = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE '..FW.vehicle_identifier..'="'..identifier..'"')
                if TaxDisShit and TaxDisShit[1] then
                    for cd=1, #TaxDisShit do
                        if TaxDisShit[cd].vehicle ~= nil then
                            TriggerClientEvent('cd_garage:GarageTax', _source, json.decode(TaxDisShit[cd].vehicle).model)
                        end
                    end
                end
            end
            cantax = nil
        end
    end)

    function GetUniqueIdentifier(source, identifier)
        return GetPhoneNumber(source)
    end

    RegisterServerEvent('cd_garage:PayTax')
    AddEventHandler('cd_garage:PayTax', function(amount, garagecount)
        local _source = source
        RemovePlayerMoney(_source, amount, 'bank')
        Notif(_source, 2, 'pay_tax', garagecount, math.ceil(amount), 'garage_tax')
    end)
    
end
