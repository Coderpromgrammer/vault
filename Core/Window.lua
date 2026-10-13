--!strict
--[=[
    Silverline UI Framework
    Module: Core/Window.lua
    Purpose: Main framework window supporting sidebar navigation, viewport-clamped dragging,
             minimize/restore, floating reopen control, and modal/portal overlay.
]=]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Input = require(script.Parent.Parent.Systems.Input)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)
local Tab = require(script.Parent.Tab)
local Dialog = require(script.Parent.Parent.Components.Dialog)

local Window = {}
Window.__index = Window

export type WindowProps = {
    Title: string?,
    Subtitle: string?,
    Icon: string?,
    Size: UDim2?,
    Position: UDim2?,
    Layout: ("Sidebar" | "Compact" | "TopNav")?,
    ReopenKey: Enum.KeyCode?,
    ParentGui: ScreenGui?,
}

function Window.new(props: WindowProps)
    local cleanup = Cleanup.new()
    local currentTitle = props.Title or "SILVERLINE"
    local currentSubtitle = props.Subtitle or "Control Center"
    local windowSize = props.Size or UDim2.fromOffset(680, 440)
    local isMinimized = false
    local tabs: { any } = {}
    local selectedTab: any = nil

    -- Host ScreenGui
    local screenGui: ScreenGui
    if props.ParentGui then
        screenGui = props.ParentGui
    else
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "SilverlineUI"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- Parent safely
        local success, _ = pcall(function()
            screenGui.Parent = CoreGui
        end)
        if not success or not screenGui.Parent then
            local lp = Players.LocalPlayer
            if lp then
                screenGui.Parent = lp:WaitForChild("PlayerGui")
            end
        end
        cleanup:Add(screenGui)
    end

    -- Main Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = windowSize
    mainFrame.Position = props.Position or UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Theme.Get("Surface")
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    cleanup:Add(mainFrame)

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Thickness = 1
    mainStroke.Color = Theme.Get("Border")
    mainStroke.Parent = mainFrame

    -- Title Bar (Drag Handle)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Theme.Get("SurfaceElevated")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 8)
    tbCorner.Parent = titleBar

    -- Mask to square off bottom of title bar
    local tbBottomMask = Instance.new("Frame")
    tbBottomMask.Name = "BottomMask"
    tbBottomMask.Size = UDim2.new(1, 0, 0, 8)
    tbBottomMask.Position = UDim2.new(0, 0, 1, -8)
    tbBottomMask.BackgroundColor3 = Theme.Get("SurfaceElevated")
    tbBottomMask.BorderSizePixel = 0
    tbBottomMask.Parent = titleBar

    local tbBorderBottom = Instance.new("Frame")
    tbBorderBottom.Name = "BorderBottom"
    tbBorderBottom.Size = UDim2.new(1, 0, 0, 1)
    tbBorderBottom.Position = UDim2.new(0, 0, 1, 0)
    tbBorderBottom.BackgroundColor3 = Theme.Get("Border")
    tbBorderBottom.BorderSizePixel = 0
    tbBorderBottom.Parent = titleBar

    -- Brand Icon
    local brandIcon = Icons.Create({
        Name = props.Icon or "shield",
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0, 14, 0.5, -10),
        Color = Theme.Get("Silver"),
        Parent = titleBar,
    })

    -- Title & Subtitle Stack
    local titleStack = Instance.new("Frame")
    titleStack.Name = "TitleStack"
    titleStack.BackgroundTransparency = 1
    titleStack.Size = UDim2.new(1, -160, 1, 0)
    titleStack.Position = UDim2.new(0, 42, 0, 0)
    titleStack.Parent = titleBar

    local tsLayout = Instance.new("UIListLayout")
    tsLayout.FillDirection = Enum.FillDirection.Vertical
    tsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tsLayout.Padding = UDim.new(0, 1)
    tsLayout.Parent = titleStack

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.Font = Theme.Get("FontBold")
    titleLabel.TextSize = 13
    titleLabel.Text = currentTitle
    titleLabel.TextColor3 = Theme.Get("Highlight")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleStack

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Size = UDim2.new(1, 0, 0, 12)
    subtitleLabel.Font = Theme.Get("FontPrimary")
    subtitleLabel.TextSize = 10
    subtitleLabel.Text = currentSubtitle
    subtitleLabel.TextColor3 = Theme.Get("TextMuted")
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = titleStack

    -- Title Bar Action Buttons (Minimize, Close)
    local actionArea = Instance.new("Frame")
    actionArea.Name = "ActionArea"
    actionArea.BackgroundTransparency = 1
    actionArea.Size = UDim2.fromOffset(70, 44)
    actionArea.Position = UDim2.new(1, -74, 0, 0)
    actionArea.Parent = titleBar

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionLayout.Padding = UDim.new(0, 6)
    actionLayout.Parent = actionArea

    local function createActionButton(name: string, iconName: string): ImageButton
        local btn = Instance.new("ImageButton")
        btn.Name = name
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.fromOffset(26, 26)
        btn.Image = Icons.Get(iconName)
        btn.ImageColor3 = Theme.Get("Silver")
        btn.Parent = actionArea

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 0.8, BackgroundColor3 = Theme.Get("SurfaceHover") })
        end)
        btn.MouseLeave:Connect(function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 1 })
        end)
        return btn
    end

    local minBtn = createActionButton("MinBtn", "minus")
    local closeBtn = createActionButton("CloseBtn", "close")

    -- Make Window Draggable by TitleBar
    cleanup:Add(Input.MakeDraggable(mainFrame, titleBar, { ClampToScreen = true }))

    -- Content Body Area
    local bodyArea = Instance.new("Frame")
    bodyArea.Name = "BodyArea"
    bodyArea.BackgroundTransparency = 1
    bodyArea.Size = UDim2.new(1, 0, 1, -45)
    bodyArea.Position = UDim2.new(0, 0, 0, 45)
    bodyArea.Parent = mainFrame

    -- Navigation Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Theme.Get("SurfaceElevated")
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(0, 170, 1, 0)
    sidebar.Parent = bodyArea

    local sbMask = Instance.new("Frame")
    sbMask.Name = "BottomLeftMask"
    sbMask.Size = UDim2.fromOffset(8, 8)
    sbMask.Position = UDim2.new(0, 0, 1, -8)
    sbMask.BackgroundColor3 = Theme.Get("SurfaceElevated")
    sbMask.BorderSizePixel = 0
    sbMask.Parent = sidebar

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 8)
    sbCorner.Parent = sidebar

    local sbDivider = Instance.new("Frame")
    sbDivider.Name = "SidebarDivider"
    sbDivider.Size = UDim2.new(0, 1, 1, 0)
    sbDivider.Position = UDim2.new(1, 0, 0, 0)
    sbDivider.BackgroundColor3 = Theme.Get("Border")
    sbDivider.BorderSizePixel = 0
    sbDivider.Parent = sidebar

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Name = "NavScroll"
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.Size = UDim2.new(1, 0, 1, 0)
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = Theme.Get("Border")
    navScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    navScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 8)
    navPad.PaddingRight = UDim.new(0, 8)
    navPad.PaddingTop = UDim.new(0, 10)
    navPad.PaddingBottom = UDim.new(0, 10)
    navPad.Parent = navScroll

    -- Main Content Area (Pages container)
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, -171, 1, 0)
    pageContainer.Position = UDim2.new(0, 171, 0, 0)
    pageContainer.Parent = bodyArea

    -- Portal Overlay Layer
    local overlayContainer = Instance.new("Frame")
    overlayContainer.Name = "OverlayContainer"
    overlayContainer.BackgroundTransparency = 1
    overlayContainer.Size = UDim2.new(1, 0, 1, 0)
    overlayContainer.ZIndex = 150
    overlayContainer.Parent = mainFrame

    -- Floating Reopen Button (Visible when minimized)
    local reopenBadge = Instance.new("TextButton")
    reopenBadge.Name = "Silverline_ReopenBadge"
    reopenBadge.Text = ""
    reopenBadge.AutoButtonColor = false
    reopenBadge.Size = UDim2.fromOffset(40, 40)
    reopenBadge.Position = UDim2.new(0, 20, 0.5, -20)
    reopenBadge.BackgroundColor3 = Theme.Get("SurfaceElevated")
    reopenBadge.BorderSizePixel = 0
    reopenBadge.Visible = false
    reopenBadge.ZIndex = 250
    reopenBadge.Parent = screenGui
    cleanup:Add(reopenBadge)

    local rbCorner = Instance.new("UICorner")
    rbCorner.CornerRadius = UDim.new(0, 8)
    rbCorner.Parent = reopenBadge

    local rbStroke = Instance.new("UIStroke")
    rbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rbStroke.Thickness = 1
    rbStroke.Color = Theme.Get("BorderHighlight")
    rbStroke.Parent = reopenBadge

    local rbIcon = Icons.Create({
        Name = props.Icon or "shield",
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        Color = Theme.Get("Silver"),
        Parent = reopenBadge,
    })

    -- Draggable Reopen Badge
    cleanup:Add(Input.MakeDraggable(reopenBadge, reopenBadge, { ClampToScreen = true }))

    local function restoreWindow()
        isMinimized = false
        reopenBadge.Visible = false
        mainFrame.Visible = true
        Animation.Tween(mainFrame, Animation.Presets.Window, { Size = windowSize })
    end

    local function minimizeWindow()
        isMinimized = true
        Animation.Tween(mainFrame, Animation.Presets.Window, { Size = UDim2.new(0, windowSize.X.Offset, 0, 44) }, function()
            mainFrame.Visible = false
            reopenBadge.Visible = true
        end)
    end

    minBtn.MouseButton1Click:Connect(minimizeWindow)
    reopenBadge.MouseButton1Click:Connect(restoreWindow)

    closeBtn.MouseButton1Click:Connect(function()
        Dialog.Show({
            Title = "Close Interface",
            Message = "Are you sure you want to close the Silverline panel?",
            Danger = true,
            ConfirmText = "Close",
            Parent = overlayContainer,
            OnConfirm = function()
                mainFrame.Visible = false
                reopenBadge.Visible = true
            end,
        })
    end)

    -- Entrance Animation
    mainFrame.Size = UDim2.new(0, windowSize.X.Offset * 0.95, 0, windowSize.Y.Offset * 0.95)
    Animation.Tween(mainFrame, Animation.Presets.Window, { Size = windowSize })

    local self = setmetatable({
        _cleanup = cleanup,
        _screenGui = screenGui,
        _mainFrame = mainFrame,
        _titleLabel = titleLabel,
        _subtitleLabel = subtitleLabel,
        _navScroll = navScroll,
        _pageContainer = pageContainer,
        _overlayContainer = overlayContainer,
        _reopenBadge = reopenBadge,
        _tabs = tabs,
        _selectedTab = selectedTab,
        _restoreWindow = restoreWindow,
        _minimizeWindow = minimizeWindow,
        _props = props,
    }, Window)

    return self
end

function Window:CreateTab(props: any): any
    props.NavContainer = self._navScroll
    props.PageContainer = self._pageContainer
    props.OverlayContainer = self._overlayContainer
    props.OnSelected = function(tabInstance)
        self:SelectTab(tabInstance)
    end

    local tab = Tab.new(props)
    table.insert(self._tabs, tab)

    if #self._tabs == 1 then
        self:SelectTab(tab)
    end

    self._cleanup:Add(tab)
    return tab
end

function Window:SelectTab(tab: any)
    for _, t in ipairs(self._tabs) do
        if t == tab then
            t:Select()
        else
            t:Deselect()
        end
    end
    self._selectedTab = tab
end

function Window:Minimize()
    self._minimizeWindow()
end

function Window:Restore()
    self._restoreWindow()
end

function Window:SetTitle(title: string, subtitle: string?)
    self._titleLabel.Text = title
    if subtitle then
        self._subtitleLabel.Text = subtitle
    end
end

function Window:SetTheme(themeName: string)
    Theme.SetTheme(themeName)
end

function Window:Destroy()
    self._cleanup:Destroy()
end

return Window
