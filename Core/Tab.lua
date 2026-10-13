--!strict
--[=[
    Silverline UI Framework
    Module: Core/Tab.lua
    Purpose: Tab page and navigation item manager with smooth switching and badge notifications.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)
local Section = require(script.Parent.Section)

local Tab = {}
Tab.__index = Tab

export type TabProps = {
    Name: string,
    Icon: string?,
    Badge: string?,
    NavContainer: GuiObject,
    PageContainer: GuiObject,
    OverlayContainer: GuiObject?,
    OnSelected: ((tab: any) -> ())?,
}

function Tab.new(props: TabProps)
    local cleanup = Cleanup.new()
    local isSelected = false

    -- Navigation Item Button
    local navBtn = Instance.new("TextButton")
    navBtn.Name = "NavTab_" .. props.Name
    navBtn.Text = ""
    navBtn.AutoButtonColor = false
    navBtn.Size = UDim2.new(1, 0, 0, 34)
    navBtn.BackgroundColor3 = Theme.Get("Surface")
    navBtn.BackgroundTransparency = 1
    navBtn.BorderSizePixel = 0
    navBtn.Parent = props.NavContainer
    cleanup:Add(navBtn)

    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, 6)
    navCorner.Parent = navBtn

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)
    navPad.Parent = navBtn

    local navLayout = Instance.new("UIListLayout")
    navLayout.FillDirection = Enum.FillDirection.Horizontal
    navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    navLayout.Padding = UDim.new(0, 8)
    navLayout.Parent = navBtn

    -- Tab Icon
    local iconLabel: ImageLabel? = nil
    if props.Icon then
        iconLabel = Icons.Create({
            Name = props.Icon,
            Size = UDim2.fromOffset(16, 16),
            Color = Theme.Get("TextMuted"),
            Parent = navBtn,
        })
    end

    -- Tab Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, if props.Icon then -60 else -30, 1, 0)
    titleLabel.Font = Theme.Get("FontPrimary")
    titleLabel.TextSize = 12
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Theme.Get("TextMuted")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ClipsDescendants = true
    titleLabel.Parent = navBtn

    -- Optional Badge
    local badgeLabel: TextLabel? = nil
    if props.Badge then
        badgeLabel = Instance.new("TextLabel")
        badgeLabel.Name = "Badge"
        badgeLabel.BackgroundColor3 = Theme.Get("SurfaceElevated")
        badgeLabel.Size = UDim2.fromOffset(20, 16)
        badgeLabel.Font = Theme.Get("FontMono")
        badgeLabel.TextSize = 9
        badgeLabel.TextColor3 = Theme.Get("Silver")
        badgeLabel.Text = props.Badge
        badgeLabel.Parent = navBtn

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = badgeLabel
    end

    -- Active Indicator Pill (Left Accent Edge)
    local activePill = Instance.new("Frame")
    activePill.Name = "ActivePill"
    activePill.Size = UDim2.fromOffset(3, 16)
    activePill.Position = UDim2.new(0, -6, 0.5, -8)
    activePill.BackgroundColor3 = Theme.Get("Silver")
    activePill.BorderSizePixel = 0
    activePill.Visible = false
    activePill.Parent = navBtn

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = activePill

    -- Page Canvas (ScrollingFrame)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. props.Name
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1, 0, 1, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Get("Border")
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = props.PageContainer
    cleanup:Add(page)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.Padding = UDim.new(0, 14)
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingLeft = UDim.new(0, 14)
    pagePad.PaddingRight = UDim.new(0, 14)
    pagePad.PaddingTop = UDim.new(0, 14)
    pagePad.PaddingBottom = UDim.new(0, 14)
    pagePad.Parent = page

    local function updateVisuals()
        if isSelected then
            Animation.Tween(navBtn, Animation.Presets.Tab, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Get("SurfaceElevated") })
            Animation.Tween(titleLabel, Animation.Presets.Tab, { TextColor3 = Theme.Get("Highlight") })
            if iconLabel then
                Animation.Tween(iconLabel, Animation.Presets.Tab, { ImageColor3 = Theme.Get("Highlight") })
            end
            activePill.Visible = true
            page.Visible = true
        else
            Animation.Tween(navBtn, Animation.Presets.Tab, { BackgroundTransparency = 1 })
            Animation.Tween(titleLabel, Animation.Presets.Tab, { TextColor3 = Theme.Get("TextMuted") })
            if iconLabel then
                Animation.Tween(iconLabel, Animation.Presets.Tab, { ImageColor3 = Theme.Get("TextMuted") })
            end
            activePill.Visible = false
            page.Visible = false
        end
    end

    cleanup:Add(navBtn.MouseEnter:Connect(function()
        if not isSelected then
            Animation.Tween(navBtn, Animation.Presets.Fast, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Get("SurfaceHover") })
            Animation.Tween(titleLabel, Animation.Presets.Fast, { TextColor3 = Theme.Get("Silver") })
        end
    end))

    cleanup:Add(navBtn.MouseLeave:Connect(function()
        if not isSelected then
            Animation.Tween(navBtn, Animation.Presets.Fast, { BackgroundTransparency = 1 })
            Animation.Tween(titleLabel, Animation.Presets.Fast, { TextColor3 = Theme.Get("TextMuted") })
        end
    end))

    local self = setmetatable({
        _cleanup = cleanup,
        _navBtn = navBtn,
        _page = page,
        _badgeLabel = badgeLabel,
        _isSelected = isSelected,
        _updateVisuals = updateVisuals,
        _overlayContainer = props.OverlayContainer,
        _props = props,
    }, Tab)

    cleanup:Add(navBtn.MouseButton1Click:Connect(function()
        if props.OnSelected then
            props.OnSelected(self)
        else
            self:Select()
        end
    end))

    return self
end

function Tab:Select()
    self._isSelected = true
    self._updateVisuals()
end

function Tab:Deselect()
    self._isSelected = false
    self._updateVisuals()
end

function Tab:CreateSection(props: any): any
    props.Parent = self._page
    props.OverlayContainer = self._overlayContainer
    local sec = Section.new(props)
    self._cleanup:Add(sec)
    return sec
end

function Tab:SetBadge(text: string?)
    if self._badgeLabel then
        self._badgeLabel.Text = text or ""
        self._badgeLabel.Visible = (text ~= nil and text ~= "")
    end
end

function Tab:Destroy()
    self._cleanup:Destroy()
end

return Tab
