--!strict
--[=[
    Silverline UI Framework
    Module: Core/Section.lua
    Purpose: Section container grouping related controls with optional collapsible accordion behavior.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

-- Component Imports
local Button = require(script.Parent.Parent.Components.Button)
local Toggle = require(script.Parent.Parent.Components.Toggle)
local Checkbox = require(script.Parent.Parent.Components.Checkbox)
local Slider = require(script.Parent.Parent.Components.Slider)
local RangeSlider = require(script.Parent.Parent.Components.RangeSlider)
local Dropdown = require(script.Parent.Parent.Components.Dropdown)
local InputComponent = require(script.Parent.Parent.Components.Input)
local Keybind = require(script.Parent.Parent.Components.Keybind)
local ColorPicker = require(script.Parent.Parent.Components.ColorPicker)
local PredictionPanel = require(script.Parent.Parent.Components.PredictionPanel)

local Section = {}
Section.__index = Section

export type SectionProps = {
    Name: string,
    Collapsible: boolean?,
    DefaultCollapsed: boolean?,
    Parent: GuiObject,
    OverlayContainer: GuiObject?,
}

function Section.new(props: SectionProps)
    local cleanup = Cleanup.new()
    local isCollapsible = props.Collapsible or false
    local isCollapsed = if isCollapsible and props.DefaultCollapsed ~= nil then props.DefaultCollapsed else false

    -- Container Frame
    local container = Instance.new("Frame")
    container.Name = "Section_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = props.Parent
    cleanup:Add(container)

    local mainLayout = Instance.new("UIListLayout")
    mainLayout.FillDirection = Enum.FillDirection.Vertical
    mainLayout.Padding = UDim.new(0, 8)
    mainLayout.Parent = container

    -- Header Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 24)
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, if isCollapsible then -30 else 0, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 12
    title.Text = string.upper(props.Name)
    title.TextColor3 = Theme.Get("Silver")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local collapseIcon: ImageLabel? = nil
    if isCollapsible then
        collapseIcon = Icons.Create({
            Name = "chevron-down",
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(1, -16, 0.5, -7),
            Color = Theme.Get("Silver"),
            Parent = header,
        })

        local headerBtn = Instance.new("TextButton")
        headerBtn.BackgroundTransparency = 1
        headerBtn.Text = ""
        headerBtn.Size = UDim2.new(1, 0, 1, 0)
        headerBtn.Parent = header

        headerBtn.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            if isCollapsed then
                Animation.Tween(collapseIcon :: ImageLabel, Animation.Presets.Fast, { Rotation = -90 })
            else
                Animation.Tween(collapseIcon :: ImageLabel, Animation.Presets.Fast, { Rotation = 0 })
            end
        end)
    end

    -- Content Canvas
    local contentCanvas = Instance.new("Frame")
    contentCanvas.Name = "ContentCanvas"
    contentCanvas.BackgroundTransparency = 1
    contentCanvas.Size = UDim2.new(1, 0, 0, 0)
    contentCanvas.AutomaticSize = Enum.AutomaticSize.Y
    contentCanvas.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = contentCanvas

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _contentCanvas = contentCanvas,
        _overlayContainer = props.OverlayContainer,
        _props = props,
    }, Section)

    return self
end

function Section:CreateButton(props: any): any
    props.Parent = self._contentCanvas
    local btn = Button.new(props)
    self._cleanup:Add(btn)
    return btn
end

function Section:CreateToggle(props: any): any
    props.Parent = self._contentCanvas
    local tog = Toggle.new(props)
    self._cleanup:Add(tog)
    return tog
end

function Section:CreateCheckbox(props: any): any
    props.Parent = self._contentCanvas
    local cb = Checkbox.new(props)
    self._cleanup:Add(cb)
    return cb
end

function Section:CreateSlider(props: any): any
    props.Parent = self._contentCanvas
    local sl = Slider.new(props)
    self._cleanup:Add(sl)
    return sl
end

function Section:CreateRangeSlider(props: any): any
    props.Parent = self._contentCanvas
    local rsl = RangeSlider.new(props)
    self._cleanup:Add(rsl)
    return rsl
end

function Section:CreateDropdown(props: any): any
    props.Parent = self._contentCanvas
    props.OverlayContainer = self._overlayContainer
    local dd = Dropdown.new(props)
    self._cleanup:Add(dd)
    return dd
end

function Section:CreateInput(props: any): any
    props.Parent = self._contentCanvas
    local inp = InputComponent.new(props)
    self._cleanup:Add(inp)
    return inp
end

function Section:CreateKeybind(props: any): any
    props.Parent = self._contentCanvas
    local kb = Keybind.new(props)
    self._cleanup:Add(kb)
    return kb
end

function Section:CreateColorPicker(props: any): any
    props.Parent = self._contentCanvas
    local cp = ColorPicker.new(props)
    self._cleanup:Add(cp)
    return cp
end

function Section:CreatePredictionPanel(props: any): any
    props.Parent = self._contentCanvas
    local pp = PredictionPanel.new(props)
    self._cleanup:Add(pp)
    return pp
end

function Section:CreateLabel(text: string, description: string?): TextLabel
    local frame = Instance.new("Frame")
    frame.Name = "LabelFrame"
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, if description then 34 else 20)
    frame.Parent = self._contentCanvas

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Name = "MainText"
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Font = Theme.Get("FontPrimary")
    lbl.TextSize = 12
    lbl.Text = text
    lbl.TextColor3 = Theme.Get("Highlight")
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    if description then
        local sub = Instance.new("TextLabel")
        sub.Name = "SubText"
        sub.BackgroundTransparency = 1
        sub.Size = UDim2.new(1, 0, 0, 14)
        sub.Font = Theme.Get("FontPrimary")
        sub.TextSize = 10
        sub.Text = description
        sub.TextColor3 = Theme.Get("TextMuted")
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = frame
    end

    self._cleanup:Add(frame)
    return lbl
end

function Section:CreateDivider(): Frame
    local div = Instance.new("Frame")
    div.Name = "Divider"
    div.Size = UDim2.new(1, 0, 0, 1)
    div.BackgroundColor3 = Theme.Get("Border")
    div.BorderSizePixel = 0
    div.Parent = self._contentCanvas

    self._cleanup:Add(div)
    return div
end

function Section:AddCustom(customInstance: Instance)
    customInstance.Parent = self._contentCanvas
    self._cleanup:Add(customInstance)
end

function Section:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Section:Destroy()
    self._cleanup:Destroy()
end

return Section
