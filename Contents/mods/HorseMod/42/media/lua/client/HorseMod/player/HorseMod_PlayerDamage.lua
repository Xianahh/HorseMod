local HorseRiding = require("HorseMod/shared/HorseMod_Riding")
local HorseUtils = require("HorseMod/HorseMod_Utils")

-- maximum pain allowed on each affected body part
local MAX_PAIN_BAREBACK = 20
local MAX_PAIN_SADDLE = 10
-- pain per update while riding without a saddle
local PAIN_RATE_BAREBACK = 0.003
-- pain per update while riding with a saddle
local PAIN_RATE_SADDLE = 0.001

local allowedDamageParts = {
    BodyPartType.Foot_L,
    BodyPartType.Foot_R,
    BodyPartType.LowerLeg_L,
    BodyPartType.LowerLeg_R,
    BodyPartType.UpperLeg_L,
    BodyPartType.UpperLeg_R,
    BodyPartType.Groin,
}

local function applyRidingPain(player)
    local horse = HorseRiding.getMountedHorse and HorseRiding.getMountedHorse(player)
    if not horse then return end
    if not player:getVariableBoolean("pressedmovement") then return end
    local rate = HorseUtils.horseHasSaddleItem(horse) and PAIN_RATE_SADDLE or PAIN_RATE_BAREBACK
    local maxPain = HorseUtils.horseHasSaddleItem(horse) and MAX_PAIN_SADDLE or MAX_PAIN_BAREBACK
    local bd = player:getBodyDamage()
    local bodyPartsList = {BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R, BodyPartType.Groin}
    for i = 1, #bodyPartsList do
        local partType = bodyPartsList[i]
        local part = bd:getBodyPart(partType)
        if part then
            local newPain = math.min(part:getAdditionalPain() + rate, maxPain)
            part:setAdditionalPain(newPain)
        end
    end
end
Events.OnPlayerUpdate.Add(applyRidingPain)

