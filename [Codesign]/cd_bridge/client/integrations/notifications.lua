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
    ['other'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
}

--- @param notif_type number     The type of notification (1=success, 2=info, 3=error).
--- @param message string        The notification message.
function Notification(notif_type, message)
    if not notif_type or not  message then ERROR('7231', 'Notifications arguments error') return end

    local title = Locale('title')
    local newNotifType = notifTypeConfig[Cfg.Notification] and notifTypeConfig[Cfg.Notification][notif_type]

    if Cfg.Notification == 'cd_notifications' then
        TriggerEvent('cd_notifications:Add',{title = title, message = message, type = newNotifType})

    elseif Cfg.Notification == 'chat' then
        TriggerEvent('chatMessage', message)

    elseif Cfg.Notification == 'mythic_notify' then
        exports.mythic_notify:DoLongHudText(message, newNotifType)

    elseif Cfg.Notification == 'okokNotify' then
        exports.okokNotify:Alert(title, message, 5000, newNotifType)

    elseif Cfg.Notification == 'origen_notify' then
        exports['origen_notify']:ShowNotification(message)

    elseif Cfg.Notification == 'ox_lib' then
        exports.ox_lib:notify({title = title, description = message, type = newNotifType})

    elseif Cfg.Notification == 'pNotify' then
        exports.pNotify:SendNotification({text = message, type = newNotifType, timeout = 5000})

    elseif Cfg.Notification == 'ps-ui' then
        exports['ps-ui']:Notify(message, newNotifType, 5000)

    elseif Cfg.Notification == 'rtx_notify' then
        TriggerEvent('rtx_notify:Notify', title, newNotifType, message, 5000)

    elseif Cfg.Notification == 'vms_notifyv2' then
        exports['vms_notifyv2']:Notification({title = title, description = message, time = 5000, color = '#34ebe8', icon = 'fa-solid fa-check'})

    elseif Cfg.Notification == 'ZSX_UIV2' then
        exports['ZSX_UIV2']:Notification(title, message)

    elseif Cfg.Notification == 'esx' then
        ESX.ShowNotification(message)

    elseif Cfg.Notification == 'qbox' then
        exports['qbx_core']:Notify(message, newNotifType)

    elseif Cfg.Notification == 'qbcore' then
        QBCore.Functions.Notify(message, newNotifType)

    elseif Cfg.Notification == 'other' then
        -- Implement other notification method here.
    else
        ERROR('8743', 'Notification system not configured properly in cd_bridge/shared/config.lua')
    end
end