# Creating Custom Components in Silverline

Silverline is architected so developers can easily create custom cards, data tables, or specialized interactive widgets without modifying the library's core files.

---

## 1. Quick Extension via `section:AddCustom(instance)`

If you already have a Roblox GuiObject (such as an inventory grid, viewport frame, or health gauge), you can mount it directly inside any section:

```lua
local myCustomFrame = Instance.new("Frame")
myCustomFrame.Size = UDim2.new(1, 0, 0, 100)
myCustomFrame.BackgroundColor3 = Color3.fromRGB(32, 36, 43)

-- Add to section
section:AddCustom(myCustomFrame)
```

`AddCustom` ensures that the instance is automatically cleaned up whenever the section or window is destroyed.

---

## 2. Building a Reusable Theme-Aware Component

To build a first-class custom component that responds to theme changes and respects Silverline's design language, follow this pattern:

```lua
local Silverline = require(game.ReplicatedStorage.Silverline)
local Theme = Silverline.Theme
local Animation = Silverline.Animation
local Cleanup = Silverline.Cleanup

local MyMetricCard = {}
MyMetricCard.__index = MyMetricCard

function MyMetricCard.new(parent: GuiObject, titleText: string, valueText: string)
    local cleanup = Cleanup.new()

    local card = Instance.new("Frame")
    card.Name = "MetricCard_" .. titleText
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = parent
    cleanup:Add(card)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("Border")
    stroke.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 16)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Font = Theme.Get("FontBold")
    label.TextSize = 12
    label.TextColor3 = Theme.Get("Highlight")
    label.Text = titleText
    label.Parent = card

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -20, 0, 24)
    val.Position = UDim2.new(0, 10, 0, 28)
    val.Font = Theme.Get("FontMono")
    val.TextSize = 16
    val.TextColor3 = Theme.Get("Silver")
    val.Text = valueText
    val.Parent = card

    -- Automatically handle theme switching
    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        label.TextColor3 = Theme.Get("Highlight")
        val.TextColor3 = Theme.Get("Silver")
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _val = val,
    }, MyMetricCard)

    return self
end

function MyMetricCard:SetValue(newVal: string)
    self._val.Text = newVal
end

function MyMetricCard:Destroy()
    self._cleanup:Destroy()
end

return MyMetricCard
```

---

## 3. Registering Custom Icons

You can add your own icon assets to Silverline's centralized registry so any component can use them:

```lua
local Icons = Silverline.Icons

-- Register custom asset
Icons.Register("custom-gem", "rbxassetid://10709790479", "♦")

-- Use anywhere:
section:CreateButton({
    Name = "Claim Gem",
    Icon = "custom-gem",
    Callback = function() end,
})
```
