local function deepcopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local r = {}
    for k,v in pairs(tbl) do r[k] = deepcopy(v) end
    return r
end

local function addUnique(t, val)
    for i=1,#t do if t[i] == val then return end end
    table.insert(t, val)
end

local function patchRanchZones()
    RanchZoneDefinitions = RanchZoneDefinitions or {}
    RanchZoneDefinitions.type = RanchZoneDefinitions.type or {}

    -- Grab the existing cow def to copy from
    local cowDef = RanchZoneDefinitions.type["cow"]
    if not cowDef then
        return
    end

    -- Build the horse def by cloning cow and swapping types
    local horseDef = deepcopy(cowDef)
    horseDef.femaleType = "mare"
    horseDef.maleType   = "stallion"
    horseDef.babyType   = "filly"

    RanchZoneDefinitions.type["horse"] = horseDef

    local wrapper =
        (RanchZoneDefinitions.type and RanchZoneDefinitions.type["notchicken"]) or
        RanchZoneDefinitions["notchicken"]

    if wrapper and type(wrapper.possibleDef) == "table" then
        addUnique(wrapper.possibleDef, "horse")
    end
end

Events.OnGameStart.Add(patchRanchZones)