local POPUP_HEIGHT = 120
local CORE = getCore()

local function make_popup(text, onclick)
    local width = getTextManager():MeasureStringX(UIFont.Small, text) + 20
    -- i wanted to colour the text, but this doesn't use ISRichTextPanel :(
    -- yea and me I wanted to add an image to it HAAAAAAAAAAAAAAAAA
    local popup = ISModalDialog:new(
        (CORE:getScreenWidth() - width) / 2,
        (CORE:getScreenHeight() - POPUP_HEIGHT) / 2,
        width,
        POPUP_HEIGHT,
        text,
        false,
        nil,
        onclick
    )
    popup:setAlwaysOnTop(true)
    popup:initialise()
    popup:addToUIManager()
end

local MAKE_NEW_SAVE_WARNING = false

---Checks for the meatball issue by verifying that the horse's animation clips are properly loaded.
local function check_meatball()
    -- need to do it here bcs the other event is too early to show a UI
    if MAKE_NEW_SAVE_WARNING then
        local text = getText("IGUI_HorseMod_OldSaveWarning")
        make_popup(text, function(dialog)
            local modData = ModData.getOrCreate("horsemod")
            modData.newGame = true
        end)
    end


    local animViewer = AnimationViewerState.checkInstance()

    local clips = animViewer:fromLua1("getClipNames", "HorseMod.Horse")
    local size = clips:size()
    animViewer:fromLua0('exit')

    if size > 0 then 
        print("No meatball issue detected, horse animation clips loaded successfully.")
        return 
    end

    print("WARNING, MEATBALL ISSUE DETECTED")

    local text = getText("IGUI_HorseMod_MeatballWarning")
    make_popup(text)
end

Events.OnGameStart.Add(check_meatball)


local function check_new_game(newGame)
    print("Checking for new game. newGame =", newGame)
    local modData = ModData.getOrCreate("horsemod")
    print(newGame, modData.newGame)
    if newGame then
        modData.newGame = true
    elseif not modData.newGame then
        -- this means that the save was created, then the mod was added later
        print("WARNING, OLD SAVE DETECTED")
        MAKE_NEW_SAVE_WARNING = true
    end
end


Events.OnInitGlobalModData.Add(check_new_game)