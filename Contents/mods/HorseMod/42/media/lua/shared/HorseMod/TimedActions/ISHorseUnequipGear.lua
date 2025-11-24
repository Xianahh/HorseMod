---@namespace HorseMod

---REQUIREMENTS
local Attachments = require("HorseMod/Attachments")
local ISHorseEquipGear = require("HorseMod/TimedActions/ISHorseEquipGear")

---@class ISHorseUnequipGear : ISHorseEquipGear
---@field horse IsoAnimal
---@field oldAccessory InventoryItem
---@field attachmentDef AttachmentDefinition
---@field unlockFn fun()?
local ISHorseUnequipGear = ISHorseEquipGear:derive("ISHorseUnequipGear")

function ISHorseUnequipGear:start()
    self:setActionAnim(self.attachmentDef.unequipAnim or "Loot")
    self.character:faceThisObject(self.horse)
end

function ISHorseUnequipGear:perform()
    local horse = self.horse
    local player = self.character
    local oldAccessory = self.oldAccessory
    local attachmentDef = self.attachmentDef
    local slot = attachmentDef.slot

    -- remove old accessory from slot and give to player or drop
    Attachments.setAttachedItem(horse, slot, nil)

    self:updateModData(horse, slot, nil, nil)

    self:giveBackToPlayerOrDrop(player, horse, oldAccessory)

    if self.unlockFn then
        self.unlockFn()
    end
    ISBaseTimedAction.perform(self)
end

---@param character IsoGameCharacter
---@param horse IsoAnimal
---@param oldAccessory InventoryItem
---@param unlockFn fun()?
---@return ISHorseUnequipGear
---@nodiscard
function ISHorseUnequipGear:new(character, horse, oldAccessory, unlockFn)
    local o = ISHorseEquipGear.new(self, character, horse, oldAccessory, unlockFn) --[[@as ISHorseUnequipGear]]
    o.horse   = horse
    o.oldAccessory = oldAccessory
    local attachmentDef = Attachments.getAttachmentDefinition(oldAccessory:getFullType())
    o.maxTime = attachmentDef.unequipTime or 90
    o.attachmentDef = attachmentDef
    o.unlockFn = unlockFn
    o.stopOnWalk = true
    o.stopOnRun  = true
    o.stopOnAim  = true
    return o
end

return ISHorseUnequipGear