--!strict
--[=[
    Silverline UI Framework
    Module: Components/Button.lua
    Purpose: Premium interactive button with variants (Primary, Secondary, Subtle, Danger),
             loading state, confirmation mode, and micro-motion feedback.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Button = {}
Button.__index = Button

export type ButtonProps = {
    Name: string,
    Description: string?,
    Icon: string?,
    Variant: ("Primary" | "Secondary" | "Subtle" | "Danger")?,
    Confirm: boolean?,
    ConfirmText: string?,
    Disabled: boolean?,
    Parent: GuiObject,
    Callback: (() -> ())?,
}

function Button.new(props: ButtonProps)
    local cleanup = Cleanup.new()
    local variant = props.Variant or "Secondary"
    local disabled = props.Disabled or false
    local isLoading = false
    local isAwaitingConfirm = false

    -- Container Frame
    local container = Instance.new("Frame")
    container.Name = "Button_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 48 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    -- Interactive Button Frame
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Text = ""
    buttonFrame.AutoButtonColor = false
    buttonFrame.Size = UDim2.new(1, 0, 1, 0)
    buttonFrame.BackgroundColor3 = Theme.Get("SurfaceElevated")
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = buttonFrame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("Border")
    stroke.Parent = buttonFrame

    -- Padding
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = buttonFrame

    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 10)
    layout.Parent = buttonFrame

    -- Icon
    local iconLabel: ImageLabel? = nil
    if props.Icon then
        iconLabel = Icons.Create({
            Name = props.Icon,
            Size = UDim2.fromOffset(16, 16),
            Color = Theme.Get("Silver"),
            Parent = buttonFrame,
        })
    end

    -- Text Stack
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, if props.Icon then -28 else 0, 1, 0)
    textStack.Parent = buttonFrame

    local stackLayout = Instance.new("UIListLayout")
    stackLayout.FillDirection = Enum.FillDirection.Vertical
    stackLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    stackLayout.Padding = UDim.new(0, 2)
    stackLayout.Parent = textStack

    -- Title Label
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

    -- Optional Description
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

    -- Styling by Variant
    local function getVariantColors()
        if disabled then
            return {
                Bg = Theme.Get("SurfaceElevated"),
                Text = Theme.Get("TextDisabled"),
                Stroke = Theme.Get("Border"),
                Icon = Theme.Get("TextDisabled"),
            }
        elseif variant == "Primary" then
            return {
                Bg = Theme.Get("Silver"),
                Text = Color3.fromRGB(16, 18, 22),
                Stroke = Theme.Get("Highlight"),
                Icon = Color3.fromRGB(16, 18, 22),
            }
        elseif variant == "Danger" then
            return {
                Bg = Color3.fromRGB(48, 22, 25),
                Text = Theme.Get("Error"),
                Stroke = Theme.Get("Error"),
                Icon = Theme.Get("Error"),
            }
        elseif variant == "Subtle" then
            return {
                Bg = Color3.fromRGB(0, 0, 0),
                BgTransparency = 1,
                Text = Theme.Get("Silver"),
                Stroke = Color3.fromRGB(0, 0, 0),
                StrokeTransparency = 1,
                Icon = Theme.Get("Silver"),
            }
        else -- Secondary (Default)
            return {
                Bg = Theme.Get("SurfaceElevated"),
                Text = Theme.Get("Highlight"),
                Stroke = Theme.Get("Border"),
                Icon = Theme.Get("Silver"),
            }
        end
    end

    local function applyStyle()
        local colors = getVariantColors()
        buttonFrame.BackgroundColor3 = colors.Bg
        if colors.BgTransparency then
            buttonFrame.BackgroundTransparency = colors.BgTransparency
        else
            buttonFrame.BackgroundTransparency = 0
        end

        stroke.Color = colors.Stroke
        if colors.StrokeTransparency then
            stroke.Transparency = colors.StrokeTransparency
        else
            stroke.Transparency = 0
        end

        titleLabel.TextColor3 = colors.Text
        if iconLabel then
            iconLabel.ImageColor3 = colors.Icon
        end
    end

    applyStyle()

    -- Theme Binding
    cleanup:Add(Theme.OnThemeChanged(function()
        applyStyle()
    end))

    -- Hover and Press Interactions
    local isHovered = false
    cleanup:Add(buttonFrame.MouseEnter:Connect(function()
        if disabled or isLoading then return end
        isHovered = true
        if variant == "Primary" then
            Animation.Tween(buttonFrame, Animation.Presets.Fast, { BackgroundColor3 = Theme.Get("Highlight") })
        elseif variant == "Secondary" then
            Animation.Tween(buttonFrame, Animation.Presets.Fast, { BackgroundColor3 = Theme.Get("SurfaceHover") })
            Animation.Tween(stroke, Animation.Presets.Fast, { Color = Theme.Get("BorderHighlight") })
        elseif variant == "Subtle" then
            Animation.Tween(buttonFrame, Animation.Presets.Fast, { BackgroundTransparency = 0.85, BackgroundColor3 = Theme.Get("SurfaceElevated") })
        end
    end))

    cleanup:Add(buttonFrame.MouseLeave:Connect(function()
        if disabled or isLoading then return end
        isHovered = false
        applyStyle()
    end))

    cleanup:Add(buttonFrame.MouseButton1Down:Connect(function()
        if disabled or isLoading then return end
        Animation.Tween(buttonFrame, Animation.Presets.ButtonPress, { Size = UDim2.new(1, -2, 1, -2) })
    end))

    local function resetConfirmState()
        isAwaitingConfirm = false
        titleLabel.Text = props.Name
        applyStyle()
    end

    cleanup:Add(buttonFrame.MouseButton1Up:Connect(function()
        if disabled or isLoading then return end
        Animation.Tween(buttonFrame, Animation.Presets.ButtonPress, { Size = UDim2.new(1, 0, 1, 0) })

        -- Confirmation check
        if props.Confirm and not isAwaitingConfirm then
            isAwaitingConfirm = true
            titleLabel.Text = props.ConfirmText or "Click again to confirm"
            titleLabel.TextColor3 = Theme.Get("Warning")
            task.delay(3, function()
                if isAwaitingConfirm then
                    resetConfirmState()
                end
            end)
            return
        end

        if isAwaitingConfirm then
            resetConfirmState()
        end

        if props.Callback then
            local success, err = pcall(props.Callback)
            if not success then
                warn("[Silverline Button] Callback error: " .. tostring(err))
            end
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _titleLabel = titleLabel,
        _descLabel = descLabel,
        _iconLabel = iconLabel,
        _buttonFrame = buttonFrame,
        _disabled = disabled,
        _isLoading = isLoading,
        _props = props,
    }, Button)

    return self
end

function Button:SetText(text: string)
    self._titleLabel.Text = text
end

function Button:SetDescription(desc: string)
    if self._descLabel then
        self._descLabel.Text = desc
    end
end

function Button:SetDisabled(disabled: boolean)
    self._disabled = disabled
    if disabled then
        self._buttonFrame.AutoButtonColor = false
        self._titleLabel.TextColor3 = Theme.Get("TextDisabled")
    else
        self._titleLabel.TextColor3 = Theme.Get("Highlight")
    end
end

function Button:SetLoading(loading: boolean)
    self._isLoading = loading
    if loading then
        self._titleLabel.Text = "Please wait..."
        if self._iconLabel then
            self._iconLabel.Image = Icons.Get("loader")
        end
    else
        self._titleLabel.Text = self._props.Name
        if self._iconLabel and self._props.Icon then
            self._iconLabel.Image = Icons.Get(self._props.Icon)
        end
    end
end

function Button:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Button:Destroy()
    self._cleanup:Destroy()
end

return Button
