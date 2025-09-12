-- local HorseUtils = require("HorseMod/HorseMod_Utils")

-- HorseCamPan = HorseCamPan or {}

-- local core = getCore()

-- -- Tunables
-- local REQUIRE_RMB      = true   -- must hold RMB to pan
-- local DRAG_SENS_PX     = -50   -- pixels of mouse movement -> pixels of pan (higher = faster)

-- local function isRMBDown()
--   if not REQUIRE_RMB then return true end
--   if isMouseButtonDown then return isMouseButtonDown(1) end -- 0=LMB, 1=RMB
--   if isRightMouseDown   then return isRightMouseDown()   end
--   return false
-- end

-- local dcs = DebugChunkState.checkInstance()

-- local lastMxPos = 0
-- local lastMyPos = 0
-- local sw, sh = core:getScreenWidth(), core:getScreenHeight()

-- function HorseCamPan.onTick()
--   if not isRMBDown() then return end
--   if not sw or not sh or sw <= 0 or sh <= 0 then return end

--   local mx, my = getMouseX(), getMouseY()
--   if mx == nil or my == nil then return end

--   if lastMxPos == mx and lastMyPos == my then return end

--   local cx = mx - (sw * 0.5)
--   local cy = my - (sh * 0.5)

--   local dt   = GameTime.getInstance():getTimeDelta()
--   local sx   = cx * dt * DRAG_SENS_PX
--   local sy   = cy * dt * DRAG_SENS_PX

--   local dxIso, dyIso = HorseUtils.toIsoPlayerRelative(sx, sy)

--   dcs:fromLua2('dragCamera', dxIso, dyIso)

--   lastMxPos = mx
--   lastMyPos = my
-- end

-- Events.OnRenderTick.Add(HorseCamPan.onTick)

-- function HorseCamPan.setSensitivity(pxPerPixel)
--   DRAG_SENS_PX = math.max(0.05, tonumber(pxPerPixel) or DRAG_SENS_PX)
-- end

-- function HorseCamPan.setRequireRMB(enable)
--   REQUIRE_RMB = not not enable
-- end
