--!strict
--[=[
    Silverline UI Framework
    Module: Components/Dropdown.lua
    Purpose: Single and multi-select dropdown with search filter, clipping-safe popover, and outside-click dismissal.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Dropdown = {}
Dropdown.__index = Dropdown

export type DropdownProps = {
    Name: string,
    Description: string?,
    Options: { string },
    Default: (string | { string })?,
    Multi: boolean?,
    Searchable: boolean?,
    Disabled: boolean?,
    Parent: GuiObject,
    OverlayContainer: GuiObject?,
    Callback: ((selected: any) -> ())?,
}

function Dropdown.new(props: DropdownProps)
    local cleanup = Cleanup.new()
    local isMulti = props.Multi or false
    local options = props.Options or {}
    local disabled = props.Disabled or false
    local isOpen = false

    local selectedMap: { [string]: boolean } = {}
    if isMulti then
        if type(props.Default) == "table" then
            for _, item in ipairs(props.Default :: { string }) do
                selectedMap[item] = true
            end
        end
    else
        if type(props.Default) == "string" then
            selectedMap[props.Default :: string] = true
        elseif #options > 0 then
            selectedMap[options[1]] = true
        end
    end

    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. props.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 56 else 44)
    container.Parent = props.Parent
    cleanup:Add(container)

    -- Card Button
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
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = card

    -- Text Stack
    local textStack = Instance.new("Frame")
    textStack.Name = "TextStack"
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -150, 1, 0)
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

    -- Selection Chip Button
    local chip = Instance.new("Frame")
    chip.Name = "Chip"
    chip.Size = UDim2.fromOffset(130, 26)
    chip.Position = UDim2.new(1, -130, 0.5, -13)
    chip.BackgroundColor3 = Theme.Get("Surface")
    chip.BorderSizePixel = 0
    chip.Parent = card

    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(0, 4)
    chipCorner.Parent = chip

    local chipStroke = Instance.new("UIStroke")
    chipStroke.Thickness = 1
    chipStroke.Color = Theme.Get("Border")
    chipStroke.Parent = chip

    local chipText = Instance.new("TextLabel")
    chipText.Name = "ChipText"
    chipText.BackgroundTransparency = 1
    chipText.Size = UDim2.new(1, -28, 1, 0)
    chipText.Position = UDim2.new(0, 8, 0, 0)
    chipText.Font = Theme.Get("FontPrimary")
    chipText.TextSize = 11
    chipText.TextColor3 = Theme.Get("Silver")
    chipText.TextXAlignment = Enum.TextXAlignment.Left
    chipText.ClipsDescendants = true
    chipText.Parent = chip

    local chevron = Icons.Create({
        Name = "chevron-down",
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(1, -20, 0.5, -7),
        Color = Theme.Get("Silver"),
        Parent = chip,
    })

    local function getDisplayString(): string
        local items = {}
        for opt, active in pairs(selectedMap) do
            if active then table.insert(items, opt) end
        end
        if #items == 0 then
            return "Select..."
        elseif isMulti then
            return table.concat(items, ", ")
        else
            return items[1]
        end
    end

    local function updateChipText()
        chipText.Text = getDisplayString()
    end
    updateChipText()

    -- Popover Layer (Spawns on overlay container or main window)
    local overlayParent = props.OverlayContainer or card
    local popover = Instance.new("Frame")
    popover.Name = "Popover_" .. props.Name
    popover.Size = UDim2.fromOffset(160, 160)
    popover.BackgroundColor3 = Theme.Get("SurfaceElevated")
    popover.BorderSizePixel = 0
    popover.Visible = false
    popover.ZIndex = 50
    popover.Parent = overlayParent
    cleanup:Add(popover)

    local popCorner = Instance.new("UICorner")
    popCorner.CornerRadius = UDim.new(0, 6)
    popCorner.Parent = popover

    local popStroke = Instance.new("UIStroke")
    popStroke.Thickness = 1
    popStroke.Color = Theme.Get("BorderHighlight")
    popStroke.Parent = popover

    -- Search Box inside popover
    local searchBox: TextBox? = nil
    if props.Searchable ~= false then
        searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Size = UDim2.new(1, -12, 0, 24)
        searchBox.Position = UDim2.new(0, 6, 0, 6)
        searchBox.BackgroundColor3 = Theme.Get("Surface")
        searchBox.BorderSizePixel = 0
        searchBox.PlaceholderText = "Search options..."
        searchBox.PlaceholderColor3 = Theme.Get("TextDisabled")
        searchBox.Font = Theme.Get("FontPrimary")
        searchBox.TextSize = 11
        searchBox.TextColor3 = Theme.Get("Highlight")
        searchBox.ClearTextOnFocus = false
        searchBox.ZIndex = 51
        searchBox.Parent = popover

        local sbCorner = Instance.new("UICorner")
        sbCorner.CornerRadius = UDim.new(0, 4)
        sbCorner.Parent = searchBox

        local sbStroke = Instance.new("UIStroke")
        sbStroke.Thickness = 1
        sbStroke.Color = Theme.Get("Border")
        sbStroke.Parent = searchBox
    end

    -- Scrollable Options List
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Get("Border")
    scroll.Size = UDim2.new(1, -12, 1, if searchBox then -38 else -12)
    scroll.Position = UDim2.new(0, 6, 0, if searchBox then 34 else 6)
    scroll.ZIndex = 51
    scroll.Parent = popover

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scroll

    local optionButtons: { [string]: TextButton } = {}

    local function refreshOptionsList(filterText: string?)
        for _, btn in pairs(optionButtons) do
            btn:Destroy()
        end
        table.clear(optionButtons)

        local query = string.lower(filterText or "")
        local visibleCount = 0

        for _, opt in ipairs(options) do
            if query == "" or string.find(string.lower(opt), query, 1, true) then
                visibleCount += 1
                local isSelected = selectedMap[opt] == true

                local optBtn = Instance.new("TextButton")
                optBtn.Name = "Opt_" .. opt
                optBtn.Size = UDim2.new(1, 0, 0, 24)
                optBtn.BackgroundColor3 = if isSelected then Theme.Get("SurfaceActive") else Color3.fromRGB(0,0,0)
                optBtn.BackgroundTransparency = if isSelected then 0 else 1
                optBtn.Text = "  " .. opt
                optBtn.Font = Theme.Get("FontPrimary")
                optBtn.TextSize = 11
                optBtn.TextColor3 = if isSelected then Theme.Get("Highlight") else Theme.Get("Silver")
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.AutoButtonColor = false
                optBtn.ZIndex = 52
                optBtn.Parent = scroll

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseEnter:Connect(function()
                    if not selectedMap[opt] then
                        optBtn.BackgroundTransparency = 0.5
                        optBtn.BackgroundColor3 = Theme.Get("SurfaceHover")
                    end
                end)
                optBtn.MouseLeave:Connect(function()
                    if not selectedMap[opt] then
                        optBtn.BackgroundTransparency = 1
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    if isMulti then
                        selectedMap[opt] = not selectedMap[opt]
                    else
                        table.clear(selectedMap)
                        selectedMap[opt] = true
                        -- close popover
                        isOpen = false
                        popover.Visible = false
                        Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
                    end
                    updateChipText()
                    refreshOptionsList(searchBox and searchBox.Text or "")

                    if props.Callback then
                        local selectedItems = {}
                        for k, v in pairs(selectedMap) do
                            if v then table.insert(selectedItems, k) end
                        end
                        pcall(props.Callback, if isMulti then selectedItems else selectedItems[1])
                    end
                end)

                optionButtons[opt] = optBtn
            end
        end

        scroll.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 26)
    end

    if searchBox then
        cleanup:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            refreshOptionsList(searchBox.Text)
        end))
    end

    local function togglePopover()
        if disabled then return end
        isOpen = not isOpen

        if isOpen then
            -- Position popover right under the chip
            if props.OverlayContainer then
                local chipAbs = chip.AbsolutePosition
                local overlayAbs = props.OverlayContainer.AbsolutePosition
                popover.Position = UDim2.fromOffset(chipAbs.X - overlayAbs.X + chip.AbsoluteSize.X - 160, chipAbs.Y - overlayAbs.Y + chip.AbsoluteSize.Y + 4)
            else
                popover.Position = UDim2.new(1, -160, 1, 4)
            end

            popover.Visible = true
            refreshOptionsList("")
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 180 })
        else
            popover.Visible = false
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
        end
    end

    cleanup:Add(card.MouseButton1Click:Connect(togglePopover))

    -- Outside click listener
    cleanup:Add(UserInputService.InputBegan:Connect(function(input)
        if not isOpen then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = input.Position
            local popX, popY = popover.AbsolutePosition.X, popover.AbsolutePosition.Y
            local popW, popH = popover.AbsoluteSize.X, popover.AbsoluteSize.Y
            local chipX, chipY = chip.AbsolutePosition.X, chip.AbsolutePosition.Y
            local chipW, chipH = chip.AbsoluteSize.X, chip.AbsoluteSize.Y

            local inPopover = (mousePos.X >= popX and mousePos.X <= popX + popW and mousePos.Y >= popY and mousePos.Y <= popY + popH)
            local inChip = (mousePos.X >= chipX and mousePos.X <= chipX + chipW and mousePos.Y >= chipY and mousePos.Y <= chipY + chipH)

            if not inPopover and not inChip then
                isOpen = false
                popover.Visible = false
                Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
            end
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _container = container,
        _selectedMap = selectedMap,
        _options = options,
        _isMulti = isMulti,
        _disabled = disabled,
        _updateChipText = updateChipText,
        _refreshOptionsList = refreshOptionsList,
        _props = props,
    }, Dropdown)

    return self
end

function Dropdown:GetSelected(): any
    local items = {}
    for k, v in pairs(self._selectedMap) do
        if v then table.insert(items, k) end
    end
    return if self._isMulti then items else items[1]
end

function Dropdown:SetSelected(itemOrItems: any, triggerCallback: boolean?)
    table.clear(self._selectedMap)
    if self._isMulti and type(itemOrItems) == "table" then
        for _, it in ipairs(itemOrItems) do
            self._selectedMap[it] = true
        end
    elseif type(itemOrItems) == "string" then
        self._selectedMap[itemOrItems] = true
    end
    self._updateChipText()

    if triggerCallback and self._props.Callback then
        pcall(self._props.Callback, self:GetSelected())
    end
end

function Dropdown:SetOptions(newOptions: { string })
    self._options = newOptions
    self._refreshOptionsList("")
    self._updateChipText()
end

function Dropdown:SetDisabled(disabled: boolean)
    self._disabled = disabled
end

function Dropdown:SetVisible(visible: boolean)
    self._container.Visible = visible
end

function Dropdown:Destroy()
    self._cleanup:Destroy()
end

return Dropdown
