local config = {
    horseSoundVolume = nil,
    horseWalkSpeed = nil,
    horseTrotSpeed = nil,
    horseGallopSpeed = nil
}

local function HorseConfig()
    local options = PZAPI.ModOptions:create("HorseMod", "Horse")

    options:addDescription("Change the volume of Horse sounds.")
    config.horseSoundVolume = options:addSlider("HorseSoundVolume", "Horse Sound Volume (Default 0.40)", 0.01, 1, 0.01, 0.40, "Set sound volume of horse sounds.")

    options:addDescription("Change the horse speed.")
    config.horseWalkSpeed = options:addSlider("HorseWalkSpeed", "Horse Walk Speed Multiplier (Default 1)", 0.10, 10, 0.10, 1.3, "Change walk speed of horse.")
    config.horseGallopSpeed = options:addSlider("HorseGallopSpeed", "Horse Gallop Speed Multiplier (Default 1)", 0.10, 10, 0.10, 1, "Change gallop speed of horse.")
end

HorseConfig()
