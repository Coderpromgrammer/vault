# Getting Started with Silverline

This guide walks you through placing Silverline into your Roblox Studio project and creating your first interface.

---

## 1. Installation in Roblox Studio

1. **Place the Module**:
   - In Roblox Studio's **Explorer**, navigate to `ReplicatedStorage`.
   - Insert a `Folder` or `ModuleScript` named `Silverline`.
   - Place the Silverline directory contents inside, ensuring `init.lua` is the root ModuleScript, with `Core`, `Components`, and `Systems` as child folders.

2. **Client Script Location**:
   - Create a `LocalScript` in `StarterPlayer -> StarterPlayerScripts` (or inside a UI container).
   - Require the library:
   ```lua
   local ReplicatedStorage = game:GetService("ReplicatedStorage")
   local Silverline = require(ReplicatedStorage:WaitForChild("Silverline"))
   ```

---

## 2. Basic Setup Walkthrough

### Step 1: Initialize the Application Instance
```lua
local app = Silverline.new({
    Title = "Game Admin",
    Subtitle = "Server Manager v1.0",
    Theme = "DarkSilver",
    Animations = true,
    Icon = "shield",
})
```

### Step 2: Create a Window
```lua
local window = app:CreateWindow({
    Size = UDim2.fromOffset(680, 440),
})
```

### Step 3: Add Tabs and Sections
```lua
local tab = window:CreateTab({
    Name = "Combat",
    Icon = "zap",
    Badge = "NEW",
})

local section = tab:CreateSection({
    Name = "Abilities",
    Collapsible = true,
})
```

### Step 4: Add Controls
```lua
local enableTog = section:CreateToggle({
    Name = "Super Dash",
    Description = "Enables double-tap dash mechanics",
    Default = false,
    Keybind = Enum.KeyCode.Q,
    Callback = function(val)
        print("Super Dash toggled:", val)
    end,
})

local speedSlider = section:CreateSlider({
    Name = "Dash Velocity",
    Min = 10,
    Max = 100,
    Default = 50,
    Step = 5,
    Suffix = " studs/s",
    Callback = function(val)
        print("Dash velocity set to:", val)
    end,
})

local actionBtn = section:CreateButton({
    Name = "Trigger Cooldown Reset",
    Variant = "Primary",
    Icon = "refresh",
    Callback = function()
        app:Notify({
            Title = "Cooldowns Reset",
            Content = "All ability timers have been cleared.",
            Type = "Success",
        })
    end,
})
```

---

## 3. Window Behavior & Shortcuts

- **Dragging**: Click/tap and drag anywhere on the title bar. The window is clamped to stay within the viewport boundary on both desktop and mobile.
- **Minimizing**: Clicking the minimize icon (`-`) folds the window and reveals a compact, draggable floating badge on the edge of the screen.
- **Restoring**: Clicking the floating badge restores the window smoothly.
