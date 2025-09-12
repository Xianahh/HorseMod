require "ISUI/Animal/ISAnimalContextMenu"

local HorseUtils = require("HorseMod/HorseMod_Utils")
HorseMod = HorseMod or {}
HorseMod.HorseAttachments  = HorseMod.HorseAttachments

-----------------------------------------------------------------------
-- Attachment locations setup
-----------------------------------------------------------------------
local group = AttachedLocations.getGroup("Animal")
local back       = group:getOrCreateLocation("Back")
local head       = group:getOrCreateLocation("Head")
local mountLeft  = group:getOrCreateLocation("MountLeft")
local mountRight = group:getOrCreateLocation("MountRight")
back:setAttachmentName("back")
head:setAttachmentName("head")
mountLeft:setAttachmentName("mountLeft")
mountRight:setAttachmentName("mountRight")

-- Known slots list
local SLOTS = { "Back", "Head", "MountLeft", "MountRight" }

HorseMod.HorseAttachments = HorseMod.HorseAttachments or {
    --EXAMPLE: ["FullType"] = { slot = "AttachmentSlot" }
    ["HorseMod.HorseSaddle"] = { slot = "Back" },
    ["HorseMod.HorseBackpack"] = { slot = "Back" },
}

-----------------------------------------------------------------------
-- Utils
-----------------------------------------------------------------------
local function getTextOr(s) return (getTextOrNull and (getTextOrNull(s) or s)) or s end

local function getAttachedItem(animal, slot)
    if animal.getAttachedItems then
        local ai = animal:getAttachedItems()
        if ai and ai.getItem then return ai:getItem(slot) end
    end
    if animal.getAttachedItem then
        return animal:getAttachedItem(slot)
    end
    return nil
end

local function setAttachedItem(animal, slot, item)
    animal:setAttachedItem(slot, item)
end

local function giveBackToPlayerOrDrop(player, animal, item)
    if not item then return end
    local pinv = player and player:getInventory()
    if pinv and pinv:addItem(item) then return end
    local sq = animal:getSquare() or (player and player:getSquare())
    if sq then sq:AddWorldInventoryItem(item, 0.0, 0.0, 0.0) end
end

local function collectCandidateItems(player, itemsMap)
    local out = {}

    local function addIfListed(item)
        if not item then return end
        local ft = item:getFullType()
        if itemsMap[ft] then table.insert(out, item) end
    end

    local pinv = player and player:getInventory()
    if pinv and pinv.getAllEvalRecurse then
        local list = ArrayList.new()
        pinv:getAllEvalRecurse(function(it) return itemsMap[it:getFullType()] ~= nil end, list)
        for i=0, list:size()-1 do addIfListed(list:get(i)) end
    else
        if pinv and pinv.getItems then
            local its = pinv:getItems()
            for i=0, its:size()-1 do addIfListed(its:get(i)) end
        end
    end

    -- Nearby floor containers
    if ISInventoryPaneContextMenu and ISInventoryPaneContextMenu.getContainers then
        local containers = ISInventoryPaneContextMenu.getContainers(player)
        for i=0, containers:size()-1 do
            local cont = containers[i]
            if cont and cont:getType() == "floor" then
                local its = cont:getItems()
                if its then
                    for j=0, its:size()-1 do addIfListed(its:get(j)) end
                end
            end
        end
    end

    return out
end

local function ensureHorseModData(animal)
    local md = animal:getModData()
    md.HM_Attach = md.HM_Attach or { bySlot = {}, ground = {} }
    md.HM_Attach.bySlot  = md.HM_Attach.bySlot  or {}
    md.HM_Attach.ground  = md.HM_Attach.ground  or {}
    return md.HM_Attach.bySlot, md.HM_Attach.ground
end

local function isContainerItem(item)
    if not item then return false end
    if item.IsInventoryContainer and item:IsInventoryContainer() then return true end
    if instanceof and instanceof(item, "InventoryContainer") then return true end
    return false
end

