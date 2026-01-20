---REQUIREMENTS
local UrgentDismountAction = require("HorseMod/TimedActions/UrgentDismountAction")
local AnimationVariable = require("HorseMod/AnimationVariable")


local original_isPlayerDoingActionThatCanBeCancelled = isPlayerDoingActionThatCanBeCancelled

---Patch to make the urgent dismount action un-cancellable.
---
---Patch the function to take into account dynamic cancel flags on mount/dismount actions notably.
function isPlayerDoingActionThatCanBeCancelled(player)
    local queue = ISTimedActionQueue.getTimedActionQueue(player)
    local current = queue.current
    if current then
        local Type = current.Type
        if Type == UrgentDismountAction.Type then
            return false
        else
            local dynamicCancel = current.dynamicCancel ---@diagnostic disable-line not a field in ISBaseTimedAction
            player:addLineChatElement(tostring(player:getVariableBoolean(AnimationVariable.NO_CANCEL)))
            if dynamicCancel and dynamicCancel == true 
                and player:getVariableBoolean(AnimationVariable.NO_CANCEL) then
                return false
            end
        end
    end
    return original_isPlayerDoingActionThatCanBeCancelled(player)
end