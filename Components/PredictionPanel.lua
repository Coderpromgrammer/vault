--!strict
--[=[
    Silverline UI Framework
    Module: Components/PredictionPanel.lua
    Purpose: Presentation component for application-supplied predictions, metrics, estimates, and previews.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Icons = require(script.Parent.Parent.Systems.Icons)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local PredictionPanel = {}
PredictionPanel.__index = PredictionPanel

export type PredictionPanelProps = {
    Title: string,
    Status: string?,
    Value: string?,
    Confidence: string?,
    Details: { [string]: string }?,
    Parent: GuiObject,
    OnRefresh: (() -> ())?,
}

function PredictionPanel.new(props: PredictionPanelProps)
    local cleanup = Cleanup.new()

    local card = Instance.new("Frame")
    card.Name = "PredictionPanel_" .. props.Title
    card.Size = UDim2.new(1, 0, 0, 110)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = props.Parent
    cleanup:Add(card)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("Border")
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = card

    -- Header (Title + Status Badge + Refresh button)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 20)
    header.Parent = card

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local statusBadge = Instance.new("TextLabel")
    statusBadge.Name = "StatusBadge"
    statusBadge.Size = UDim2.fromOffset(68, 18)
    statusBadge.Position = UDim2.new(1, -94, 0, 1)
    statusBadge.BackgroundColor3 = Theme.Get("Surface")
    statusBadge.Font = Theme.Get("FontMono")
    statusBadge.TextSize = 10
    statusBadge.TextColor3 = Theme.Get("Accent")
    statusBadge.Text = props.Status or "Active"
    statusBadge.Parent = header

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = statusBadge

    if props.OnRefresh then
        local refreshBtn = Instance.new("ImageButton")
        refreshBtn.Name = "RefreshBtn"
        refreshBtn.BackgroundTransparency = 1
        refreshBtn.Size = UDim2.fromOffset(16, 16)
        refreshBtn.Position = UDim2.new(1, -18, 0, 2)
        refreshBtn.Image = Icons.Get("refresh")
        refreshBtn.ImageColor3 = Theme.Get("Silver")
        refreshBtn.Parent = header

        refreshBtn.MouseButton1Click:Connect(function()
            Animation.Tween(refreshBtn, Animation.Presets.Fast, { Rotation = refreshBtn.Rotation + 180 })
            pcall(props.OnRefresh)
        end)
    end

    -- Hero Value Display
    local heroVal = Instance.new("TextLabel")
    heroVal.Name = "HeroValue"
    heroVal.BackgroundTransparency = 1
    heroVal.Size = UDim2.new(1, 0, 0, 32)
    heroVal.Position = UDim2.new(0, 0, 0, 28)
    heroVal.Font = Theme.Get("FontBold")
    heroVal.TextSize = 24
    heroVal.Text = props.Value or "—"
    heroVal.TextColor3 = Theme.Get("Silver")
    heroVal.TextXAlignment = Enum.TextXAlignment.Left
    heroVal.Parent = card

    -- Confidence / Uncertainty subtext
    local confLabel = Instance.new("TextLabel")
    confLabel.Name = "ConfidenceLabel"
    confLabel.BackgroundTransparency = 1
    confLabel.Size = UDim2.new(1, 0, 0, 14)
    confLabel.Position = UDim2.new(0, 0, 0, 64)
    confLabel.Font = Theme.Get("FontPrimary")
    confLabel.TextSize = 11
    confLabel.Text = props.Confidence or "Confidence: 99.2% (±0.4)"
    confLabel.TextColor3 = Theme.Get("TextMuted")
    confLabel.TextXAlignment = Enum.TextXAlignment.Left
    confLabel.Parent = card

    local self = setmetatable({
        _cleanup = cleanup,
        _card = card,
        _heroVal = heroVal,
        _statusBadge = statusBadge,
        _confLabel = confLabel,
        _props = props,
    }, PredictionPanel)

    return self
end

function PredictionPanel:Update(val: string, status: string?, confidence: string?)
    self._heroVal.Text = val
    if status then self._statusBadge.Text = status end
    if confidence then self._confLabel.Text = confidence end
end

function PredictionPanel:Destroy()
    self._cleanup:Destroy()
end

return PredictionPanel
