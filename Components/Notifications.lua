--!strict
--[=[
    Silverline UI Framework
    Module: Components/Notifications.lua
    Purpose: Toast notification manager with progress bar decay, semantic types, and queue handling.
]=]

local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)

local Notifications = {}

export type NotificationProps = {
    Title: string,
    Content: string,
    Duration: number?,
    Type: ("Info" | "Success" | "Warning" | "Error")?,
    Icon: string?,
    OnClick: (() -> ())?,
}

local hostContainer: Frame? = nil

function Notifications.Init(screenGui: ScreenGui)
    if hostContainer then return end

    local container = Instance.new("Frame")
    container.Name = "Silverline_Notifications"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 280, 1, -20)
    container.Position = UDim2.new(1, -290, 0, 10)
    container.ZIndex = 100
    container.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    hostContainer = container
end

function Notifications.Notify(props: NotificationProps)
    if not hostContainer then return end

    local nType = props.Type or "Info"
    local duration = props.Duration or 4
    local iconName = props.Icon or (if nType == "Success" then "check" elseif nType == "Warning" then "warning" elseif nType == "Error" then "close" else "info")

    local accentColor = if nType == "Success" then Theme.Get("Success")
        elseif nType == "Warning" then Theme.Get("Warning")
        elseif nType == "Error" then Theme.Get("Error")
        else Theme.Get("Accent")

    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.Size = UDim2.new(1, 0, 0, 68)
    toast.BackgroundColor3 = Theme.Get("SurfaceElevated")
    toast.BorderSizePixel = 0
    toast.ClipsDescendants = true
    toast.Position = UDim2.new(1, 40, 0, 0) -- starts offset for slide-in
    toast.Parent = hostContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("Border")
    stroke.Parent = toast

    -- Left Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast

    -- Icon
    local icon = Icons.Create({
        Name = iconName,
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(0, 12, 0, 12),
        Color = accentColor,
        Parent = toast,
    })

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -60, 0, 16)
    title.Position = UDim2.new(0, 36, 0, 10)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ClipsDescendants = true
    title.Parent = toast

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -60, 0, 30)
    content.Position = UDim2.new(0, 36, 0, 28)
    content.Font = Theme.Get("FontPrimary")
    content.TextSize = 11
    content.Text = props.Content
    content.TextColor3 = Theme.Get("TextMuted")
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = toast

    -- Close Button
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.fromOffset(16, 16)
    closeBtn.Position = UDim2.new(1, -24, 0, 10)
    closeBtn.Image = Icons.Get("close")
    closeBtn.ImageColor3 = Theme.Get("TextMuted")
    closeBtn.Parent = toast

    -- Decay Progress Bar at bottom
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = accentColor
    progress.BorderSizePixel = 0
    progress.Parent = toast

    local function dismiss()
        Animation.Tween(toast, Animation.Presets.Fast, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, function()
            toast:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)

    if props.OnClick then
        local clickBtn = Instance.new("TextButton")
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Size = UDim2.new(1, -30, 1, 0)
        clickBtn.ZIndex = 2
        clickBtn.Parent = toast
        clickBtn.MouseButton1Click:Connect(function()
            props.OnClick()
            dismiss()
        end)
    end

    -- Entrance slide-in
    Animation.Tween(toast, Animation.Presets.Fast, { Position = UDim2.new(0, 0, 0, 0) })

    -- Decay animation
    local decayTween = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    decayTween:Play()
    decayTween.Completed:Connect(function()
        dismiss()
    end)
end

return Notifications
