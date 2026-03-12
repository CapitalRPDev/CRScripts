--- @param action string        The action to perform ('show' or 'hide').
--- @param text string          The text to display (only for 'show' action).
function DrawTextUI(action, text)
    local method = Cfg.DrawTextUI

    if method == 'cd_drawtextui' then
        if action == 'show' then
            TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
        elseif action == 'hide' then
            TriggerEvent('cd_drawtextui:HideUI')
        end

    elseif method == 'jg-textui' then
        if action == 'show' then
            exports['jg-textui']:DrawText(text)
        elseif action == 'hide' then
            exports['jg-textui']:HideText()
        end

    elseif method == 'ox_lib' then
        if action == 'show' then
            exports.ox_lib:showTextUI(text)
        elseif action == 'hide' then
            exports.ox_lib:hideTextUI()
        end

    elseif method == 'okokTextUI' then
        if action == 'show' then
            exports['okokTextUI']:Open(text, false)
        elseif action == 'hide' then
            exports['okokTextUI']:Close()
        end

    elseif method == 'ps-ui' then
        if action == 'show' then
            exports['ps-ui']:DisplayText(text, 'primary', 'fa-solid fa-circle-info')
        elseif action == 'hide' then
            exports['ps-ui']:HideText()
        end

    elseif method == 'tgiann-core' then
        if action == 'show' then
            exports['tgiann-core']:DrawTextOpen('cd_bridge', '', text)
        elseif action == 'hide' then
            exports['tgiann-core']:DrawTextClose('cd_bridge')
        end

    elseif method == 'vms_notifyv2' then
        if action == 'show' then
            exports['vms_notifyv2']:ShowTextUI(text)
        elseif action == 'hide' then
            exports['vms_notifyv2']:HideTextUI()
        end

    elseif method == 'ZSX_UIV2' then
        if action == 'show' then
            exports['ZSX_UIV2']:TextUI_Persistent('', text)
        elseif action == 'hide' then
            exports['ZSX_UIV2']:TextUI_RemovePersistent(false)
        end

    elseif method == 'qb-core' then
        if action == 'show' then
            exports['qb-core']:DrawText(text)
        elseif action == 'hide' then
            exports['qb-core']:HideText()
        end

    elseif method == 'other' then
        if action == 'show' then
            -- Implement other text UI show method here.
        elseif action == 'hide' then
            -- Implement other text UI hide method here.
        end
    end
end