local function getWorldInventoryObjectsAt(x, y, z)
    local sq = getCell():getGridSquare(math.floor(x), math.floor(y), z)
    return sq, sq and sq:getWorldObjects() or nil
end

local function findWorldItemOnSquare(x, y, z, fullType, wantId)
    local sq, list = getWorldInventoryObjectsAt(x, y, z)
    if not list then return nil, nil end
    for i=0, list:size()-1 do
        local wo = list:get(i)
        if wo and wo.getItem then
            local it = wo:getItem()
            if it and it:getFullType() == fullType then
                if not wantId or (it.getID and it:getID() == wantId) then
                    return wo, sq
                end
            end
        end
    end
    return nil, sq
end

local function takeWorldItemToInventory(worldObj, sq, inv)
    if not (worldObj and worldObj.getItem and inv) then return nil end
    local item = worldObj:getItem()
    if not item then return nil end
    inv:AddItem(item)
    if worldObj.removeFromSquare then
        worldObj:removeFromSquare()
    elseif sq and sq.transmitRemoveItemFromSquare then
        sq:transmitRemoveItemFromSquare(worldObj)
    elseif sq and sq.RemoveWorldObject then
        sq:RemoveWorldObject(worldObj)
    end
    return item
end


-----------------------------------------------------------------------
-- Equip / Unequip
-----------------------------------------------------------------------
local function equipAttachment(player, animal, item, itemsMap)
    local ft   = item:getFullType()
    local def  = itemsMap[ft]
    if not def then return end
    local slot = (type(def) == "table") and def.slot or def

    -- Move to horse inventory and replace if needed
    local inv = animal:getInventory()
    if item:getContainer() ~= inv then
        local oldC = item:getContainer()
        if oldC then oldC:Remove(item) end
        inv:AddItem(item)
    end

    local old = getAttachedItem(animal, slot)
    if old and old ~= item then
        setAttachedItem(animal, slot, nil)
        giveBackToPlayerOrDrop(player, animal, old)
    end

    setAttachedItem(animal, slot, item)

    local bySlot, ground = ensureHorseModData(animal)
    bySlot[slot] = ft
    ground[slot] = nil
end

local function unequipAttachment(player, animal, slot)
    local cur = getAttachedItem(animal, slot)
    if not cur then return end

    setAttachedItem(animal, slot, nil)

    local bySlot, ground = ensureHorseModData(animal)
    bySlot[slot] = nil
    ground[slot] = nil

    giveBackToPlayerOrDrop(player, animal, cur)
end


local function unequipAll(player, animal)
    for i = 1, #SLOTS do
        local slot = SLOTS[i]
        unequipAttachment(player, animal, slot)
    end
end

local function queueHorseGearAction(player, horse, workFn, maxTime, context)
    local unlock, lockDir = HorseUtils.lockHorseForInteraction(horse)
    context:closeAll()

    local lx, ly, lz = HorseUtils.getMountWorld(horse, "mountLeft")
    local rx, ry, rz = HorseUtils.getMountWorld(horse, "mountRight")
    local px, py     = player:getX(), player:getY()

    local dl = (px - lx) * (px - lx) + (py - ly) * (py - ly)
    local dr = (px - rx) * (px - rx) + (py - ry) * (py - ry)

    local tx, ty, tz = lx, ly, lz
    if dr < dl then tx, ty, tz = rx, ry, rz end

    local path
    if ISPathFindAction and ISPathFindAction.pathToLocationF then
        path = ISPathFindAction:pathToLocationF(player, tx, ty, tz)
    end

    local function cleanupOnFail()
        unlock()
    end

    if path then
        path:setOnFail(cleanupOnFail)
        path.stop = function(self)
            cleanupOnFail()
            ISPathFindAction.stop(self)
        end
        path:setOnComplete(function()
            player:setDir(lockDir)
            ISTimedActionQueue.add(ISHorseGearAction:new(player, horse, workFn, maxTime, unlock))
        end)
        ISTimedActionQueue.add(path)
    else
        ISTimedActionQueue.add(ISHorseGearAction:new(player, horse, workFn, maxTime, unlock))
    end
