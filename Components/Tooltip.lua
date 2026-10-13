--!strict
--[=[
    Silverline UI Framework
    Module: Components/Tooltip.lua
    Purpose: Floating hover tooltip attached to any GuiObject with smart positioning and micro-fade.
]=]

local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)

local Tooltip = {}

function Tooltip.Attach(target: GuiObject, text: string, overlay: GuiObject, cleanup: any?): () -> ()
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.fromOffset(120, 24)
    tooltip.BackgroundColor3 = Theme.Get("SurfaceElevated")
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.ZIndex = 300
    tooltip.Parent = overlay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tooltip

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("BorderHighlight")
    stroke.Parent = tooltip

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.Font = Theme.Get("FontPrimary")
    label.TextSize = 10
    label.TextColor3 = Theme.Get("Highlight")
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.ZIndex = 301
    label.Parent = tooltip

    local isHovered = false

    local c1 = target.MouseEnter:Connect(function()
        isHovered = true
        task.delay(0.2, function()
            if isHovered and target and target.Parent then
                local abs = target.AbsolutePosition
                local size = target.AbsoluteSize
                local ovAbs = overlay.AbsolutePosition

                tooltip.Position = UDim2.fromOffset(abs.X - ovAbs.X + (size.X / 2) - 60, abs.Y - ovAbs.Y - 28)
                tooltip.BackgroundTransparency = 1
                label.TextTransparency = 1
                stroke.Transparency = 1
                tooltip.Visible = true

                Animation.Tween(tooltip, Animation.Presets.Tooltip, { BackgroundTransparency = 0 })
                Animation.Tween(label, Animation.Presets.Tooltip, { TextTransparency = 0 })
                Animation.Tween(stroke, Animation.Presets.Tooltip, { Transparency = 0 })
            end
        end)
    end)

    local c2 = target.MouseLeave:Connect(function()
        isHovered = false
        tooltip.Visible = false
    end)

    local detach = function()
        c1:Disconnect()
        c2:Disconnect()
        tooltip:Destroy()
    end

    if cleanup then
        cleanup:Add(detach)
    end

    return detach
end

return Tooltip
