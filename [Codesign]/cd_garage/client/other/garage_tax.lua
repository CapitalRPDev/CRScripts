if not Config.GarageTax.ENABLE then return end

local GarageTaxTable = {
    amount = 0,
    garage_count = 0,
    has_sent = false,
    price = Config.GarageTax.default_price
}

local function GetGarageTaxPrice(model)
    if Config.GarageTax.method == 'vehicles_data' and VehicleData and VehicleData[model] and VehicleData[model].price then
        return Round(VehicleData[model].price*0.01*Config.GarageTax.vehiclesdata_price_multiplier)
    else
        return Config.GarageTax.default_price
    end
end

RegisterNetEvent('cd_garage:GarageTax')
AddEventHandler('cd_garage:GarageTax', function(model)
    GarageTaxTable.price = GetGarageTaxPrice(model)
    GarageTaxTable.amount = GarageTaxTable.amount + GarageTaxTable.price
    GarageTaxTable.garage_count = GarageTaxTable.garage_count + 1
    if not GarageTaxTable.has_sent then
        TriggerEvent('cd_garage:PayTax')
        GarageTaxTable.has_sent = true
    end
end)

RegisterNetEvent('cd_garage:PayTax')
AddEventHandler('cd_garage:PayTax', function()
    if not GarageTaxTable.has_sent then
        Wait(5000)
        TriggerServerEvent('cd_garage:PayTax', GarageTaxTable.amount, Round(GarageTaxTable.garage_count))
        GarageTaxTable = nil
    end
end)