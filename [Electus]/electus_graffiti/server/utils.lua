function Notify(src, text, type)
    TriggerClientEvent('ox_lib:notify', src, {
        title = L("gangs"),
        description = text,
        type = type
    })
end

function Split(string, delimiter)
    local result = {}
    for match in (string..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end