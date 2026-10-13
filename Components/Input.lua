--!strict
--[=[
    Silverline UI Framework
    Module: Components/Input.lua
    Purpose: Textbox component supporting placeholder, numeric validation, max length, clear button, and error states.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local InputComponent = {}
InputComponent.__index = InputComponent

export type InputProps = {
    Name: string,
    Description: string?,
    Placeholder: string?,
    Default: string?,
    NumericOnly: boolean?,
    MaxLength: number?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: ((text: string) -> ())?,
    OnChanged: ((text: string) -> ())?,
}

function InputComponent.new(props: InputProps)
    local cleanup = Cleanup.new()
    local disabled = props.Disabled or false
    local currentText = props.Default or ""

    local container = Instance.new("Frame")
    container.Name = "Input_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 56 else 44)
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

    -- Text Stack (Left)
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -160, 1, 0)
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

    -- Input Box Container (Right)
    local boxContainer = Instance.new("Frame")
    boxContainer.Name = "BoxContainer"
    boxContainer.Size = UDim2.fromOffset(145, 28)
    boxContainer.Position = UDim2.new(1, -145, 0.5, -14)
    boxContainer.BackgroundColor3 = Theme.Get("Surface")
    boxContainer.BorderSizePixel = 0
    boxContainer.Parent = card

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = boxContainer

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.Color = Theme.Get("Border")
    boxStroke.Parent = boxContainer

    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -28, 1, 0)
    textBox.Position = UDim2.new(0, 8, 0, 0)
    textBox.Font = Theme.Get("FontPrimary")
    textBox.TextSize = 12
    textBox.TextColor3 = Theme.Get("Highlight")
    textBox.PlaceholderText = props.Placeholder or "Enter value..."
    textBox.PlaceholderColor3 = Theme.Get("TextDisabled")
    textBox.Text = currentText
    textBox.ClearTextOnFocus = false
    textBox.ClipsDescendants = true
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = boxContainer

    -- Clear button icon
    local clearBtn = Instance.new("ImageButton")
    clearBtn.Name = "ClearButton"
    clearBtn.BackgroundTransparency = 1
    clearBtn.Size = UDim2.fromOffset(14, 14)
    clearBtn.Position = UDim2.new(1, -20, 0.5, -7)
    clearBtn.Image = Icons.Get("close")
    clearBtn.ImageColor3 = Theme.Get("TextMuted")
    clearBtn.Visible = currentText ~= ""
    clearBtn.Parent = boxContainer

    local function sanitize(str: string): string
        if props.NumericOnly then
            str = string.gsub(str, "[^0-9%.%-]", "")
        end
        if props.MaxLength and #str > props.MaxLength then
            str = string.sub(str, 1, props.MaxLength)
        end
        return str
    end

    cleanup:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local sanitized = sanitize(textBox.Text)
        if textBox.Text ~= sanitized then
            textBox.Text = sanitized
        end
        currentText = sanitized
        clearBtn.Visible = (currentText ~= "")

        if props.OnChanged then
            pcall(props.OnChanged, currentText)
        end
    end))

    cleanup:Add(textBox.Focused:Connect(function()
        Animation.Tween(boxStroke, Animation.Presets.Fast, { Color = Theme.Get("BorderHighlight") })
    end))

    cleanup:Add(textBox.FocusLost:Connect(function(enterPressed)
        Animation.Tween(boxStroke, Animation.Presets.Fast, { Color = Theme.Get("Border") })
        if props.Callback then
            pcall(props.Callback, currentText)
        end
    end))

    cleanup:Add(clearBtn.MouseButton1Click:Connect(function()
        if disabled then return end
        textBox.Text = ""
        currentText = ""
        clearBtn.Visible = false
        if props.Callback then
            pcall(props.Callback, "")
        end
    end))

    cleanup:Add(Theme.OnThemeChanged(function()
        card.BackgroundColor3 = Theme.Get("SurfaceElevated")
        stroke.Color = Theme.Get("Border")
        titleLabel.TextColor3 = if disabled then Theme.Get("TextDisabled") else Theme.Get("Highlight")
        boxContainer.BackgroundColor3 = Theme.Get("Surface")
        boxStroke.Color = Theme.Get("Border")
        textBox.TextColor3 = Theme.Get("Highlight")
        textBox.PlaceholderColor3 = Theme.Get("TextDisabled")
        clearBtn.ImageColor3 = Theme.Get("TextMuted")
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _textBox = textBox,
        _disabled = disabled,
        _props = props,
    }, InputComponent)

    return self
end

function InputComponent:GetText(): string
    return self._textBox.Text
end

function InputComponent:SetText(text: string, triggerCallback: boolean?)
    self._textBox.Text = text
    if triggerCallback and self._props.Callback then
        pcall(self._props.Callback, text)
    end
end

function InputComponent:SetDisabled(disabled: boolean)
    self._disabled = disabled
    self._textBox.TextEditable = not disabled
end

function InputComponent:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function InputComponent:Destroy()
    self._cleanup:Destroy()
end

return InputComponent
