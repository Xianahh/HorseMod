---@namespace HorseMod

---@alias AttachmentSlot "Saddle"|"Saddlebags"|"Reins"|"ManeStart"|"ManeMid1"|"ManeMid2"|"ManeMid3"|"ManeMid4"|"ManeMid5"|"ManeEnd"|"Head"|"MountLeft"|"MountRight"

---Defines an attachment item with its associated slots and extra data if needed.
---@class AttachmentDefinition
---@field slot AttachmentSlot

---Maps items' fulltype to their associated attachment definition.
---@alias AttachmentsItemsMap table<string, AttachmentDefinition>

---Available item slots.
---@alias AttachmentsSlots AttachmentSlot[]

---Stores the various attachment data which are required to work with attachments for horses.
---@class Attachments
---@field items AttachmentsItemsMap
---@field SLOTS AttachmentsSlots
---@field MANE_SLOTS_SET table<AttachmentSlot, true>
local Attachments = {
    items = {
        -- saddles
            -- vanilla animals
        ["HorseMod.HorseSaddle_Crude"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_Black"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_CowHolstein"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_CowSimmental"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_White"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_Landrace"] = { slot = "Saddle" },
            -- horses
        ["HorseMod.HorseSaddle_AP"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_APHO"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_AQHBR"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_AQHP"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_FBG"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_GDA"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_LPA"] = { slot = "Saddle" },
        ["HorseMod.HorseSaddle_T"] = { slot = "Saddle" },

        -- saddlebags
            -- vanilla animals
        ["HorseMod.HorseSaddlebags_Crude"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_Black"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_CowHolstein"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_CowSimmental"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_White"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_Landrace"] = { slot = "Saddlebags" },
            -- horses
        ["HorseMod.HorseSaddlebags_AP"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_APHO"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_AQHBR"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_AQHP"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_FBG"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_GDA"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_LPA"] = { slot = "Saddlebags" },
        ["HorseMod.HorseSaddlebags_T"] = { slot = "Saddlebags" },

        -- reins
        ["HorseMod.HorseReins_Crude"] = { slot = "Reins" },
        ["HorseMod.HorseReins_Black"] = { slot = "Reins" },
        ["HorseMod.HorseReins_Brown"] = { slot = "Reins" },
        ["HorseMod.HorseReins_White"] = { slot = "Reins" },

        -- manes
        ["HorseMod.HorseManeStart"] = { slot = "ManeStart" },
        ["HorseMod.HorseManeMid"]   = { slot = "ManeMid1" },
        ["HorseMod.HorseManeEnd"]   = { slot = "ManeEnd" },
    },
    SLOTS = {
        "Saddle",
        "Saddlebags",
        "Head",
        "Reins",
        "MountLeft",
        "MountRight",
        "ManeStart",
        "ManeMid1",
        "ManeMid2",
        "ManeMid3",
        "ManeMid4",
        "ManeMid5",
        "ManeEnd",
    },
    MANE_SLOTS_SET = {
        ["ManeStart"] = true,
        ["ManeMid1"] = true,
        ["ManeMid2"] = true,
        ["ManeMid3"] = true,
        ["ManeMid4"] = true,
        ["ManeMid5"] = true,
        ["ManeEnd"] = true,
    },
}

---Checks if the given item full type is an attachment, and optionally if it has a slot `_slot`.
---@param fullType string
---@param _slot string?
---@return boolean
---@nodiscard
Attachments.isAttachment = function(fullType, _slot)
    local attachmentDef = Attachments.items[fullType]
    if _slot then
        return attachmentDef and attachmentDef.slot == _slot or false
    end
    return attachmentDef ~= nil
end

---Retrieves the attachments associated to the given item full type.
---@param fullType string
---@return AttachmentDefinition
---@nodiscard
Attachments.getAttachment = function(fullType)
    return Attachments.items[fullType]
end

---Retrieve the attached item on the specified `slot` of `animal`.
---@param animal IsoAnimal
---@param slot AttachmentSlot
---@return InventoryItem?
---@nodiscard
Attachments.getAttachedItem = function(animal, slot)
    local ai = animal:getAttachedItems()
    return ai and ai:getItem(slot)
    -- return animal:getAttachedItem(slot)
end

---@param animal IsoAnimal
---@return InventoryItem[]
---@nodiscard
Attachments.getAttachedItems = function(animal)
    -- return animal:getAttachedItems()

    local attached = {}
    local slots = Attachments.SLOTS
    local mane_slots_set = Attachments.MANE_SLOTS_SET
    for i = 1, #slots do
        local slot = slots[i]
        if not mane_slots_set[slot] then
            local attachment = Attachments.getAttachedItem(animal, slot)
            if attachment then
                table.insert(attached, attachment)
            end
        end
    end
    return attached
end

---Attach an `item` to a specific `slot` on the `animal`.
---@param animal IsoAnimal
---@param slot AttachmentSlot
---@param item InventoryItem
Attachments.setAttachedItem = function(animal, slot, item)
    animal:setAttachedItem(slot, item)
end

return Attachments
