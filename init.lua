-- ~/.hammerspoon/init.lua
-- App-level "inventory bar"
--   ⌥1..⌥9   -> switch to the app in slot n
--   ⌥⌘1..⌥⌘9 -> bind the currently focused app to slot n (persists across restarts)
--   ⌥0       -> show the inventory bar (which app is in which slot)
--   ⌥⌘0      -> clear all slots
--
-- Slots start EMPTY. Assign your apps once with ⌥⌘<n> and they stick
-- (stored in macOS user defaults, so they survive reloads and restarts).

local SWITCH_MOD = {"alt"}          -- ⌥<n>  -> jump to the app in slot n
local ASSIGN_MOD = {"alt", "cmd"}   -- ⌥⌘<n> -> bind current app to slot n
local SLOT_KEYS  = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}

-- Live "save file": persisted app assignments, by bundle ID. Starts empty.
local slots = hs.settings.get("appSlots") or {}

local function save() hs.settings.set("appSlots", slots) end

-- Friendly app name from a bundle ID, for the on-screen toasts.
local function nameFor(bundleID)
  if not bundleID then return "empty" end
  local path = hs.application.pathForBundleID(bundleID)
  return path and hs.application.infoForBundlePath(path).CFBundleName or bundleID
end

for _, key in ipairs(SLOT_KEYS) do
  -- SWITCH: focus (or launch) the app bound to this slot
  hs.hotkey.bind(SWITCH_MOD, key, function()
    local id = slots[key]
    if id then
      hs.application.launchOrFocusByBundleID(id)
    else
      hs.alert.show("Slot " .. key .. " is empty  —  ⌥⌘" .. key .. " to assign")
    end
  end)

  -- REASSIGN: bind the currently focused app to this slot, and persist it
  hs.hotkey.bind(ASSIGN_MOD, key, function()
    local app = hs.application.frontmostApplication()
    local id  = app and app:bundleID()
    if id then
      slots[key] = id
      save()
      hs.alert.show("Slot " .. key .. "  \u{2794}  " .. nameFor(id))
    end
  end)
end

-- Clear all slots: ⌥⌘0
hs.hotkey.bind(ASSIGN_MOD, "0", function()
  slots = {}
  save()
  hs.alert.show("All slots cleared")
end)

-- ===== Inventory HUD: ⌥0 pops up a Minecraft-style bar of all slots =====
local hud, hudTimer = nil, nil

local function hideHUD()
  if hudTimer then hudTimer:stop(); hudTimer = nil end
  if hud then hud:delete(); hud = nil end
end

local function showHUD()
  hideHUD()  -- rebuild fresh so it reflects the current assignments

  local N        = #SLOT_KEYS
  local slotSize = 72
  local gap      = 8
  local pad      = 12
  local labelH   = 16
  local barW     = N * slotSize + (N - 1) * gap + 2 * pad
  local barH     = slotSize + labelH + 2 * pad

  local sf = hs.screen.mainScreen():frame()
  local x  = sf.x + (sf.w - barW) / 2
  local y  = sf.y + sf.h - barH - 80

  hud = hs.canvas.new({ x = x, y = y, w = barW, h = barH })

  -- backdrop
  hud:appendElements({
    type = "rectangle", action = "fill",
    roundedRectRadii = { xRadius = 14, yRadius = 14 },
    fillColor = { red = 0.08, green = 0.08, blue = 0.10, alpha = 0.92 },
  })

  for i, key in ipairs(SLOT_KEYS) do
    local sx = pad + (i - 1) * (slotSize + gap)
    local sy = pad
    local id = slots[key]

    -- slot cell
    hud:appendElements({
      type = "rectangle", action = "fill",
      roundedRectRadii = { xRadius = 8, yRadius = 8 },
      fillColor = id and { white = 1, alpha = 0.10 } or { white = 1, alpha = 0.04 },
      strokeColor = { white = 1, alpha = 0.18 }, strokeWidth = 1,
      frame = { x = sx, y = sy, w = slotSize, h = slotSize },
    })

    -- app icon (if this slot is assigned)
    if id then
      local icon = hs.image.imageFromAppBundle(id)
      if icon then
        local inset = 12
        hud:appendElements({
          type = "image", image = icon, imageScaling = "scaleProportionally",
          frame = { x = sx + inset, y = sy + inset, w = slotSize - 2 * inset, h = slotSize - 2 * inset },
        })
      end
    end

    -- slot number badge (top-left corner)
    hud:appendElements({
      type = "text", text = key, textSize = 13,
      textColor = { white = 1, alpha = 0.85 },
      frame = { x = sx + 6, y = sy + 3, w = 20, h = 16 },
    })

    -- app name under the cell
    hud:appendElements({
      type = "text", text = id and nameFor(id) or "—", textSize = 10,
      textAlignment = "center",
      textColor = { white = 1, alpha = id and 0.7 or 0.3 },
      frame = { x = sx - 4, y = sy + slotSize + 1, w = slotSize + 8, h = labelH },
    })
  end

  hud:level(hs.canvas.windowLevels.overlay)
  hud:show()
  hudTimer = hs.timer.doAfter(2.5, hideHUD)  -- auto-dismiss
end

-- ⌥0 toggles the inventory bar
hs.hotkey.bind(SWITCH_MOD, "0", function()
  if hud then hideHUD() else showHUD() end
end)

-- Auto-reload when this file is saved
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
hs.alert.show("Inventory bar loaded")
