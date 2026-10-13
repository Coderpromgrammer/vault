--!strict
--[=[
    Silverline UI Framework
    Module: Components/Keybind.lua
    Purpose: Interactive keybind picker supporting listening state, hold/toggle modes, and typing filtering.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Input = require(script.Parent.Parent.Systems.Input)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Keybind = {}
Keybind.__index = Keybind

export type KeybindProps = {
    Name: string,
    Description: string?,
    Default: Enum.KeyCode?,
    Mode: ("Toggle" | "Hold")?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((activeOrPressed: boolean) -> ())?,
    OnKeyChanged: ((key: Enum.KeyCode?) -> ())?,
}

function Keybind.new(props: KeybindProps)
    local cleanup = Cleanup.new()
    local currentKey: Enum.KeyCode? = props.Default or Enum.KeyCode.E
    local mode = props.Mode or "Toggle"
    local disabled = props.Disabled or false
    local isListening = false
    local toggleState = false

    local container = Instance.new("Frame")
    container.Name = "Keybind_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 50 else 38)
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
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = card

    -- Text Stack
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -100, 1, 0)
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

    -- Key Button Chip
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.AutoButtonColor = false
    keyButton.Size = UDim2.fromOffset(80, 24)
    keyButton.Position = UDim2.new(1, -80, 0.5, -12)
    keyButton.BackgroundColor3 = Theme.Get("Surface")
    keyButton.BorderSizePixel = 0
    keyButton.Font = Theme.Get("FontMono")
    keyButton.TextSize = 11
    keyButton.TextColor3 = Theme.Get("Silver")
    keyButton.Text = if currentKey then currentKey.Name else "None"
    keyButton.Parent = card

    local kbCorner = Instance.new("UICorner")
    kbCorner.CornerRadius = UDim.new(0, 4)
    kbCorner.Parent = keyButton

    local kbStroke = Instance.new("UIStroke")
    kbStroke.Thickness = 1
    kbStroke.Color = Theme.Get("Border")
    kbStroke.Parent = keyButton

    local function updateKeyVisual()
        if isListening then
            keyButton.Text = "..."
            keyButton.TextColor3 = Theme.Get("Warning")
            kbStroke.Color = Theme.Get("Warning")
        else
            keyButton.Text = if currentKey then currentKey.Name else "None"
            keyButton.TextColor3 = Theme.Get("Silver")
            kbStroke.Color = Theme.Get("Border")
        end
    end

    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        keyButton.BackgroundColor3 = Theme.Get("Surface")
        updateKeyVisual()
    end))

    local listenCleanup: (() -> ())? = nil

    keyButton.MouseButton1Click:Connect(function()
        if disabled or isListening then return end
        isListening = true
        updateKeyVisual()

        listenCleanup = Input.ListenForNextKey(function(newKey, cancelled)
            isListening = false
            if not cancelled and newKey then
                currentKey = newKey
                if props.OnKeyChanged then
                    pcall(props.OnKeyChanged, currentKey)
                end
            elseif cancelled then
                -- escape pressed, keeps old or unbinds
            end
            updateKeyVisual()
        end)
    end)

    -- Global Key Listening
    cleanup:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or Input.IsTyping() or disabled or not currentKey then return end
        if input.KeyCode == currentKey then
            if mode == "Hold" then
                if props.Callback then
                    pcall(props.Callback, true)
                end
            else
                toggleState = not toggleState
                if props.Callback then
                    pcall(props.Callback, toggleState)
                end
            end
        end
    end))

    if mode == "Hold" then
        cleanup:Add(UserInputService.InputEnded:Connect(function(input)
            if not currentKey or disabled then return end
            if input.KeyCode == currentKey then
                if props.Callback then
                    pcall(props.Callback, false)
                end
            end
        end))
    end

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _keyButton = keyButton,
        _currentKey = currentKey,
        _disabled = disabled,
        _props = props,
    }, Keybind)

    return self
end

function Keybind:GetKey(): Enum.KeyCode?
    return self._currentKey
end

function Keybind:SetKey(key: Enum.KeyCode?, triggerCallback: boolean?)
    self._currentKey = key
    self._keyButton.Text = if key then key.Name else "None"
    if triggerCallback and self._props.OnKeyChanged then
        pcall(self._props.OnKeyChanged, key)
    end
end

function Keybind:SetDisabled(disabled: boolean)
    self._disabled = disabled
end

function Keybind:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Keybind:Destroy()
    self._cleanup:Destroy()
end

return Keybind
