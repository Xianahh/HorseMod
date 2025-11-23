local HorseRiding = require("HorseMod/Riding")
local Mounting = require("HorseMod/Mounting")
local HorseAttachments = require("HorseMod/horse/HorseAttachments")

ContextualActionHandlers = ContextualActionHandlers or {}


local _originalAnimalsInteraction = ContextualActionHandlers.AnimalsInteraction
function ContextualActionHandlers.AnimalsInteraction(action, playerObj, animal, arg2, arg3, arg4)
    local mountedHorse = HorseRiding.getMountedHorse(playerObj)

    -- dismount horse
    if mountedHorse == animal then
        if not playerObj:hasTimedActions() then
            Mounting.dismountHorse(playerObj)
        end
        return
    end

    -- equip attachment
    -- local equipedItem = playerObj:getPrimaryHandItem()
    -- if equipedItem then
        
    -- end

    -- horse ride
    if HorseRiding.isMountableHorse(animal) and HorseRiding.canMountHorse(playerObj, animal) and not playerObj:hasTimedActions() then
        local near = Mounting.getNearestMountPosition(playerObj, animal, 1.15)
        if near then
            playerObj:setIsAiming(false)
            Mounting.mountHorse(playerObj, animal)
            return
        end
    end

    return _originalAnimalsInteraction(action, playerObj, animal, arg2, arg3, arg4)
end
