--!strict
--[=[
    Silverline UI Framework
    Module: Components/Checkbox.lua
    Purpose: Clean checkbox control with checkmark animation and consistent card layout.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Checkbox = {}
Checkbox.__index = Checkbox

export type CheckboxProps = {
    Name: string,
    Description: string?,
    Default: boolean?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((value: boolean) -> ())?,
}

function Checkbox.new(props: CheckboxProps)
    local cleanup = Cleanup.new()
    local currentValue = if props.Default ~= nil then props.Default else false
    local disabled = props.Disabled or false

    local container = Instance.new("Frame")
    container.Name = "Checkbox_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 46 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    local card = Instance.new("TextButton")
    card.Name = "Card"
    card.Text = ""
    card.AutoButtonColor = false
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("Border")
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card

    -- Text Stack
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -40, 1, 0)
    textStack.Position = UDim2.new(0, 0, 0, 0)
    textStack.Parent = card

    local stackLayout = Instance.new("UIListLayout")
    stackLayout.FillDirection = Enum.FillDirection.Vertical
    stackLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    stackLayout.Padding = UDim.new(0, 2)
    stackLayout.Parent = textStack

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.Font = Theme.Get("FontBold")
    titleLabel.TextSize = 13
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Theme.Get("Highlight")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ClipsDescendants = true
    titleLabel.Parent = textStack

    local descLabel: TextLabel? = nil
    if props.Description then
        descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 14)
        descLabel.Font = Theme.Get("FontPrimary")
        descLabel.TextSize = 11
        descLabel.Text = props.Description
        descLabel.TextColor3 = Theme.Get("TextMuted")
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ClipsDescendants = true
        descLabel.Parent = textStack
    end

    -- Checkbox Square
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.fromOffset(20, 20)
    box.Position = UDim2.new(1, -20, 0.5, -10)
    box.BackgroundColor3 = if currentValue then Theme.Get("Silver") else Theme.Get("Surface")
    box.BorderSizePixel = 0
    box.Parent = card

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Thickness = 1
    boxStroke.Color = if currentValue then Theme.Get("Highlight") else Theme.Get("Border")
    boxStroke.Parent = box

    -- Check Icon
    local checkIcon = Icons.Create({
        Name = "check",
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        Color = Color3.fromRGB(16, 18, 22),
        Parent = box,
    })
    checkIcon.ImageTransparency = if currentValue then 0 else 1

    local function updateVisuals(animate: boolean)
        local targetBg = if disabled then Theme.Get("Border") elseif currentValue then Theme.Get("Silver") else Theme.Get("Surface")
        local targetStroke = if currentValue then Theme.Get("Highlight") else Theme.Get("Border")
        local targetCheckTrans = if currentValue then 0 else 1

        if animate then
            Animation.Tween(box, Animation.Presets.Toggle, { BackgroundColor3 = targetBg })
            Animation.Tween(boxStroke, Animation.Presets.Toggle, { Color = targetStroke })
            Animation.Tween(checkIcon, Animation.Presets.Toggle, { ImageTransparency = targetCheckTrans })
        else
            box.BackgroundColor3 = targetBg
            boxStroke.Color = targetStroke
            checkIcon.ImageTransparency = targetCheckTrans
        end
    end

    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        if descLabel then descLabel.TextColor3 = Theme.Get("TextMuted") end
        updateVisuals(false)
    end))

    cleanup:Add(card.MouseEnter:Connect(function()
        if disabled then return end
        Animation.Tween(card, Animation.Presets.Fast, { BackgroundColor3 = Theme.Get("SurfaceHover") })
        Animation.Tween(stroke, Animation.Presets.Fast, { Color = Theme.Get("BorderHighlight") })
    end))

    cleanup:Add(card.MouseLeave:Connect(function()
        if disabled then return end
        Animation.Tween(card, Animation.Presets.Fast, { BackgroundColor3 = Theme.Get("SurfaceElevated") })
        Animation.Tween(stroke, Animation.Presets.Fast, { Color = Theme.Get("Border") })
    end))

    cleanup:Add(card.MouseButton1Click:Connect(function()
        if disabled then return end
        currentValue = not currentValue
        updateVisuals(true)

        if props.Callback then
            local success, err = pcall(props.Callback, currentValue)
            if not success then
                warn("[Silverline Checkbox] Callback error: " .. tostring(err))
            end
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _currentValue = currentValue,
        _disabled = disabled,
        _updateVisuals = updateVisuals,
        _props = props,
    }, Checkbox)

    return self
end

function Checkbox:GetValue(): boolean
    return self._currentValue
end

function Checkbox:SetValue(value: boolean, triggerCallback: boolean?)
    if self._currentValue == value then return end
    self._currentValue = value
    self._updateVisuals(true)

    if triggerCallback and self._props.Callback then
        local success, err = pcall(self._props.Callback, self._currentValue)
        if not success then
            warn("[Silverline Checkbox] SetValue callback error: " .. tostring(err))
        end
    end
end

function Checkbox:SetDisabled(disabled: boolean)
    self._disabled = disabled
    self._updateVisuals(false)
end

function Checkbox:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Checkbox:Destroy()
    self._cleanup:Destroy()
end

return Checkbox
