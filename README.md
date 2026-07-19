# Hammerspoon Inventory Bar

A tiny [Hammerspoon](https://www.hammerspoon.org/) config that turns your number
keys into a Minecraft-style **inventory bar for apps**. Bind your most-used apps
to slots `1`–`6` and jump straight to any of them with a single keystroke —
faster than Mission Control, `⌘Tab`, or hunting through windows.

## Keybindings

| Shortcut     | Action                                                        |
|--------------|---------------------------------------------------------------|
| `⌥1` … `⌥6`  | Switch to the app in that slot (launches it if not running)   |
| `⌥⌘1` … `⌥⌘6`| Bind the **currently focused** app to that slot               |
| `⌥⌘0`        | Clear all slots                                               |

`⌥` = Option/Alt, `⌘` = Command.

## How it works

- **Slots start empty.** You assign your own apps — there are no baked-in defaults.
- Assignments are saved to macOS user defaults (via `hs.settings`), so they
  **persist across reloads and full restarts**.
- Assignments are stored **per-machine** and do *not* travel with this repo. That's
  intentional — each computer keeps its own app layout. The repo only carries the
  script itself; pull it anywhere and assign fresh.
- Apps are tracked by **bundle ID** (e.g. `com.google.Chrome`), which is stable
  across renames and localizations.

## Install (human)

1. **Install Hammerspoon:**
   ```sh
   brew install --cask hammerspoon
   ```
   (No Homebrew? Download from https://www.hammerspoon.org/ and drag to /Applications.)

2. **Install this config:**
   ```sh
   git clone https://github.com/sim1029/hammerspoon-inventory-bar.git
   cd hammerspoon-inventory-bar
   ./install.sh
   ```
   The script backs up any existing `~/.hammerspoon/init.lua` and copies this one in.

   Prefer to keep the repo linked so `git pull` updates your live config? Symlink instead:
   ```sh
   mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.bak 2>/dev/null || true
   ln -s "$(pwd)/init.lua" ~/.hammerspoon/init.lua
   ```

3. **Launch Hammerspoon** (Spotlight, or `open -a Hammerspoon`).
   - On first launch it asks for **Accessibility** permission. Grant it in
     **System Settings → Privacy & Security → Accessibility** (toggle Hammerspoon on).
     This is required for it to focus apps.
   - You'll see an "Inventory bar loaded" toast.

4. **Assign your apps:** focus an app, press `⌥⌘1`; focus the next, press `⌥⌘2`;
   and so on. From then on `⌥1`–`⌥6` jump straight to them.

## Install (AI agent)

If you're an AI agent setting this up on the user's Mac, do the following. Only the
Homebrew install and the Accessibility permission need the user — everything else you
can do directly.

1. Check prerequisites:
   ```sh
   command -v brew            # Homebrew present?
   ls -d /Applications/Hammerspoon.app 2>/dev/null   # already installed?
   ```
2. If Hammerspoon is absent, ask the user to run `brew install --cask hammerspoon`
   (installing apps and granting permissions should not be done silently).
3. Install the config:
   ```sh
   ./install.sh
   ```
   or copy `init.lua` to `~/.hammerspoon/init.lua` (back up any existing file first).
4. Have the user launch Hammerspoon and grant **Accessibility** permission in
   System Settings → Privacy & Security → Accessibility. The config cannot control
   windows without it.
5. Tell the user the keybindings (table above) and that slots start empty — they
   assign apps with `⌥⌘<n>`.

## Customizing

Open `init.lua`. The knobs are at the top:

```lua
local SWITCH_MOD = {"alt"}          -- key(s) to switch:  ⌥<n>
local ASSIGN_MOD = {"alt", "cmd"}   -- key(s) to assign:  ⌥⌘<n>
local SLOT_KEYS  = {"1","2","3","4","5","6"}
```

- **More slots:** add more keys to `SLOT_KEYS` (e.g. `"7"`, `"8"`).
- **Modifier clashes?** `⌥`+number occasionally collides with app shortcuts (special
  characters, tab switching). Swap `SWITCH_MOD` to something collision-free like a
  Caps-Lock hyper key, or `{"ctrl", "alt"}`.

The config auto-reloads when you save the file — no restart needed.

## Finding an app's bundle ID

Focus the app, then run this in the Hammerspoon Console (menu-bar icon → Console):

```lua
hs.application.frontmostApplication():bundleID()
```

You normally never need this — assigning with `⌥⌘<n>` handles it for you.
