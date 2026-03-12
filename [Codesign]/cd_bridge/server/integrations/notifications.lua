local notifTypeConfig = {
    ['cd_notifications'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['mythic_notify'] = {
        [1] = 'success',
        [2] = 'inform',
        [3] = 'error',
    },
    ['okokNotify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['ox_lib'] = {
        [1] = 'success',
        [2] = 'inform',
        [3] = 'error',
    },
    ['pNotify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['ps-ui'] = {
        [1] = 'success',
        [2] = 'primary',
        [3] = 'error',
    },
    ['rtx_notify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['qbox'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['qbcore'] = {
        [1] = 'success',
        [2] = 'primary',
        [3] = 'error',
    },
    ['custom'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
}

--- @param source number         The player source to send the notification to.
--- @param notif_type number     The type of notification (1=success, 2=info, 3=error).
--- @param message string        The notification message.
function Notification(source, notif_type, message)
    if not source or not notif_type or not message then ERROR('7231', 'Notifications arguments error') return end

    local newNotifType = notifTypeConfig[Cfg.Notification] and notifTypeConfig[Cfg.Notification][notif_type]

    if Cfg.Notification == 'cd_notifications' then
        TriggerClientEvent('cd_notifications:Add', source, {
            title = Locale('title'),
            message = message,
            type = newNotifType,
        })

    elseif Cfg.Notification == 'chat' then
        TriggerClientEvent('chatMessage', source, message)

    elseif Cfg.Notification == 'mythic_notify' then
        TriggerClientEvent('mythic_notify:DoLongHudText', source, newNotifType, message)

    elseif Cfg.Notification == 'okokNotify' then
        TriggerClientEvent('okokNotify:Alert', source, Locale('title'), message, 5000, newNotifType)

    elseif Cfg.Notification == 'origen_notify' then
        exports['origen_notify']:ShowNotification(source, message)

    elseif Cfg.Notification == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', source, { title = Locale('title'), description = message, type = newNotifType })

    elseif Cfg.Notification == 'pNotify' then
        TriggerClientEvent('pNotify:SendNotification', source, { text = message, type = newNotifType, timeout = 5000 })

    elseif Cfg.Notification == 'ps-ui' then
        TriggerClientEvent('ps-ui:Notify', source, message, newNotifType)

    elseif Cfg.Notification == 'rtx_notify' then
        TriggerClientEvent('rtx_notify:Notify', source, Locale('title'), message, 5000, newNotifType)

    elseif Cfg.Notification == 'vms_notifyv2' then
        TriggerClientEvent('vms_notifyv2:Notification', source, { title = Locale('title'), description = message, time = 5000, color = "#34ebe8", icon = "fa-solid fa-check"})

    elseif Cfg.Notification == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)

    elseif Cfg.Notification == 'qbox' then
        exports['qbx_core']:Notify(source, message, newNotifType)

    elseif Cfg.Notification == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', source, message, newNotifType)

    elseif Cfg.Notification == 'other' then
        -- Implement other notification method here.
    else
        ERROR('8743', 'Notification system not configured properly in cd_bridge/shared/config.lua')
    end
end