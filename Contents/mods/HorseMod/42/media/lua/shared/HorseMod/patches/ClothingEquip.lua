---REQUIREMENTS
local HorseRiding = require("HorseMod/Riding")
local HorseUtils = require("HorseMod/Utils")

--[[
This patch prevents players from equipping or unequipping certain clothing items while mounted on a horse.

API functions are provided in :lua:obj:`HorseMod/HorseAPI` to allow or restrict specific body locations while mounted.
]]

local ClothingEquip = {
    ---Table of allowed body locations to equip while mounted on a horse.
    ---@type table<string, boolean>
    allowedBodyLocations = {
        -- ["AmmoStrap"] = true,
        -- ["AnkleHolster"] = true,
        -- ["Back"] = true,
        -- ["Bandage"] = true,
        -- ["BathRobe"] = true,
        -- ["BellyButton"] = true,
        -- ["Belt"] = true,
        -- ["BeltExtra"] = true,
        -- ["BodyCostume"] = false,
        -- ["Boilersuit"] = false,
        -- ["Calf_Left"] = false,
        -- ["Calf_Left_Texture"] = false,
        -- ["Calf_Right"] = false,
        -- ["Calf_Right_Texture"] = false,
        -- ["Codpiece"] = false,
        -- ["Cuirass"] = true,
        -- ["Dress"] = false,
        -- ["EarTop"] = true,
        -- ["Ears"] = true,
        -- ["Elbow_Left"] = true,
        -- ["Elbow_Right"] = true,
        -- ["Eyes"] = true,
        -- ["FannyPackBack"] = true,
        -- ["FannyPackFront"] = true,
        -- ["ForeArm_Left"] = true,
        -- ["ForeArm_Right"] = true,
        -- ["FullHat"] = true,
        -- ["FullRobe"] = false,
        -- ["FullSuit"] = false,
        -- ["FullSuitHead"] = false,
        -- ["FullSuitHeadSCBA"] = false,
        -- ["FullTop"] = true,
        -- ["Gaiter_Left"] = false,
        -- ["Gaiter_Right"] = false,
        -- ["Gorget"] = true,
        -- ["Hands"] = true,
        -- ["HandsLeft"] = true,
        -- ["HandsRight"] = true,
        -- ["Hat"] = true,
        -- ["Jacket"] = true,
        -- ["JacketHat"] = true,
        -- ["JacketHat_Bulky"] = true,
        -- ["JacketSuit"] = true,
        -- ["Jacket_Bulky"] = true,
        -- ["Jacket_Down"] = true,
        -- ["Jersey"] = true,
        -- ["Knee_Left"] = true,
        -- ["Knee_Right"] = true,
        -- ["LeftArm"] = true,
        -- ["LeftEye"] = true,
        -- ["LeftWrist"] = true,
        -- ["Left_MiddleFinger"] = true,
        -- ["Left_RingFinger"] = true,
        -- ["Legs1"] = false,
        -- ["Legs5"] = false,
        -- ["LongDress"] = false,
        -- ["LongSkirt"] = false,
        -- ["MakeUp_Eyes"] = true,
        -- ["MakeUp_EyesShadow"] = true,
        -- ["MakeUp_FullFace"] = true,
        -- ["MakeUp_Lips"] = true,
        -- ["Mask"] = true,
        -- ["MaskEyes"] = true,
        -- ["MaskFull"] = true,
        -- ["Neck"] = true,
        -- ["Neck_Texture"] = true,
        -- ["Necklace"] = true,
        -- ["Necklace_Long"] = true,
        -- ["Nose"] = true,
        -- ["Pants"] = false,
        -- ["PantsExtra"] = false,
        -- ["Pants_Skinny"] = false,
        -- ["RightArm"] = true,
        -- ["RightEye"] = true,
        -- ["RightWrist"] = true,
        -- ["Right_MiddleFinger"] = true,
        -- ["Right_RingFinger"] = true,
        -- ["SCBA"] = true,
        -- ["SCBAnotank"] = true,
        -- ["Scarf"] = true,
        -- ["Shirt"] = true,
        -- ["Shoes"] = false,
        -- ["ShortPants"] = false,
        -- ["ShortSleeveShirt"] = true,
        -- ["ShortsShort"] = false,
        -- ["ShoulderHolster"] = true,
        -- ["ShoulderpadLeft"] = true,
        -- ["ShoulderpadRight"] = true,
        -- ["Skirt"] = false,
        -- ["Socks"] = false,
        -- ["SportShoulderpad"] = true,
        -- ["SportShoulderpadOnTop"] = true,
        -- ["Sweater"] = true,
        -- ["SweaterHat"] = true,
        -- ["Tail"] = true,
        -- ["TankTop"] = true,
        -- ["Thigh_Left"] = false,
        -- ["Thigh_Right"] = false,
        -- ["Torso1"] = true,
        -- ["Torso1Legs1"] = false,
        -- ["TorsoExtra"] = true,
        -- ["TorsoExtraVest"] = true,
        -- ["TorsoExtraVestBullet"] = true,
        -- ["Tshirt"] = true,
        -- ["Underwear"] = false,
        -- ["UnderwearBottom"] = false,
        -- ["UnderwearExtra1"] = false,
        -- ["UnderwearExtra2"] = false,
        -- ["UnderwearTop"] = true,
        -- ["VestTexture"] = true,
        -- ["Webbing"] = true,
        -- ["Wound"] = true,
        -- ["ZedDmg"] = true,
    },

    ---Table of allowed blood locations to equip while mounted on a horse.
    ---@type table<string, boolean>
    allowedBloodLocations = {
        ["Apron"] = true,
        ["Bag"] = true,
        ["Foot_L"] = true,
        ["Foot_R"] = true,
        ["ForeArm_L"] = true,
        ["ForeArm_R"] = true,
        ["FullHelmet"] = true,
        ["Groin"] = true,
        ["Hand_L"] = true,
        ["Hand_R"] = true,
        ["Hands"] = true,
        ["Head"] = true,
        ["Jacket"] = true,
        ["Jumper"] = true,
        ["JumperNoSleeves"] = true,
        ["LongJacket"] = true,
        ["LowerArms"] = true,
        ["LowerBody"] = true,
        ["LowerLeg_L"] = true,
        ["LowerLeg_R"] = true,
        ["LowerLegs"] = true,
        ["Neck"] = true,
        ["Shirt"] = true,
        ["ShirtLongSleeves"] = true,
        ["ShirtNoSleeves"] = true,
        ["Shoes"] = true,
        ["ShortsShort"] = true,
        ["Trousers"] = true,
        ["UpperArm_L"] = true,
        ["UpperArm_R"] = true,
        ["UpperArms"] = true,
        ["UpperBody"] = true,
        ["UpperLeg_L"] = true,
        ["UpperLeg_R"] = true,
        ["UpperLegs"] = true,
    },
}

