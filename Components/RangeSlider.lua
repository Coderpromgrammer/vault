--!strict
--[=[
    Silverline UI Framework
    Module: Components/RangeSlider.lua
    Purpose: Dual-handled range slider supporting lower and upper bounds with step clamping.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local RangeSlider = {}
RangeSlider.__index = RangeSlider

export type RangeSliderProps = {
    Name: string,
    Description: string?,
    Min: number,
    Max: number,
    DefaultMin: number?,
    DefaultMax: number?,
    Step: number?,
    Suffix: string?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((minVal: number, maxVal: number) -> ())?,
}

function RangeSlider.new(props: RangeSliderProps)
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
        local decimals = 0
        if step < 1 then
            local str = tostring(step)
            local dot = string.find(str, "%.")
            if dot then decimals = #str - dot end
        end
        return tonumber(string.format("%." .. decimals .. "f", val)) or val
    end

    local currentMin = roundToStep(props.DefaultMin or min)
    local currentMax = roundToStep(props.DefaultMax or max)
    if currentMin > currentMax then
        currentMin, currentMax = currentMax, currentMin
    end

    local container = Instance.new("Frame")
    container.Name = "RangeSlider_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 58 else 50)
    container.Parent = props.Parent
    cleanup:Add(container)

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

    -- Header Row
    local headerRow = Instance.new("Frame")
    headerRow.Name = "HeaderRow"
    headerRow.BackgroundTransparency = 1
    headerRow.Size = UDim2.new(1, 0, 0, 18)
    headerRow.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -110, 1, 0)
    titleLabel.Font = Theme.Get("FontBold")
    titleLabel.TextSize = 13
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Theme.Get("Highlight")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ClipsDescendants = true
    titleLabel.Parent = headerRow

    local readout = Instance.new("TextLabel")
    readout.Name = "Readout"
    readout.Size = UDim2.fromOffset(100, 20)
    readout.Position = UDim2.new(1, -100, 0, 0)
    readout.BackgroundColor3 = Theme.Get("Surface")
    readout.BorderSizePixel = 0
    readout.Font = Theme.Get("FontMono")
    readout.TextSize = 10
    readout.TextColor3 = Theme.Get("Silver")
    readout.Text = tostring(currentMin) .. " - " .. tostring(currentMax) .. suffix
    readout.Parent = headerRow

    local readoutCorner = Instance.new("UICorner")
    readoutCorner.CornerRadius = UDim.new(0, 4)
    readoutCorner.Parent = readout

    local readoutStroke = Instance.new("UIStroke")
    readoutStroke.Thickness = 1
    readoutStroke.Color = Theme.Get("Border")
    readoutStroke.Parent = readout

    -- Track Area
    local trackArea = Instance.new("Frame")
    trackArea.Name = "TrackArea"
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
    fillBar.BackgroundColor3 = Theme.Get("Silver")
    fillBar.BorderSizePixel = 0
    fillBar.Parent = trackBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillBar

    -- Two Handles
    local function createHandle(name: string)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Size = UDim2.fromOffset(12, 12)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.BackgroundColor3 = Theme.Get("Highlight")
        btn.BorderSizePixel = 0
        btn.Parent = trackBar

        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(1, 0)
        hCorner.Parent = btn

        local hStroke = Instance.new("UIStroke")
        hStroke.Thickness = 1
        hStroke.Color = Theme.Get("Border")
        hStroke.Parent = btn
        return btn
    end

    local minHandle = createHandle("MinHandle")
    local maxHandle = createHandle("MaxHandle")

    local function updateVisuals()
        local minRatio = math.clamp((currentMin - min) / (max - min), 0, 1)
        local maxRatio = math.clamp((currentMax - min) / (max - min), 0, 1)

        fillBar.Position = UDim2.new(minRatio, 0, 0, 0)
        fillBar.Size = UDim2.new(maxRatio - minRatio, 0, 1, 0)

        minHandle.Position = UDim2.new(minRatio, 0, 0.5, 0)
        maxHandle.Position = UDim2.new(maxRatio, 0, 0.5, 0)

        readout.Text = tostring(currentMin) .. " - " .. tostring(currentMax) .. suffix
    end

    updateVisuals()

    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        readout.BackgroundColor3 = Theme.Get("Surface")
        readout.TextColor3 = Theme.Get("Silver")
        readoutStroke.Color = Theme.Get("Border")
        trackBar.BackgroundColor3 = Theme.Get("Border")
        fillBar.BackgroundColor3 = Theme.Get("Silver")
        minHandle.BackgroundColor3 = Theme.Get("Highlight")
        maxHandle.BackgroundColor3 = Theme.Get("Highlight")
    end))

    local draggingTarget: string? = nil

    local function handleDrag(inputX: number)
        local barX = trackBar.AbsolutePosition.X
        local barW = trackBar.AbsoluteSize.X
        if barW <= 0 then return end

        local ratio = math.clamp((inputX - barX) / barW, 0, 1)
        local rawVal = min + (max - min) * ratio
        local val = roundToStep(rawVal)

        local changed = false
        if draggingTarget == "min" then
            if val > currentMax then val = currentMax end
            if val ~= currentMin then
                currentMin = val
                changed = true
            end
        elseif draggingTarget == "max" then
            if val < currentMin then val = currentMin end
            if val ~= currentMax then
                currentMax = val
                changed = true
            end
        end

        if changed then
            updateVisuals()
            if props.Callback then
                pcall(props.Callback, currentMin, currentMax)
            end
        end
    end

    cleanup:Add(minHandle.InputBegan:Connect(function(input)
        if disabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingTarget = "min"
        end
    end))

    cleanup:Add(maxHandle.InputBegan:Connect(function(input)
        if disabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingTarget = "max"
        end
    end))

    cleanup:Add(UserInputService.InputChanged:Connect(function(input)
        if draggingTarget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleDrag(input.Position.X)
        end
    end))

    cleanup:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingTarget = nil
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _currentMin = currentMin,
        _currentMax = currentMax,
        _disabled = disabled,
        _updateVisuals = updateVisuals,
        _props = props,
    }, RangeSlider)

    return self
end

function RangeSlider:GetValues(): (number, number)
    return self._currentMin, self._currentMax
end

function RangeSlider:SetValues(minVal: number, maxVal: number, triggerCallback: boolean?)
    self._currentMin = minVal
    self._currentMax = maxVal
    self._updateVisuals()
    if triggerCallback and self._props.Callback then
        pcall(self._props.Callback, self._currentMin, self._currentMax)
    end
end

function RangeSlider:SetDisabled(disabled: boolean)
    self._disabled = disabled
end

function RangeSlider:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function RangeSlider:Destroy()
    self._cleanup:Destroy()
end

return RangeSlider
