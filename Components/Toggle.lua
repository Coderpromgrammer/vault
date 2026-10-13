--!strict
--[=[
    Silverline UI Framework
    Module: Components/Toggle.lua
    Purpose: Premium switch toggle with animated sliding knob, keybind integration, and guarded callbacks.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)
local Input = require(script.Parent.Parent.Systems.Input)

local Toggle = {}
Toggle.__index = Toggle

export type ToggleProps = {
    Name: string,
    Description: string?,
    Default: boolean?,
    Keybind: Enum.KeyCode?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((value: boolean) -> ())?,
}

function Toggle.new(props: ToggleProps)
    local cleanup = Cleanup.new()
    local currentValue = if props.Default ~= nil then props.Default else false
    local disabled = props.Disabled or false

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 46 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    -- Clickable Card Row
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
    textStack.Size = UDim2.new(1, -70, 1, 0)
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

    -- Controls Right Area (Pill Switch + optional Keybind badge)
    local rightArea = Instance.new("Frame")
    rightArea.Name = "RightArea"
    rightArea.BackgroundTransparency = 1
    rightArea.Size = UDim2.new(0, 60, 1, 0)
    rightArea.Position = UDim2.new(1, -60, 0, 0)
    rightArea.Parent = card

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.FillDirection = Enum.FillDirection.Horizontal
    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.Parent = rightArea

    -- Keybind Badge if assigned
    local keybindBadge: TextLabel? = nil
    if props.Keybind then
        keybindBadge = Instance.new("TextLabel")
        keybindBadge.Name = "KeybindBadge"
        keybindBadge.BackgroundColor3 = Theme.Get("Surface")
        keybindBadge.Size = UDim2.fromOffset(22, 18)
        keybindBadge.Font = Theme.Get("FontMono")
        keybindBadge.TextSize = 10
        keybindBadge.TextColor3 = Theme.Get("Silver")
        keybindBadge.Text = props.Keybind.Name
        keybindBadge.Parent = rightArea

        local kbCorner = Instance.new("UICorner")
        kbCorner.CornerRadius = UDim.new(0, 4)
        kbCorner.Parent = keybindBadge

        local kbStroke = Instance.new("UIStroke")
        kbStroke.Thickness = 1
        kbStroke.Color = Theme.Get("Border")
        kbStroke.Parent = keybindBadge
    end

    -- Switch Track (Pill)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.fromOffset(36, 20)
    track.BackgroundColor3 = if currentValue then Theme.Get("Silver") else Theme.Get("Border")
    track.BorderSizePixel = 0
    track.Parent = rightArea

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Sliding Knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = if currentValue then UDim2.new(1, -17, 0.5, -7) else UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = if currentValue then Color3.fromRGB(16, 18, 22) else Theme.Get("Highlight")
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Update Visual State
    local function updateVisuals(animate: boolean)
        local targetKnobPos = if currentValue then UDim2.new(1, -17, 0.5, -7) else UDim2.new(0, 3, 0.5, -7)
        local targetTrackColor = if disabled then Theme.Get("Border") elseif currentValue then Theme.Get("Silver") else Theme.Get("SurfaceHover")
        local targetKnobColor = if disabled then Theme.Get("TextDisabled") elseif currentValue then Color3.fromRGB(16, 18, 22) else Theme.Get("Silver")

        if animate then
            Animation.Tween(knob, Animation.Presets.Toggle, { Position = targetKnobPos, BackgroundColor3 = targetKnobColor })
            Animation.Tween(track, Animation.Presets.Toggle, { BackgroundColor3 = targetTrackColor })
        else
            knob.Position = targetKnobPos
            knob.BackgroundColor3 = targetKnobColor
            track.BackgroundColor3 = targetTrackColor
        end
    end

    -- Theme Binding
    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        if descLabel then
            descLabel.TextColor3 = Theme.Get("TextMuted")
        end
        updateVisuals(false)
    end))

    -- Hover feedback
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

    -- Toggle Interaction
    local function toggleValue()
        if disabled then return end
        currentValue = not currentValue
        updateVisuals(true)

        if props.Callback then
            local success, err = pcall(props.Callback, currentValue)
            if not success then
                warn("[Silverline Toggle] Callback error: " .. tostring(err))
            end
        end
    end

    cleanup:Add(card.MouseButton1Click:Connect(toggleValue))

    -- Keybind listener if specified
    if props.Keybind then
        cleanup:Add(Input.BindKey(props.Keybind, function(isHeld)
            if isHeld then
                toggleValue()
            end
        end))
    end

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _card = card,
        _titleLabel = titleLabel,
        _descLabel = descLabel,
        _keybindBadge = keybindBadge,
        _currentValue = currentValue,
        _disabled = disabled,
        _updateVisuals = updateVisuals,
        _props = props,
    }, Toggle)

    return self
end

function Toggle:GetValue(): boolean
    return self._currentValue
end

function Toggle:SetValue(value: boolean, triggerCallback: boolean?)
    if self._currentValue == value then return end
    self._currentValue = value
    self._updateVisuals(true)

    if triggerCallback and self._props.Callback then
        local success, err = pcall(self._props.Callback, self._currentValue)
        if not success then
            warn("[Silverline Toggle] SetValue callback error: " .. tostring(err))
        end
    end
end

function Toggle:SetDisabled(disabled: boolean)
    self._disabled = disabled
    self._titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
    self._updateVisuals(false)
end

function Toggle:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Toggle:Destroy()
    self._cleanup:Destroy()
end

return Toggle
