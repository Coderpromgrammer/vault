--[=[
    Silverline UI Framework
    File: Examples/Demo.client.lua
    Purpose: Complete, interactive demonstration script exercising all Silverline components.
]=]

-- Load Silverline UI Framework via GitHub Loadstring
local Silverline = loadstring(game:HttpGet("https://raw.githubusercontent.com/Coderpromgrammer/vault/main/bundle.lua"))()

-- 1. Initialize Application
local app = Silverline.new({
    Title = "SILVERLINE",
    Subtitle = "Precision Interface Engine",
    Theme = "DarkSilver",
    Animations = true,
    Icon = "shield",
})

-- 2. Optional Loading Splash Demo
local loading = app:CreateLoadingScreen({
    Title = "SILVERLINE",
    Subtitle = "Mounting design system...",
    Icon = "shield",
    AllowSkip = true,
})

task.spawn(function()
    loading:SetProgress(0.25, "Compiling visual tokens...")
    task.wait(0.4)
    loading:SetProgress(0.55, "Registering icon atlas...")
    task.wait(0.4)
    loading:SetProgress(0.85, "Mounting responsive viewport...")
    task.wait(0.4)
    loading:Complete(function()
        app:Notify({
            Title = "Framework Ready",
            Content = "Silverline loaded successfully with DarkSilver preset.",
            Type = "Success",
            Duration = 4,
        })
    end)
end)

-- 3. Create Main Window
local window = app:CreateWindow({
    Size = UDim2.fromOffset(700, 460),
    Icon = "shield",
})

-- ==========================================================
-- TAB 1: OVERVIEW / DASHBOARD
-- ==========================================================
local tabOverview = window:CreateTab({
    Name = "Overview",
    Icon = "home",
    Badge = "LIVE",
})

local secStats = tabOverview:CreateSection({
    Name = "System Telemetry",
})

local predPanel = secStats:CreatePredictionPanel({
    Title = "Performance Confidence Index",
    Status = "Optimal",
    Value = "144.2 FPS",
    Confidence = "Stability index: 99.8% (±0.2 ms)",
    OnRefresh = function()
        app:Notify({
            Title = "Telemetry Refreshed",
            Content = "Recalculated frame timings and thread metrics.",
            Type = "Info",
            Duration = 2,
        })
    end,
})

local secActions = tabOverview:CreateSection({
    Name = "Primary Operations",
})

secActions:CreateButton({
    Name = "Execute Primary Task",
    Description = "Initiate high-priority calculation thread",
    Icon = "play",
    Variant = "Primary",
    Callback = function()
        app:Notify({
            Title = "Task Executed",
            Content = "Primary operation completed in 4.2ms.",
            Type = "Success",
        })
    end,
})

secActions:CreateButton({
    Name = "Secondary Routine",
    Description = "Standard operational handler",
    Icon = "activity",
    Variant = "Secondary",
    Callback = function()
        print("[Silverline Demo] Secondary routine invoked")
    end,
})

secActions:CreateButton({
    Name = "Reset Environment",
    Description = "Requires two-click confirmation",
    Icon = "trash",
    Variant = "Danger",
    Confirm = true,
    ConfirmText = "Are you sure? Click to confirm",
    Callback = function()
        app:Notify({
            Title = "Environment Reset",
            Content = "All telemetry caches have been cleared.",
            Type = "Warning",
        })
    end,
})

-- ==========================================================
-- TAB 2: CONTROLS & INPUT
-- ==========================================================
local tabControls = window:CreateTab({
    Name = "Controls",
    Icon = "sliders",
})

local secToggles = tabControls:CreateSection({
    Name = "Binary State Controls",
})

secToggles:CreateToggle({
    Name = "Auto-Rebalance Engine",
    Description = "Dynamically adjusts task priorities on thread load",
    Default = true,
    Keybind = Enum.KeyCode.T,
    Callback = function(val)
        print("Auto-Rebalance is now:", val)
    end,
})

secToggles:CreateCheckbox({
    Name = "Enable Verbose Logging",
    Description = "Emit detailed lifecycle events into the developer console",
    Default = false,
    Callback = function(val)
        print("Verbose logging:", val)
    end,
})

local secSliders = tabControls:CreateSection({
    Name = "Range & Precision Sliders",
})

secSliders:CreateSlider({
    Name = "Memory Allocation Threshold",
    Description = "Upper bound before garbage cycle triggers",
    Min = 64,
    Max = 1024,
    Default = 256,
    Step = 16,
    Suffix = " MB",
    Callback = function(val)
        print("Slider value:", val)
    end,
})

