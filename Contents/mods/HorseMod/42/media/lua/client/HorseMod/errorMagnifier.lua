if not getActivatedMods():contains("\\errorMagnifier") then
    return
end

local errorMagnifier = require("errorMagnifier_Main")
assert(errorMagnifier ~= nil, "failed to get error magnifier module")

local MOD_ID = "\\Horse"
local mod = getModInfoByID(MOD_ID)

local function generateDebugReport()
    return {
        ["Game version"] = getCore():getGameVersion():toString(),
        ["Mod version"] = mod:getModVersion(),
        ["Workshop ID"] = mod:getWorkshopID(),
        ["Mode"] = isClient() and "MULTIPLAYER" or "SINGLEPLAYER",
        ["Debug enabled?"] = isDebugEnabled()
    }
end

errorMagnifier.registerDebugReport(MOD_ID, generateDebugReport)
