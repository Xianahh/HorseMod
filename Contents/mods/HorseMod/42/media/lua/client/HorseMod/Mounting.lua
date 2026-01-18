require("TimedActions/ISPathFindAction")

local HorseRiding = require("HorseMod/Riding")
local MountHorseAction = require("HorseMod/TimedActions/MountHorseAction")
local DismountHorseAction = require("HorseMod/TimedActions/DismountHorseAction")
local PathfindToMountPoint -- late load
local MountPair = require("HorseMod/MountPair")
local Attachments = require("HorseMod/attachments/Attachments")
local MountingUtility = require("HorseMod/mounting/MountingUtility")



local Mounting = {}

-- TODO: mountHorse and dismountHorse are too long and have a lot of redundant code

---@deprecated
Mounting.getNearestMountPosition = function(...)
    return MountingUtility.getNearestMountPosition(...)
end

---@deprecated
Mounting.getBestMountableHorse = function(...)
    return MountingUtility.getBestMountableHorse(...)
end

---@deprecated
Mounting.canMountHorse = function(...)
    return MountingUtility.canMountHorse(...)
end





---@param player IsoPlayer
---@param horse IsoAnimal
function Mounting.mountHorse(player, horse)
    if not MountingUtility.canMountHorse(player, horse) then
        return
    end

    local data = horse:getData()
    -- TODO: check if this nil check is actually necessary
    --  an animal's data *is* null by default,
    --  but it seems like it might always gets initialised when the animal spawns
    if data then
        -- Detach from tree
        local tree = data:getAttachedTree()
        if tree then
            data:setAttachedTree(nil)
            sendAttachAnimalToTree(horse, player, tree, true)
        end
        -- Detach from any leading player
        local leader = data:getAttachedPlayer()
        if leader then
            leader:getAttachedAnimals():remove(horse)
            data:setAttachedPlayer(nil)
            sendAttachAnimalToPlayer(horse, player, nil, true)
        end
    end


    --- pathfind to the mount position
    local mountPosition = MountingUtility.getNearestMountPosition(player, horse)
    assert(mountPosition ~= nil, "No mount position found when should be found. Report this to the mod authors.")

    PathfindToMountPoint = PathfindToMountPoint or require("HorseMod/TimedAction/PathfindToMountPoint")
    local pathfindAction = PathfindToMountPoint:new(
        player,
        mountPosition,
        horse
    )

    -- stop the horse from moving
    horse:getPathFindBehavior2():reset()

    -- create mount action
    local saddle = Attachments.getSaddle(horse)
    local pairing = MountPair.new(player, horse)
    local mountAction = MountHorseAction:new(pairing, mountPosition.name, saddle)

    -- patch to update to last known mount position
    function pathfindAction:perform()
        mountAction.side = self.mountPosition.name
        return PathfindToMountPoint.perform(self)
    end
    
    -- add to queue
    ISTimedActionQueue.add(pathfindAction)
    ISTimedActionQueue.add(mountAction)
end


---@param player IsoPlayer
function Mounting.dismountHorse(player)
    local mount = HorseRiding.getMount(player)
    if not mount then
        return
    end

    local horse = mount.pair.mount

    horse:getPathFindBehavior2():reset()

    local behavior = horse:getBehavior()
    behavior:setBlockMovement(true)
    behavior:setDoingBehavior(false)

    horse:stopAllMovementNow()
    local lockDir = horse:getDir()

    local lpos = horse:getAttachmentWorldPos("mountLeft")
    local rpos = horse:getAttachmentWorldPos("mountRight")
    local hx, hy = horse:getX(), horse:getY()

    local dl = (hx - lpos:x())^2 + (hy - lpos:y())^2
    local dr = (hx - rpos:x())^2 + (hy - rpos:y())^2
    local side, tx, ty, tz = "right", rpos:x(), rpos:y(), rpos:z()
    if dl < dr then side, tx, ty, tz = "left", lpos:x(), lpos:y(), lpos:z() end

    local function centerBlocked(nx, ny, nz)
        local sq = getSquare(nx, ny, nz)
        if not sq then
            return true
        end
        if sq:isSolid() or sq:isSolidTrans() then
            return true
        end
        return false
    end

    if centerBlocked(tx, ty, tz) then
        local ox = (side=="right") and lpos:x() or rpos:x()
        local oy = (side=="right") and lpos:y() or rpos:y()
        local oz = (side=="right") and lpos:z() or rpos:z()
        if not centerBlocked(ox, oy, oz) then
            if side == "right" then
                side = "left"
            else
                side = "right"
            end
            tx, ty, tz = ox, oy, oz
        end
    end

    local saddleItem = Attachments.getSaddle(horse)

    player:setDir(lockDir)

    local action = DismountHorseAction:new(
        mount,
        side,
        saddleItem ~= nil,
        tx,
        ty,
        tz
    )

    ISTimedActionQueue.add(action)
end


return Mounting