end

-----------------------------------------------------------------------
-- Context menu added to animal context menu
-----------------------------------------------------------------------
local function addAttachmentOptions(playerNum, context, animals, test)
    if test or not animals or #animals == 0 then return end

    local animal = animals[1]
    if not HorseUtils.isHorse(animal) then return end

    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local horseOption = context:getOptionFromName(animal:getFullName())
    if not horseOption or not horseOption.subOption then return end

    local horseSubMenu = context:getSubMenu(horseOption.subOption)
    if not horseSubMenu then return end

    local itemsMap = HorseMod.HorseAttachments or {}

    local function slotFor(fullType)
        local def = itemsMap[fullType]
        if def == nil then return nil end
        local t = type(def)
        if t == "string" then
            return def
        elseif t == "table" then
            return def.slot
        end
        return nil
    end

    local function T(s) return (getTextOr and getTextOr(s)) or s end

    -------------------------------------------------------------------
    -- Gear submenu
    -------------------------------------------------------------------
    local gearRoot = horseSubMenu:addOption(T("Gear"))
    local gearSub  = ISContextMenu:getNew(context)
    context:addSubMenu(gearRoot, gearSub)

    -------------------------------------------------------------------
    -- Equip submenu
    -------------------------------------------------------------------
    local candidates = collectCandidateItems(player, itemsMap)
    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            local da = a:getDisplayName() or a:getFullType() or ""
            local db = b:getDisplayName() or b:getFullType() or ""
            if da == db then return a:getFullType() < b:getFullType() end
            return da:lower() < db:lower()
        end)

        local equipRoot = gearSub:addOption(T("Equip"))
        local equipSub  = ISContextMenu:getNew(context)
        context:addSubMenu(equipRoot, equipSub)

        for i = 1, #candidates do
            local it = candidates[i]
            local fullType = it:getFullType()
            local slot     = slotFor(fullType)
            if slot and slot ~= "" then
                local current     = getAttachedItem(animal, slot)
                local currentName = current and (current:getDisplayName() or slot)
                local name        = it:getDisplayName() or fullType
                local label       = current
                    and string.format(T("Replace %s with %s"), currentName, name)
                    or  string.format(T("Equip %s"), name)

                local opt = equipSub:addOption(label, player, function(p, a, obj)
                    queueHorseGearAction(p, a, function()
                        equipAttachment(p, a, obj, itemsMap)
                    end, 120, context)
                end, animal, it)

                opt.toolTip = ISWorldObjectContextMenu.addToolTip()
                opt.toolTip.description = string.format("%s: %s", T("Slot"), tostring(slot))
            end
        end
    else
        local noOpt = gearSub:addOption(T("No compatible gear found"))
        noOpt.notAvailable = true
        if noOpt.setEnabled then noOpt:setEnabled(false) end
    end

    -------------------------------------------------------------------
    -- Unequip submenu
    -------------------------------------------------------------------
    local anyEquipped = false
    for i = 1, #SLOTS do
        local slot = SLOTS[i]
        if getAttachedItem(animal, slot) then anyEquipped = true; break end
    end

    if anyEquipped then
        local uneqRoot = gearSub:addOption(T("Unequip"))
        local uneqSub  = ISContextMenu:getNew(context)
        context:addSubMenu(uneqRoot, uneqSub)

        for i = 1, #SLOTS do
            local slot = SLOTS[i]
            local cur = getAttachedItem(animal, slot)
            if cur then
                local name = cur:getDisplayName() or slot
                uneqSub:addOption(T("Unequip") .. " " .. name,
                    player,
                    function(p, a, s)
                        queueHorseGearAction(p, a, function()
                            unequipAttachment(p, a, s)
                        end, 90, context)
                    end,
                    animal, slot
                )
            end
        end

        uneqSub:addOption(T("Unequip All"),
            player,
            function(p, a)
                queueHorseGearAction(p, a, function()
                    unequipAll(p, a)
                end, 150, context)
            end,
            animal
        )
    end
