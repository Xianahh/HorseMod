---@namespace HorseMod

---REQUIREMENTS
local HorseUtils = require("HorseMod/Utils")

---@class ContainerInformation
---@field container InventoryItem
---@field x number
---@field y number
---@field z number

---@alias AnimalContainers table<AttachmentSlot, ContainerInformation>

---Holds all the utility functions to manage containers on horses.
local ContainerManager = {
    ---@type table<IsoAnimal, AnimalContainers>
    CONTAINERS = {}
}


ContainerManager.findContainer = function(horse, slot, fullType)

end

ContainerManager.initContainer = function(horse, slot, fullType)
    -- should run it in the equip gear timed action
end

ContainerManager.findOrInitContainer = function(horse, slot, fullType)
    local item = ContainerManager.findContainer(horse, slot, fullType)
    if not item then
        -- either check later, bcs the square where it is might not be loaded yet
        -- we should make sure the container is initialized at the proper time so we 
        -- shouldn't have to ever reinitialize it to not replace the old one with a new one
    end
end

---@param horse IsoAnimal
---@param slot AttachmentSlot
---@param fullType string
ContainerManager.getContainer = function(horse, slot, fullType)
    local container = ContainerManager.CONTAINERS[horse]

    -- if container not find, find it or initialize it
    if not container then
        local item = ContainerManager.findOrInitContainer(horse, slot, fullType)
        return item
    end
end



ContainerManager.track = function(horses)
    for i = 1, #horses do
        local horse = horses[i]
        local bySlot = HorseUtils.getModData(horse).bySlot

        for slot, fullType in pairs(bySlot) do
            ContainerManager.getContainer(horse, slot, fullType)
        end
    end    
end


return ContainerManager
