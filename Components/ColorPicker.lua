--!strict
--[=[
    Silverline UI Framework
    Module: Components/ColorPicker.lua
    Purpose: Expandable HSV color picker with hue slider, hex editor, alpha channel, and live swatch preview.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

export type ColorPickerProps = {
    Name: string,
    Description: string?,
    Default: Color3?,
    Alpha: boolean?,
    DefaultAlpha: number?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((color: Color3, alpha: number) -> ())?,
}

function ColorPicker.new(props: ColorPickerProps)
    local cleanup = Cleanup.new()
    local currentColor = props.Default or Color3.fromRGB(198, 204, 213)
    local currentAlpha = props.DefaultAlpha or 1
    local disabled = props.Disabled or false
    local isExpanded = false

    local h, s, v = currentColor:ToHSV()

    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 50 else 38)
    container.Parent = props.Parent
    cleanup:Add(container)

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
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
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = card

    -- Header Row (Title on left, Swatch button on right)
    local headerRow = Instance.new("TextButton")
    headerRow.Name = "HeaderRow"
    headerRow.Text = ""
    headerRow.AutoButtonColor = false
    headerRow.BackgroundTransparency = 1
    headerRow.Size = UDim2.new(1, 0, 0, if props.Description then 38 else 26)
    headerRow.Position = UDim2.new(0, 0, 0, 0)
    headerRow.Parent = card

    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -50, 1, 0)
    textStack.Parent = headerRow

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

    if props.Description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 12)
        descLabel.Font = Theme.Get("FontPrimary")
        descLabel.TextSize = 10
        descLabel.Text = props.Description
        descLabel.TextColor3 = Theme.Get("TextMuted")
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ClipsDescendants = true
        descLabel.Parent = textStack
    end

    -- Swatch Preview
    local swatch = Instance.new("Frame")
    swatch.Name = "Swatch"
    swatch.Size = UDim2.fromOffset(34, 20)
    swatch.Position = UDim2.new(1, -34, 0.5, -10)
    swatch.BackgroundColor3 = currentColor
    swatch.BorderSizePixel = 0
    swatch.Parent = headerRow

    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, 4)
    swatchCorner.Parent = swatch

    local swatchStroke = Instance.new("UIStroke")
    swatchStroke.Thickness = 1
    swatchStroke.Color = Theme.Get("Border")
    swatchStroke.Parent = swatch

    -- Flyout Controls Container
    local flyout = Instance.new("Frame")
    flyout.Name = "Flyout"
    flyout.BackgroundTransparency = 1
    flyout.Size = UDim2.new(1, 0, 0, 110)
    flyout.Position = UDim2.new(0, 0, 0, if props.Description then 42 else 32)
    flyout.Visible = false
    flyout.Parent = card

    -- Hue Slider Track
    local hueTrack = Instance.new("TextButton")
    hueTrack.Name = "HueTrack"
    hueTrack.Text = ""
    hueTrack.AutoButtonColor = false
    hueTrack.Size = UDim2.new(1, 0, 0, 12)
    hueTrack.Position = UDim2.new(0, 0, 0, 8)
    hueTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueTrack.BorderSizePixel = 0
    hueTrack.Parent = flyout

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(1, 0)
    hueCorner.Parent = hueTrack

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
    })
    hueGrad.Parent = hueTrack

    local hueHandle = Instance.new("Frame")
    hueHandle.Name = "HueHandle"
    hueHandle.Size = UDim2.fromOffset(8, 16)
    hueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    hueHandle.Position = UDim2.new(h, 0, 0.5, 0)
    hueHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueHandle.BorderSizePixel = 0
    hueHandle.Parent = hueTrack

    local hhCorner = Instance.new("UICorner")
    hhCorner.CornerRadius = UDim.new(0, 2)
    hhCorner.Parent = hueHandle

    -- Saturation/Value Slider Track (Lightness/Shade)
    local valTrack = Instance.new("TextButton")
    valTrack.Name = "ValTrack"
    valTrack.Text = ""
    valTrack.AutoButtonColor = false
    valTrack.Size = UDim2.new(1, 0, 0, 12)
    valTrack.Position = UDim2.new(0, 0, 0, 30)
    valTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    valTrack.BorderSizePixel = 0
    valTrack.Parent = flyout

    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(1, 0)
    valCorner.Parent = valTrack

    local valGrad = Instance.new("UIGradient")
    valGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, 1, 1))
    valGrad.Parent = valTrack

    local valHandle = Instance.new("Frame")
    valHandle.Name = "ValHandle"
    valHandle.Size = UDim2.fromOffset(8, 16)
    valHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    valHandle.Position = UDim2.new(v, 0, 0.5, 0)
    valHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    valHandle.BorderSizePixel = 0
    valHandle.Parent = valTrack

    local vhCorner = Instance.new("UICorner")
    vhCorner.CornerRadius = UDim.new(0, 2)
    vhCorner.Parent = valHandle

    -- Hex String Field
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Name = "HexLabel"
    hexLabel.BackgroundTransparency = 1
    hexLabel.Size = UDim2.fromOffset(30, 24)
    hexLabel.Position = UDim2.new(0, 0, 0, 54)
    hexLabel.Font = Theme.Get("FontMono")
    hexLabel.TextSize = 11
    hexLabel.TextColor3 = Theme.Get("TextMuted")
    hexLabel.Text = "HEX"
    hexLabel.Parent = flyout

    local hexInput = Instance.new("TextBox")
    hexInput.Name = "HexInput"
    hexInput.Size = UDim2.new(0, 90, 0, 24)
    hexInput.Position = UDim2.new(0, 34, 0, 54)
    hexInput.BackgroundColor3 = Theme.Get("Surface")
    hexInput.BorderSizePixel = 0
    hexInput.Font = Theme.Get("FontMono")
    hexInput.TextSize = 11
    hexInput.TextColor3 = Theme.Get("Highlight")
    hexInput.Text = "#" .. currentColor:ToHex()
    hexInput.ClearTextOnFocus = false
    hexInput.Parent = flyout

    local hiCorner = Instance.new("UICorner")
    hiCorner.CornerRadius = UDim.new(0, 4)
    hiCorner.Parent = hexInput

    local hiStroke = Instance.new("UIStroke")
    hiStroke.Thickness = 1
    hiStroke.Color = Theme.Get("Border")
    hiStroke.Parent = hexInput

    local function updateColor(newColor: Color3)
        currentColor = newColor
        h, s, v = currentColor:ToHSV()
        swatch.BackgroundColor3 = currentColor
        hueHandle.Position = UDim2.new(h, 0, 0.5, 0)
        valHandle.Position = UDim2.new(v, 0, 0.5, 0)
        valGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, 1, 1))
        hexInput.Text = "#" .. currentColor:ToHex()

        if props.Callback then
            pcall(props.Callback, currentColor, currentAlpha)
        end
    end

    -- Interaction: Expand / Collapse
    headerRow.MouseButton1Click:Connect(function()
        if disabled then return end
        isExpanded = not isExpanded
        flyout.Visible = isExpanded

        local targetH = if isExpanded then (if props.Description then 145 else 135) else (if props.Description then 50 else 38)
        Animation.Tween(container, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, targetH) })
    end)

    -- Hue Drag
    local draggingHue = false
    cleanup:Add(hueTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            local rel = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            h = rel
            updateColor(Color3.fromHSV(h, s, v))
        end
    end))

    -- Value Drag
    local draggingVal = false
    cleanup:Add(valTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingVal = true
            local rel = math.clamp((input.Position.X - valTrack.AbsolutePosition.X) / valTrack.AbsoluteSize.X, 0, 1)
            v = rel
            updateColor(Color3.fromHSV(h, s, v))
        end
    end))

    cleanup:Add(UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if draggingHue then
                local rel = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
                h = rel
                updateColor(Color3.fromHSV(h, s, v))
            elseif draggingVal then
                local rel = math.clamp((input.Position.X - valTrack.AbsolutePosition.X) / valTrack.AbsoluteSize.X, 0, 1)
                v = rel
                updateColor(Color3.fromHSV(h, s, v))
            end
        end
    end))

    cleanup:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
            draggingVal = false
        end
    end))

    -- Hex manual editing
    cleanup:Add(hexInput.FocusLost:Connect(function()
        local raw = string.gsub(hexInput.Text, "[^0-9A-Fa-f]", "")
        if #raw == 6 then
            local ok, parsed = pcall(function()
                return Color3.fromHex(raw)
            end)
            if ok and parsed then
                updateColor(parsed)
            end
        else
            hexInput.Text = "#" .. currentColor:ToHex()
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _currentColor = currentColor,
        _currentAlpha = currentAlpha,
        _updateColor = updateColor,
        _disabled = disabled,
        _props = props,
    }, ColorPicker)

    return self
end

function ColorPicker:GetColor(): (Color3, number)
    return self._currentColor, self._currentAlpha
end

function ColorPicker:SetColor(color: Color3, alpha: number?, triggerCallback: boolean?)
    self._currentAlpha = alpha or self._currentAlpha
    self._updateColor(color)
end

function ColorPicker:SetDisabled(disabled: boolean)
    self._disabled = disabled
end

function ColorPicker:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function ColorPicker:Destroy()
    self._cleanup:Destroy()
end

return ColorPicker