end

Events.OnClickedAnimalForContext.Add(addAttachmentOptions)

-----------------------------------------------------------------------
-- Re-apply attachments for on screen horses
-----------------------------------------------------------------------
local REAPPLY_RADIUS = 20
local reapplyTick = 0

local function reapplyFor(animal)
    if not HorseUtils.isHorse(animal) then return end
    local bySlot, ground = ensureHorseModData(animal)
    if not bySlot then return end

    local inv = animal:getInventory()

    for slot, fullType in pairs(bySlot) do
        if fullType and fullType ~= "" then
            local cur = getAttachedItem(animal, slot)
            if cur and cur:getFullType() == fullType then
                setAttachedItem(animal, slot, cur)
            else
                local found = inv and inv:FindAndReturn(fullType)
                if found then
                    setAttachedItem(animal, slot, found)
                    ground[slot] = nil
                else
                    local g = ground[slot]
                    if g and g.x and g.y and g.z then
                        local wo, sq = findWorldItemOnSquare(g.x, g.y, g.z, fullType, g.id)
                        if wo then
                            local picked = takeWorldItemToInventory(wo, sq, inv)
                            if picked then
                                setAttachedItem(animal, slot, picked)
                                ground[slot] = nil
                            end
                        end
                    end

                    if not getAttachedItem(animal, slot) then
                        local spawnIt = InventoryItemFactory and InventoryItemFactory.CreateItem and InventoryItemFactory.CreateItem(fullType)
                        if fullType and not isContainerItem(fullType) then
                            inv:AddItem(fullType)
                            setAttachedItem(animal, slot, spawnIt)
                        end
                    end
                end
            end
        end
    end
end

Events.OnTick.Add(function()
    reapplyTick = reapplyTick + 1
    if reapplyTick % 120 ~= 0 then return end

    local player = getPlayer()
    if not player then return end

    local cell = getCell()
    local z    = player:getZ()
    local px   = math.floor(player:getX())
    local py   = math.floor(player:getY())

    for x = px - REAPPLY_RADIUS, px + REAPPLY_RADIUS do
        for y = py - REAPPLY_RADIUS, py + REAPPLY_RADIUS do
            local sq = cell:getGridSquare(x, y, z)
            if sq then
                local animals = sq:getAnimals()
                if animals then
                    for i = 0, animals:size() - 1 do
                        local a = animals:get(i)
                        if a:isOnScreen() then
                            reapplyFor(a)
                        end
                    end
                end
            end
        end
    end
end)

local DROP_RADIUS = 50

local function dropContainerAttachmentsOnSave()
    for p=0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(p)
        if player then
            local z  = player:getZ()
            local px = math.floor(player:getX())
            local py = math.floor(player:getY())
            local cell = getCell()

            for x = px - DROP_RADIUS, px + DROP_RADIUS do
                for y = py - DROP_RADIUS, py + DROP_RADIUS do
                    local sq = cell:getGridSquare(x, y, z)
                    if sq then
                        local animals = sq:getAnimals()
                        if animals then
                            for i=0, animals:size()-1 do
                                local a = animals:get(i)
                                if HorseUtils.isHorse(a) then
                                    local bySlot, ground = ensureHorseModData(a)
                                    for j = 1, #SLOTS do
                                        local slot = SLOTS[j]
                                        local cur = getAttachedItem(a, slot)
                                        if cur and isContainerItem(cur) then
                                            setAttachedItem(a, slot, nil)

                                            local inv = a:getInventory()
                                            if inv and inv:contains(cur) then inv:Remove(cur) end

                                            sq:AddWorldInventoryItem(cur, 0.0, 0.0, 0.0)

                                            local id = cur.getID and cur:getID() or nil
                                            ground[slot] = { x = x + 0.0, y = y + 0.0, z = z, id = id }
                                            bySlot[slot] = cur:getFullType()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnSave.Add(dropContainerAttachmentsOnSave)

