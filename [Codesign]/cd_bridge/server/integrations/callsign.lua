function GetCallsign(source)
    if Cfg.Framework =='qbcore' or Cfg.Framework =='qbox' then
        local Player = GetPlayer(source)
        if Player and Player.PlayerData and Player.PlayerData.metadata and Player.PlayerData.metadata.callsign then
            return Player.PlayerData.metadata.callsign
        end
    end

    if GetResourceState('cd_dispatch') == 'started' or GetResourceState('cd_dispatch3d') == 'started' then
        local identifier = GetIdentifier(source)
        if identifier then
            local result = DB.fetch('SELECT callsign FROM cd_dispatch WHERE identifier="'..identifier..'"')
            if result and result[1] and result[1].callsign then
                return result[1].callsign
            end
        end
    end

    return Locale('unknown')
end

function SetCallsign(source, callsign)
    if Cfg.Framework =='qbcore' or Cfg.Framework =='qbox' then
        local Player = GetPlayer(source)
        if Player and Player.PlayerData and Player.PlayerData.metadata then
            Player.PlayerData.metadata.callsign = callsign
            Player.Functions.SetMetaData('callsign', callsign)
            return
        end
    end

    if GetResourceState('cd_dispatch') == 'started' or GetResourceState('cd_dispatch3d') == 'started' then
        local identifier = GetIdentifier(source)
        if identifier then
            DB.exec('REPLACE INTO cd_dispatch (identifier, callsign) VALUES (?, ?)', {identifier, callsign})
            return
        end
    end
end