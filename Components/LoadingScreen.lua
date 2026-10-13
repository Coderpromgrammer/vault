--!strict
--[=[
    Silverline UI Framework
    Module: Components/LoadingScreen.lua
    Purpose: Splash and loading screen with determinate/indeterminate progress, stages, and transition into main UI.
]=]

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

export type LoadingProps = {
    Title: string?,
    Subtitle: string?,
    Icon: string?,
    Parent: GuiObject,
    AllowSkip: boolean?,
    OnSkip: (() -> ())?,
}

function LoadingScreen.new(props: LoadingProps)
    local cleanup = Cleanup.new()

    local overlay = Instance.new("Frame")
    overlay.Name = "Silverline_LoadingScreen"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Theme.Get("Background")
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = props.Parent
    cleanup:Add(overlay)

    -- Centered Box
    local centerFrame = Instance.new("Frame")
    centerFrame.Name = "CenterFrame"
    centerFrame.BackgroundTransparency = 1
    centerFrame.Size = UDim2.fromOffset(360, 220)
    centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    centerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerFrame.ZIndex = 501
    centerFrame.Parent = overlay

    -- Brand Icon / Logo
    local icon = Icons.Create({
        Name = props.Icon or "shield",
        Size = UDim2.fromOffset(48, 48),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Color = Theme.Get("Silver"),
        ZIndex = 502,
        Parent = centerFrame,
    })

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 24)
    title.Position = UDim2.new(0, 0, 0, 70)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 18
    title.Text = props.Title or "SILVERLINE"
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 502
    title.Parent = centerFrame

    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Position = UDim2.new(0, 0, 0, 96)
    subtitle.Font = Theme.Get("FontPrimary")
    subtitle.TextSize = 12
    subtitle.Text = props.Subtitle or "Loading framework environment..."
    subtitle.TextColor3 = Theme.Get("TextMuted")
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.ZIndex = 502
    subtitle.Parent = centerFrame

    -- Progress Bar Track
    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, -60, 0, 4)
    track.Position = UDim2.new(0, 30, 0, 136)
    track.BackgroundColor3 = Theme.Get("Border")
    track.BorderSizePixel = 0
    track.ZIndex = 502
    track.Parent = centerFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Progress Bar Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Get("Silver")
    fill.BorderSizePixel = 0
    fill.ZIndex = 503
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Status Text (Stage indicator)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Position = UDim2.new(0, 0, 0, 150)
    statusLabel.Font = Theme.Get("FontMono")
    statusLabel.TextSize = 11
    statusLabel.Text = "Initializing..."
    statusLabel.TextColor3 = Theme.Get("TextMuted")
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.ZIndex = 502
    statusLabel.Parent = centerFrame

    -- Optional Skip button
    if props.AllowSkip then
        local skipBtn = Instance.new("TextButton")
        skipBtn.Name = "SkipButton"
        skipBtn.Size = UDim2.fromOffset(80, 24)
        skipBtn.AnchorPoint = Vector2.new(0.5, 0)
        skipBtn.Position = UDim2.new(0.5, 0, 0, 180)
        skipBtn.BackgroundColor3 = Theme.Get("Surface")
        skipBtn.BorderSizePixel = 0
        skipBtn.Font = Theme.Get("FontPrimary")
        skipBtn.TextSize = 11
        skipBtn.TextColor3 = Theme.Get("Silver")
        skipBtn.Text = "Skip"
        skipBtn.ZIndex = 504
        skipBtn.Parent = centerFrame

        local skCorner = Instance.new("UICorner")
        skCorner.CornerRadius = UDim.new(0, 4)
        skCorner.Parent = skipBtn

        local skStroke = Instance.new("UIStroke")
        skStroke.Thickness = 1
        skStroke.Color = Theme.Get("Border")
        skStroke.Parent = skipBtn

        skipBtn.MouseButton1Click:Connect(function()
            if props.OnSkip then pcall(props.OnSkip) end
            cleanup:Destroy()
        end)
    end

    local self = setmetatable({
        _cleanup = cleanup,
        _overlay = overlay,
        _fill = fill,
        _statusLabel = statusLabel,
        _props = props,
    }, LoadingScreen)

    return self
end

function LoadingScreen:SetProgress(ratio: number, statusText: string?)
    local clamped = math.clamp(ratio, 0, 1)
    Animation.Tween(self._fill, Animation.Presets.Fast, { Size = UDim2.new(clamped, 0, 1, 0) })
    if statusText then
        self._statusLabel.Text = statusText
    end
end

function LoadingScreen:SetStage(stageName: string)
    self._statusLabel.Text = stageName
end

function LoadingScreen:Complete(onFinished: (() -> ())?)
    self:SetProgress(1, "Complete")
    task.delay(0.25, function()
        Animation.Tween(self._overlay, Animation.Presets.Window, { BackgroundTransparency = 1 }, function()
            self._cleanup:Destroy()
            if onFinished then onFinished() end
        end)
    end)
end

function LoadingScreen:Destroy()
    self._cleanup:Destroy()
end

return LoadingScreen
