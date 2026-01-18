require("TimedActions/ISBaseTimedAction")

local MountPair = require("HorseMod/MountPair")
local AnimationVariable = require("HorseMod/AnimationVariable")
local Mounts = require("HorseMod/Mounts")
local MountingUtility = require("HorseMod/mounting/MountingUtility")


---@namespace HorseMod


---@class MountHorseAction : ISBaseTimedAction
---
---@field pair MountPair
---
---@field mount IsoAnimal
---
---@field side string
---
---@field saddle InventoryItem | nil
---
---@field lockDir number
local MountHorseAction = ISBaseTimedAction:derive("HorseMod_MountHorseAction")



function MountHorseAction:isValid()
    if self.mount:isExistInTheWorld()
        and self.character:getSquare() then
        
        -- verify the player can still mount the horse
        if MountingUtility.canMountHorse(self.character, self.mount) then
            return true
        end
        return false
    else
        return false
    end
end

function MountHorseAction:waitToStart()
    -- self.character:faceThisObject(self.mount)
    self.lockDir = self.mount:getDirectionAngle()
    self.character:setDirectionAngle(self.lockDir)
	return self.character:shouldBeTurning()
end


function MountHorseAction:update()
    -- fix the mount and rider to look in the same direction for animation alignment
    self.mount:setDirectionAngle(self.lockDir)
    
    local character = self.character
    character:setIsAiming(false)
    character:setDirectionAngle(self.lockDir)

    if character:getVariableBoolean(AnimationVariable.MOUNT_FINISHED) == true then
        character:setVariable(AnimationVariable.MOUNT_FINISHED, false)
        self:forceComplete()
    end
end


function MountHorseAction:start()
    -- freeze horse and log horse facing direction
    -- self.horse:getPathFindBehavior2():reset()
    -- self.horse:getBehavior():setBlockMovement(true)
    -- self.horse:stopAllMovementNow()

    self.mount:setVariable(AnimationVariable.DYING, false)

    -- self.lockDir = self.mount:getDirectionAngle()
    -- self.character:setDir(self.lockDir)

    self.character:setVariable(AnimationVariable.MOUNTING_HORSE, true)
    self.character:setVariable(AnimationVariable.MOUNT_FINISHED, false)
    self.character:setVariable(AnimationVariable.DYING, false)

    if self.side == "right" then
        if self.saddle then
            self:setActionAnim("Bob_Mount_Saddle_Right")
        else
            self:setActionAnim("Bob_Mount_Bareback_Right")
        end

    elseif self.side == "left" then
        if self.saddle then
            self:setActionAnim("Bob_Mount_Saddle_Left")
        else
            self:setActionAnim("Bob_Mount_Bareback_Left")
        end
    end
end


function MountHorseAction:stop()
    -- self.horse:getBehavior():setBlockMovement(false)

    self.pair:setAnimationVariable(AnimationVariable.RIDING_HORSE, false)
    self.character:setVariable(AnimationVariable.MOUNTING_HORSE, false)
    self.character:setVariable("isTurningLeft", false)
    self.character:setVariable("isTurningRight", false)
    self.character:setTurnDelta(1)

    self.character:setVariable(AnimationVariable.MOUNTING_HORSE, false)

    ISBaseTimedAction.stop(self)
end


function MountHorseAction:complete()
    -- TODO: this might take a bit to inform the client, so we should consider faking it in perform()
    Mounts.addMount(self.character, self.mount)
    return true
end


function MountHorseAction:perform()
    -- HACK: we can't require this at file load because it is in the client dir
    local HorseSounds = require("HorseMod/HorseSounds")
    HorseSounds.playSound(self.mount, HorseSounds.Sound.MOUNT)

    ISBaseTimedAction.perform(self)
end


function MountHorseAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end

    return -1
end


---@param pair MountPair
---@param side string
---@param saddle InventoryItem | nil
---@return self
---@nodiscard
function MountHorseAction:new(pair, side, saddle)
    ---@type MountHorseAction
    local o = ISBaseTimedAction.new(self, pair.rider)

    -- HACK: this loses its metatable when transmitted by the server
    pair = convertToPZNetTable(pair)
    setmetatable(pair, MountPair)
    o.pair = pair
    o.mount = pair.mount
    o.side = side
    o.saddle = saddle
    o.stopOnWalk = true
    o.stopOnRun  = true

    o.maxTime = o:getDuration()

    return o
end


_G[MountHorseAction.Type] = MountHorseAction


return MountHorseAction