---@param item InventoryItem
---@return boolean
---@nodiscard
ClothingEquip.canEquipItem = function(item)
    local bodyLocation = item:getBodyLocation()
    if bodyLocation then
        local canEquip = ClothingEquip.allowedBodyLocations[tostring(bodyLocation)]
        if canEquip ~= nil then
            return canEquip
        end
    end

    local bloodLocations = HorseUtils(item, "bloodClothingType")
    if bloodLocations then
        print(bloodLocations)
    end

    return false
end


ClothingEquip._originalWearClothingValid = ISWearClothing.isValid
function ISWearClothing:isValid()
    if self.item then
        if HorseRiding.isMountingHorse(self.character) then
            local location = self.item:getBodyLocation()
            if location and not ClothingEquip.allowedBodyLocations[location] then
                return false
            end
        end
    end
    return ClothingEquip._originalWearClothingValid(self)
end

ClothingEquip._originalUnequipValid = ISUnequipAction.isValid
function ISUnequipAction:isValid()
    if self.item then
        if HorseRiding.isMountingHorse(self.character) then
            local location = self.item:getBodyLocation()
            if location and not ClothingEquip.allowedBodyLocations[location] then
                return false
            end
        end
    end
    return ClothingEquip._originalUnequipValid(self)
end

return ClothingEquip