local function addRandomDamageFromZombieOnParts(zombie, hitReaction, parts)
    local player = getSpecificPlayer(0)
    if not player or not zombie then return false end

    hitReaction = (hitReaction and hitReaction ~= "") and hitReaction or "Bite"

    player:setVariable("hitpvp", false)

    -- Server: hand off to object-change and bail
    if isServer() then
        if zombie.OnlineID then
            player:sendObjectChange("AddRandomDamageFromZombie", { zombie = zombie.OnlineID })
        end
        return true
    end

    ---- base chances
    local byte0 = 0
    local int0 = 0
    local int1 = 15 + (player.getMeleeCombatMod and player:getMeleeCombatMod() or 0)
    local int2 = 85
    local int3 = 65

    -- Facing side / position of zombie relative to player
    local side = tostring(player:testDotSide(zombie) or ""):lower()
    local isBehind = (side == "behind" or side == "back")
    local isSide   = (side == "left" or side == "right")

    -- Surrounding attackers scale
    local attackers = (player.getSurroundingAttackingZombies and player:getSurroundingAttackingZombies() or 1)
    attackers = math.max(attackers, 1)
    int1 = int1 - (attackers - 1) * 10
    int2 = int2 - (attackers - 1) * 30
    int3 = int3 - (attackers - 1) * 15

    -- Drag-down check (greatly simplified / guarded)
    local dragThreshold = 3
    local canDrag = true
    local crawlCount = 1 -- (placeholder for crawler drag option)
    if player.getHitReaction and player:getHitReaction() ~= "EndDeath" then
        if (not (player.isGodMod and player:isGodMod())) and canDrag and crawlCount >= dragThreshold and not (player.isSitOnGround and player:isSitOnGround()) then
            int1, int2, int3 = 0, 0, 0
            if player.setHitReaction then player:setHitReaction("EndDeath") end
            if player.setDeathDragDown then player:setDeathDragDown(true) end
        else
            if player.setHitReaction then player:setHitReaction(hitReaction) end
        end
    end

    -- Rear/side modifiers
    if isBehind then
        int1 = int1 - 15
        int2 = int2 - 25
        int3 = int3 - 35
        if attackers > 2 then
            int2 = int2 - 15
            int3 = int3 - 15
        end
    elseif isSide then
        int1 = int1 - 30
        int2 = int2 - 7
        int3 = int3 - 27
    end

    local isCrawling = (zombie.isCrawling and zombie:isCrawling()) or zombie.bCrawling
    if isCrawling and ZombRand(2) ~= 0 then
        return false
    end

    if type(parts) ~= "table" or #parts == 0 then
        return false
    end

    int0 = parts[ZombRand(#parts) + 1] -- pick a bodypart index

    -- Bias to neck if behind & many attackers
    if not isCrawling then
        local bonus = 10.0 * attackers
        if isBehind then bonus = bonus + 5.0 end
        if isSide   then bonus = bonus + 2.0 end
        if isBehind and ZombRand(100) < bonus then
            local neckIndex = BodyPartType.ToIndex(BodyPartType.Neck)
            for i = 1, #parts do
                if parts[i] == neckIndex then
                    int0 = neckIndex
                    break
                end
            end
        end
    end

    -- Avoid head/neck too often unless RNG says so
    local headIdx = BodyPartType.ToIndex(BodyPartType.Head)
    local neckIdx = BodyPartType.ToIndex(BodyPartType.Neck)
    if int0 == headIdx or int0 == neckIdx then
        local chance = 70
        if isBehind then chance = 90 end
        if isSide   then chance = 80 end
        if ZombRand(100) > chance then
            local filtered = {}
            for i = 1, #parts do
                local bp = parts[i]
                if bp ~= headIdx and bp ~= neckIdx and bp ~= BodyPartType.ToIndex(BodyPartType.Groin) then
                    filtered[#filtered+1] = bp
                end
            end
            if #filtered > 0 then
                int0 = filtered[ZombRand(#filtered) + 1]
            end
        end
    end

    if zombie.inactive then
        int1 = int1 + 20
        int2 = int2 + 20
        int3 = int3 + 20
    end

    -- Final raw damage (randomized)
    local float1 = (ZombRand(1000) / 1000.0) * (ZombRand(10) + 10)

    -- Convenience: body damage + body part object
    local bd = player.getBodyDamage and player:getBodyDamage()
    if not bd then return false end
    print("Body part index: ", int0)
    local bpType  = parts[ZombRand(#parts) + 1]          -- BodyPartType.*
    local bpIndex = BodyPartType.ToIndex(bpType)         -- integer index
    local bp  = bd and bd:getBodyPart(bpType)

    -- Scratch / laceration / bite decision
    local doScratch = ZombRand(100) > int3
    local doBite    = (ZombRand(100) > int2) and (not (zombie.cantBite and zombie:cantBite()))
    local doLacer   = (not doScratch) and (not doBite)

    -- Clothing defense (scratch: false biteFlag, bite: true)
    local scratchDef = player.getBodyPartClothingDefense and player:getBodyPartClothingDefense(bpIndex, false, false) or 0
    local biteDef    = player.getBodyPartClothingDefense and player:getBodyPartClothingDefense(bpIndex, true,  false) or 0

    -- Apply effects
    if ZombRand(100) > int1 then
        -- SCRATCH
        if doScratch then
            -- clothing save?
            if ZombRand(100) < scratchDef then
                player:addHoleFromZombieAttacks(BloodBodyPartType.FromIndex(bpIndex), true)
                return false
            end
            if bp and bp.AddDamage then bp:AddDamage(float1) end
            if bp and bp.setScratched then bp:setScratched(true) end
            player:addBlood(BloodBodyPartType.FromIndex(bpIndex), true, false, true)
            byte0 = 1
            if player.getEmitter and player:getEmitter() then
                player:getEmitter():playSoundImpl("ZombieScratch", nil)
            end

        -- LACERATION
        elseif doLacer then
            if bp and bp.AddDamage then bp:AddDamage(float1) end
            if bp and bp.setCut then bp:setCut(true) end
            player:addBlood(BloodBodyPartType.FromIndex(bpIndex), true, false, true)
            byte0 = 1
            if player.getEmitter and player:getEmitter() then
                player:getEmitter():playSoundImpl("ZombieScratch", nil)
            end

        -- BITE
        else
            -- clothing save?
            if ZombRand(100) < biteDef then
                player:addHoleFromZombieAttacks(BloodBodyPartType.FromIndex(bpIndex), true)
                return false
            end
            if player.getEmitter and player:getEmitter() then
                local biteSound = zombie.getBiteSoundName and zombie:getBiteSoundName() or "ZombieBite"
                if bpIndex == neckIdx then biteSound = "NeckBite" end
                player:getEmitter():playSoundImpl(biteSound, nil)
            end
            if bp and bp.AddDamage then bp:AddDamage(float1) end
            if bp and bp.setBitten then bp:setBitten(true) end
            player:addBlood(BloodBodyPartType.FromIndex(bpIndex), false, true, true)
            if bpIndex == neckIdx then
                player:addBlood(BloodBodyPartType.FromIndex(bpIndex), false, true, true)
                player:addBlood(BloodBodyPartType.Torso_Upper, false, true, false)
                if player.splatBloodFloorBig then
                    player:splatBloodFloorBig(); player:splatBloodFloorBig(); player:splatBloodFloorBig()
                end
            end
            byte0 = 2
        end
    end

    -- Pain application
    local stats = player.getStats and player:getStats()
    if stats then
        local pain = stats.Pain or 0
        if     byte0 == 0 and player.getInitialThumpPain   then pain = pain + player:getInitialThumpPain()   * BodyPartType.getPainModifyer(bpIndex)
        elseif byte0 == 1 and player.getInitialScratchPain then pain = pain + player:getInitialScratchPain() * BodyPartType.getPainModifyer(bpIndex)
        elseif byte0 == 2 and player.getInitialBitePain    then pain = pain + player:getInitialBitePain()    * BodyPartType.getPainModifyer(bpIndex)
        end
        if pain > 100.0 then pain = 100.0 end
        stats.Pain = pain
    end

    -- Sync for client
    if instanceof(player, "IsoPlayer") and isClient() and player:isLocalPlayer() then
        if player.updateMovementRates then player:updateMovementRates() end
        if GameClient and GameClient.sendPlayerInjuries then GameClient.sendPlayerInjuries(player) end
        if GameClient and GameClient.sendPlayerDamage   then GameClient.sendPlayerDamage(player)   end
    end

    return true
end

local function onZombieAttack(zombie)
    local target = zombie:getTarget()
    -- local currentAttackOutcome = zombie:getVariableString("AttackOutcome")
    if target then
        print("Zombie attacking 1: ", zombie:isZombieAttacking())
        print("Zombie attacking 2: ", zombie:isAttacking())
        local currentAttackOutcome = zombie:getVariableString("AttackOutcome")
        if currentAttackOutcome ~= "" then
            local hitReaction = target:getHitReaction()
            addRandomDamageFromZombieOnParts(zombie, hitReaction, allowedDamageParts)
        end
    end
end
Events.OnZombieUpdate.Add(onZombieAttack)

return {}