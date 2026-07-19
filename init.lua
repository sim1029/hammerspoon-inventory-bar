-- ~/.hammerspoon/init.lua
-- App-level "inventory bar"
--   ⌥1..⌥6   -> switch to the app in slot n
--   ⌥⌘1..⌥⌘6 -> bind the currently focused app to slot n (persists across restarts)
--   ⌥⌘0      -> clear all slots
--
-- Slots start EMPTY. Assign your apps once with ⌥⌘<n> and they stick
-- (stored in macOS user defaults, so they survive reloads and restarts).

local SWITCH_MOD = {"alt"}          -- ⌥<n>  -> jump to the app in slot n
local ASSIGN_MOD = {"alt", "cmd"}   -- ⌥⌘<n> -> bind current app to slot n
local SLOT_KEYS  = {"1", "2", "3", "4", "5", "6"}

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

-- Auto-reload when this file is saved
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
hs.alert.show("Inventory bar loaded")