secSliders:CreateRangeSlider({
    Name = "Frame Rate Limiter Bounds",
    Description = "Dynamic lower and upper FPS clamping boundaries",
    Min = 30,
    Max = 240,
    DefaultMin = 60,
    DefaultMax = 144,
    Step = 1,
    Suffix = " FPS",
    Callback = function(minVal, maxVal)
        print("FPS range:", minVal, "-", maxVal)
    end,
})

local secInput = tabControls:CreateSection({
    Name = "Direct Input & Shortcuts",
})

secInput:CreateInput({
    Name = "Custom Session Tag",
    Description = "Alphanumeric identifier tag",
    Placeholder = "e.g. Session_01",
    Default = "AlphaBuild",
    MaxLength = 20,
    Callback = function(text)
        print("Session tag set to:", text)
    end,
})

secInput:CreateKeybind({
    Name = "Emergency Halt Keybind",
    Description = "Click chip to assign shortcut (Escape cancels)",
    Default = Enum.KeyCode.H,
    Mode = "Toggle",
    Callback = function(active)
        app:Notify({
            Title = "Keybind Triggered",
            Content = "Emergency halt key toggled: " .. tostring(active),
            Type = "Warning",
            Duration = 2,
        })
    end,
})

-- ==========================================================
-- TAB 3: SELECTORS & PALETTE
-- ==========================================================
local tabSelectors = window:CreateTab({
    Name = "Selectors",
    Icon = "palette",
})

local secDropdowns = tabSelectors:CreateSection({
    Name = "Dropdown Menus",
})

secDropdowns:CreateDropdown({
    Name = "Rendering Quality Profile",
    Description = "Determines visual fidelity and level of detail",
    Options = { "Ultra (High Fidelity)", "Balanced", "Performance", "Battery Saver" },
    Default = "Balanced",
    Callback = function(choice)
        print("Selected profile:", choice)
    end,
})

secDropdowns:CreateDropdown({
    Name = "Active Plugin Modules",
    Description = "Multi-selection filterable dropdown",
    Multi = true,
    Options = { "Network Inspector", "Audio Equalizer", "Physics Profiler", "Memory Watcher", "Security Shield" },
    Default = { "Network Inspector", "Security Shield" },
    Callback = function(selectedList)
        print("Active plugins:", table.concat(selectedList, ", "))
    end,
})

local secColor = tabSelectors:CreateSection({
    Name = "Color Customization",
})

secColor:CreateColorPicker({
    Name = "Metallic Accent Tint",
    Description = "Fine-tune UI highlights and indicators",
    Default = Color3.fromRGB(158, 191, 232),
    Callback = function(col)
        print("Accent color changed to:", col)
    end,
})

-- ==========================================================
-- TAB 4: SETTINGS & SYSTEM
-- ==========================================================
local tabSettings = window:CreateTab({
    Name = "Settings",
    Icon = "settings",
})

local secThemes = tabSettings:CreateSection({
    Name = "Visual Themes",
})

secThemes:CreateDropdown({
    Name = "Active Theme Preset",
    Description = "Instant cascade update without recreating interface instances",
    Options = { "DarkSilver", "LightSilver", "Obsidian", "Platinum" },
    Default = "DarkSilver",
    Callback = function(themeName)
        window:SetTheme(themeName)
        app:Notify({
            Title = "Theme Changed",
            Content = "Switched visual palette to " .. themeName,
            Type = "Info",
            Duration = 2,
        })
    end,
})

local secAnim = tabSettings:CreateSection({
    Name = "Motion & Accessibility",
})

secAnim:CreateToggle({
    Name = "Enable Fluid Animations",
    Description = "Toggle micro-interactions and transitions",
    Default = true,
    Callback = function(enabled)
        Silverline.Animation.Enabled = enabled
    end,
})

local secAlerts = tabSettings:CreateSection({
    Name = "Notification & Modal Testing",
})

secAlerts:CreateButton({
    Name = "Trigger Success Notification",
    Icon = "check",
    Variant = "Secondary",
    Callback = function()
        app:Notify({
            Title = "Operation Complete",
            Content = "Changes synchronized with cloud datastore.",
            Type = "Success",
        })
    end,
})

secAlerts:CreateButton({
    Name = "Trigger Warning Notification",
    Icon = "warning",
    Variant = "Secondary",
    Callback = function()
        app:Notify({
            Title = "Network Latency Spike",
            Content = "Ping exceeded 120ms threshold.",
            Type = "Warning",
        })
    end,
})

secAlerts:CreateButton({
    Name = "Trigger Error Notification",
    Icon = "close",
    Variant = "Danger",
    Callback = function()
        app:Notify({
            Title = "Handshake Failed",
            Content = "Could not authenticate signature.",
            Type = "Error",
        })
    end,
})

print("[Silverline] Demo initialized successfully.")
