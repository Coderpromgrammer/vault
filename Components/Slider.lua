--!strict
--[=[
    Silverline UI Framework
    Module: Components/Slider.lua
    Purpose: Precision single-value slider with drag, click-to-set, editable numeric readout, and step clamping.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Slider = {}
Slider.__index = Slider

export type SliderProps = {
    Name: string,
    Description: string?,
    Min: number,
    Max: number,
    Default: number?,
    Step: number?,
    Suffix: string?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((value: number) -> ())?,
}

function Slider.new(props: SliderProps)
    local cleanup = Cleanup.new()
    local min = props.Min or 0
    local max = props.Max or 100
    if max <= min then max = min + 1 end
    local step = props.Step or 1
    local suffix = props.Suffix or ""
    local disabled = props.Disabled or false

    local function roundToStep(val: number): number
        val = math.clamp(val, min, max)
        if step > 0 then
            val = math.floor((val - min) / step + 0.5) * step + min
        end
        -- Format precision
        local decimals = 0
        if step < 1 then
            local str = tostring(step)
            local dot = string.find(str, "%.")
            if dot then decimals = #str - dot end
        end
        return tonumber(string.format("%." .. decimals .. "f", val)) or val
    end

    local currentValue = roundToStep(props.Default or min)

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 58 else 50)
    container.Parent = props.Parent
    cleanup:Add(container)

    -- Card Base
    local card = Instance.new("Frame")
    card.Name = "Card"
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
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = card

    -- Header Row (Title on left, editable readout on right)
    local headerRow = Instance.new("Frame")
    headerRow.Name = "HeaderRow"
    headerRow.BackgroundTransparency = 1
    headerRow.Size = UDim2.new(1, 0, 0, 18)
    headerRow.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Font = Theme.Get("FontBold")
    titleLabel.TextSize = 13
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Theme.Get("Highlight")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ClipsDescendants = true
    titleLabel.Parent = headerRow

    -- Readout Input Field
    local readoutBox = Instance.new("TextBox")
    readoutBox.Name = "ReadoutBox"
    readoutBox.Size = UDim2.fromOffset(60, 20)
    readoutBox.Position = UDim2.new(1, -60, 0, 0)
    readoutBox.BackgroundColor3 = Theme.Get("Surface")
    readoutBox.BorderSizePixel = 0
    readoutBox.Font = Theme.Get("FontMono")
    readoutBox.TextSize = 11
    readoutBox.TextColor3 = Theme.Get("Silver")
    readoutBox.Text = tostring(currentValue) .. suffix
    readoutBox.ClearTextOnFocus = false
    readoutBox.Parent = headerRow

    local readoutCorner = Instance.new("UICorner")
    readoutCorner.CornerRadius = UDim.new(0, 4)
    readoutCorner.Parent = readoutBox

    local readoutStroke = Instance.new("UIStroke")
    readoutStroke.Thickness = 1
    readoutStroke.Color = Theme.Get("Border")
    readoutStroke.Parent = readoutBox

    -- Optional Description
    local descLabel: TextLabel? = nil
    if props.Description then
        descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 12)
        descLabel.Position = UDim2.new(0, 0, 0, 20)
        descLabel.Font = Theme.Get("FontPrimary")
        descLabel.TextSize = 10
        descLabel.Text = props.Description
        descLabel.TextColor3 = Theme.Get("TextMuted")
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.ClipsDescendants = true
        descLabel.Parent = card
    end

    -- Track Area
    local trackArea = Instance.new("TextButton")
    trackArea.Name = "TrackArea"
    trackArea.Text = ""
    trackArea.AutoButtonColor = false
    trackArea.BackgroundTransparency = 1
    trackArea.Size = UDim2.new(1, 0, 0, 16)
    trackArea.Position = UDim2.new(0, 0, 1, -16)
    trackArea.Parent = card

    local trackBar = Instance.new("Frame")
    trackBar.Name = "TrackBar"
    trackBar.Size = UDim2.new(1, 0, 0, 4)
    trackBar.Position = UDim2.new(0, 0, 0.5, -2)
    trackBar.BackgroundColor3 = Theme.Get("Border")
    trackBar.BorderSizePixel = 0
    trackBar.Parent = trackArea

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = trackBar

    local fillBar = Instance.new("Frame")
    fillBar.Name = "FillBar"
    local initialRatio = (currentValue - min) / (max - min)
    fillBar.Size = UDim2.new(initialRatio, 0, 1, 0)
    fillBar.BackgroundColor3 = Theme.Get("Silver")
    fillBar.BorderSizePixel = 0
    fillBar.Parent = trackBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillBar

    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.fromOffset(12, 12)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(initialRatio, 0, 0.5, 0)
    handle.BackgroundColor3 = Theme.Get("Highlight")
    handle.BorderSizePixel = 0
    handle.Parent = trackBar

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle

    local handleStroke = Instance.new("UIStroke")
    handleStroke.Thickness = 1
    handleStroke.Color = Theme.Get("Border")
    handleStroke.Parent = handle

    local function updateVisuals(newVal: number)
        currentValue = newVal
        local ratio = math.clamp((currentValue - min) / (max - min), 0, 1)
        fillBar.Size = UDim2.new(ratio, 0, 1, 0)
        handle.Position = UDim2.new(ratio, 0, 0.5, 0)
        readoutBox.Text = tostring(currentValue) .. suffix
    end

    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        readoutBox.BackgroundColor3 = Theme.Get("Surface")
        readoutBox.TextColor3 = Theme.Get("Silver")
        readoutStroke.Color = Theme.Get("Border")
        trackBar.BackgroundColor3 = Theme.Get("Border")
        fillBar.BackgroundColor3 = Theme.Get("Silver")
        handle.BackgroundColor3 = Theme.Get("Highlight")
        if descLabel then descLabel.TextColor3 = Theme.Get("TextMuted") end
    end))

    -- Interactive Dragging
    local isDragging = false

    local function setFromInputPosition(inputX: number)
        local barAbsPos = trackBar.AbsolutePosition.X
        local barAbsWidth = trackBar.AbsoluteSize.X
        if barAbsWidth <= 0 then return end

        local rel = math.clamp((inputX - barAbsPos) / barAbsWidth, 0, 1)
        local rawVal = min + (max - min) * rel
        local finalVal = roundToStep(rawVal)

        if finalVal ~= currentValue then
            updateVisuals(finalVal)
            if props.Callback then
                local success, err = pcall(props.Callback, currentValue)
                if not success then
                    warn("[Silverline Slider] Callback error: " .. tostring(err))
                end
            end
        end
    end

    cleanup:Add(trackArea.InputBegan:Connect(function(input: InputObject)
        if disabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            setFromInputPosition(input.Position.X)
            Animation.Tween(handle, Animation.Presets.Fast, { Size = UDim2.fromOffset(14, 14) })
        end
    end))

    cleanup:Add(UserInputService.InputChanged:Connect(function(input: InputObject)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromInputPosition(input.Position.X)
        end
    end))

    cleanup:Add(UserInputService.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging then
                isDragging = false
                Animation.Tween(handle, Animation.Presets.Fast, { Size = UDim2.fromOffset(12, 12) })
            end
        end
    end))

    -- Readout Manual Text Input
    cleanup:Add(readoutBox.FocusLost:Connect(function()
        local cleanStr = string.gsub(readoutBox.Text, "[^0-9%.%-]", "")
        local num = tonumber(cleanStr)
        if num then
            local stepped = roundToStep(num)
            updateVisuals(stepped)
            if props.Callback then
                pcall(props.Callback, currentValue)
            end
        else
            readoutBox.Text = tostring(currentValue) .. suffix
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _currentValue = currentValue,
        _disabled = disabled,
        _updateVisuals = updateVisuals,
        _roundToStep = roundToStep,
        _props = props,
    }, Slider)

    return self
end

function Slider:GetValue(): number
    return self._currentValue
end

function Slider:SetValue(val: number, triggerCallback: boolean?)
    local stepped = self._roundToStep(val)
    if self._currentValue == stepped then return end
    self._updateVisuals(stepped)

    if triggerCallback and self._props.Callback then
        local success, err = pcall(self._props.Callback, self._currentValue)
        if not success then
            warn("[Silverline Slider] SetValue callback error: " .. tostring(err))
        end
    end
end

function Slider:SetDisabled(disabled: boolean)
    self._disabled = disabled
end

function Slider:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Slider:Destroy()
    self._cleanup:Destroy()
end

return Slider
