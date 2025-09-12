local HorseUtils  = require("HorseMod/HorseMod_Utils")
local HorseRiding = require("HorseMod/shared/HorseMod_Riding")
-- local HorseAttachments = require("HorseMod/HorseMod_HorseAttachments")

local function doHorseInteractionMenu(context, player, animal)
    if not animal or not HorseUtils.isHorse(animal) then return end
    if HorseRiding.canMountHorse(player, animal) then
        -- FIXME: currently we set this variable here because animations are still in testing
        -- we should detect when a horse spawns and apply this immediately
        animal:setVariable("isHorse", true)
        context:addOption(getText("IGUI_HorseMod_MountHorse"),
                          player, HorseRiding.mountHorse, animal)
    end
end

local function onClickedAnimalForContext(playerNum, context, animals, test)
    if test then return end
    if not animals or #animals == 0 then return end
    doHorseInteractionMenu(context, getSpecificPlayer(playerNum), animals[1])
end

Events.OnClickedAnimalForContext.Add(onClickedAnimalForContext)