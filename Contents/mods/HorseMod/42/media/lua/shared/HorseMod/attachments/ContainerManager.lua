---@namespace HorseMod

---REQUIREMENTS
local HorseUtils = require("HorseMod/Utils")
local AttachmentData = require("HorseMod/attachments/AttachmentData")

---@class ContainerInformation
---@field x number
---@field y number
---@field z number
---@field worldItem InventoryItem?

---@alias AnimalContainers table<AttachmentSlot, ContainerInformation?>

---Holds all the utility functions to manage containers on horses.
local ContainerManager = {
    ---@type table<IsoAnimal, AnimalContainers?>
    HORSE_CONTAINERS = {}
}
local HORSE_CONTAINERS = ContainerManager.HORSE_CONTAINERS

---Transfert every items from the `srcContainer` to the `destContainer`.
---@param player IsoPlayer
---@param srcContainer ItemContainer
---@param destContainer ItemContainer
ContainerManager.transferAll = function(player, srcContainer, destContainer)
    -- transfert every items from src to dest container
    local items = srcContainer:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        ISTransferAction:transferItem(player, item, srcContainer, destContainer, nil)    
    end
end

---@param horse IsoAnimal
---@param attachmentDef AttachmentDefinition
---@param worldItem InventoryItem?
ContainerManager.registerContainerInformation = function(horse, attachmentDef, worldItem)
    local modData = HorseUtils.getModData(horse)
    local containers = modData.containers
    local slot = attachmentDef.slot

    -- init cache for this horse if needed
    ---@type AnimalContainers
    HORSE_CONTAINERS[horse] = HORSE_CONTAINERS[horse] or {}

    -- remove info
    if not worldItem then
        -- clear cached and saved info        
        containers[slot] = nil
        HORSE_CONTAINERS[horse][slot] = nil
    else
        -- init container info table
        local containerInfo = {
            x = worldItem:getX(),
            y = worldItem:getY(),
            z = worldItem:getZ(),
            worldItem = worldItem,
        }

        -- store in mod data
        containers[slot] = containerInfo
        
        -- cache
        HORSE_CONTAINERS[horse][slot] = containerInfo
    end
end

---@param player IsoPlayer
---@param horse IsoAnimal
---@param attachmentDef AttachmentDefinition
---@param accessory InventoryItem
ContainerManager.initContainer = function(player, horse, attachmentDef, accessory)
    -- retrieve the container of the accessory
    local srcContainer = accessory:getContainer()
    assert(srcContainer ~= nil, "Accessory has container behavior but isn't a container.")
    srcContainer:Remove(accessory)

    -- retrieve the square the horse is on
    local square = horse:getSquare()
    assert(square ~= nil, "Horse isn't on a square.")

    -- create the invisible container
    local containerBehavior = attachmentDef.containerBehavior --[[@as ContainerBehavior]]
    local worldItem = square:AddWorldInventoryItem(containerBehavior.worldItem, 0,0,0)
    local destContainer = worldItem:getContainer()
    assert(destContainer ~= nil, "Invisible container ("..containerBehavior.worldItem..") used for "..accessory:getFullType().." isn't a container.")

    -- transfer everything to the invisible container
    ContainerManager.transferAll(player, srcContainer, destContainer)
    triggerEvent("OnContainerUpdate")

    -- register in the data of the horse the container being attached
    ContainerManager.registerContainerInformation(horse, attachmentDef, worldItem)
end

ContainerManager.removeContainer = function(player, horse, attachmentDef, accessory)
    local worldItem = ContainerManager.getContainer(horse, attachmentDef, accessory:getFullType())
    assert(worldItem ~= nil, "Container shouldn't be nil when removing it.")
    
    local container = accessory:getContainer()
    assert(container ~= nil, "Accessory has container behavior but isn't a container.")
    
    ContainerManager.transferAll(player, worldItem:getContainer(), container)
    worldItem:removeFromWorld()
end

---@param horse IsoAnimal
---@param attachmentDef AttachmentDefinition
---@param fullType string
ContainerManager.findContainer = function(horse, attachmentDef, fullType)


    ContainerManager.registerContainerInformation(horse, attachmentDef, worldItem)
end

---@param horse IsoAnimal
---@param attachmentDef AttachmentDefinition
---@param fullType string
---@return InventoryItem?
ContainerManager.getContainer = function(horse, attachmentDef, fullType)
    local slot = attachmentDef.slot

    --  verify horse should have a container there
    local modData = HorseUtils.getModData(horse)
    local containers = modData.containers
    local containerInfo = containers[slot]
    if not containerInfo then return end

    -- init cache for this horse if needed
    ---@type AnimalContainers
    HORSE_CONTAINERS[horse] = HORSE_CONTAINERS[horse] or {}
    local horseContainers = HORSE_CONTAINERS[horse]

    -- find from cache
    local containerInfo = horseContainers[slot]

    -- if container not cached, find it
    if not containerInfo then
        local item = ContainerManager.findContainer(horse, attachmentDef, fullType)
        return item
    end

    return containerInfo.worldItem
end


---@param horses IsoAnimal[]
ContainerManager.track = function(horses)
    for i = 1, #horses do
        local horse = horses[i]
        local bySlot = HorseUtils.getModData(horse).bySlot

        for slot, fullType in pairs(bySlot) do
            local attachmentDef = AttachmentData.items[fullType]
            local container = ContainerManager.getContainer(horse, attachmentDef, fullType)
        end
    end    
end


return ContainerManager
