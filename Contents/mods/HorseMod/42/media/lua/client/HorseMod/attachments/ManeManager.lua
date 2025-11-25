---@namespace HorseMod

---REQUIREMENTS
local HorseUtils = require("HorseMod/Utils")
local Attachments = require("HorseMod/Attachments")

---@class ManeManager
local ManeManager = {}

---@param horse IsoAnimal
ManeManager.removeManes = function(horse)
    if not (horse and HorseUtils.isHorse(horse)) then
        return
    end

    local modData = HorseUtils.getModData(horse)
    local bySlot, ground = modData.bySlot, modData.ground

    for slot, _ in pairs(Attachments.MANE_SLOTS_SET) do
        local attached = Attachments.getAttachedItem(horse, slot)
        if attached then
            -- Attachments.setAttachedItem(horse, slot, nil)
            Attachments.removeAttachedItem(horse, attached)
        end
        bySlot[slot] = nil
        ground[slot] = nil
    end
end


return ManeManager