local HorseRiding = require("HorseMod/shared/HorseMod_Riding")

ContextualActionHandlers = ContextualActionHandlers or {}

local function sqr(x) return x * x end
local function dist2(ax, ay, bx, by) return sqr(ax - bx) + sqr(ay - by) end

local function isNearMountSide(player, horse, radius)
    radius = radius or 1.0
    local r2 = radius * radius

    if not (horse.getAttachmentWorldPos and player.DistToSquared) then
        return false, nil
    end

    local left  = horse:getAttachmentWorldPos("mountLeft")
    local right = horse:getAttachmentWorldPos("mountRight")
    if not (left and right) then return false, nil end

    local px, py = player:getX(), player:getY()
    local dl = dist2(px, py, left:x(),  left:y())
    local dr = dist2(px, py, right:x(), right:y())

    if dl <= r2 or dr <= r2 then
        return true, (dl <= dr) and "left" or "right"
    end
    return false, nil
end

local _originalAnimalsInteraction = ContextualActionHandlers.AnimalsInteraction
function ContextualActionHandlers.AnimalsInteraction(action, playerObj, animal, arg2, arg3, arg4)
    local mountedHorse = HorseRiding.getMountedHorse(playerObj)
    if mountedHorse == animal then
        HorseRiding.dismountHorse(playerObj)
        return
    end
    if HorseRiding and HorseRiding.isMountableHorse and HorseRiding.canMountHorse then
        if HorseRiding.isMountableHorse(animal) and HorseRiding.canMountHorse(playerObj, animal) then
            local near, side = isNearMountSide(playerObj, animal, 1.15)
            if near then
                playerObj:setIsAiming(false)
                HorseRiding.mountHorse(playerObj, animal)
                return
            end
        end
    end

    return _originalAnimalsInteraction(action, playerObj, animal, arg2, arg3, arg4)
end