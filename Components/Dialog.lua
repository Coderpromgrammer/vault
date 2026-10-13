--!strict
--[=[
    Silverline UI Framework
    Module: Components/Dialog.lua
    Purpose: Modal confirmation dialog with blurred/dimmed backdrop and customizable actions.
]=]

local Theme = require(script.Parent.Parent.Systems.Theme)
local Animation = require(script.Parent.Parent.Systems.Animation)
local Cleanup = require(script.Parent.Parent.Systems.Cleanup)

local Dialog = {}

export type DialogProps = {
    Title: string,
    Message: string,
    ConfirmText: string?,
    CancelText: string?,
    Danger: boolean?,
    Parent: GuiObject,
    OnConfirm: (() -> ())?,
    OnCancel: (() -> ())?,
}

function Dialog.Show(props: DialogProps)
    local cleanup = Cleanup.new()

    -- Dimmed Backdrop
    local backdrop = Instance.new("TextButton")
    backdrop.Name = "DialogBackdrop"
    backdrop.Text = ""
    backdrop.AutoButtonColor = false
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Theme.Get("Overlay")
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 200
    backdrop.Parent = props.Parent
    cleanup:Add(backdrop)

    -- Dialog Modal Window
    local modal = Instance.new("Frame")
    modal.Name = "DialogModal"
    modal.Size = UDim2.fromOffset(320, 150)
    modal.Position = UDim2.new(0.5, -160, 0.5, -75)
    modal.BackgroundColor3 = Theme.Get("SurfaceElevated")
    modal.BorderSizePixel = 0
    modal.ZIndex = 201
    modal.Parent = backdrop

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = modal

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1
    stroke.Color = Theme.Get("BorderHighlight")
    stroke.Parent = modal

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent = modal

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 14
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 202
    title.Parent = modal

    -- Message
    local msg = Instance.new("TextLabel")
    msg.Name = "Message"
    msg.BackgroundTransparency = 1
    msg.Size = UDim2.new(1, 0, 0, 48)
    msg.Position = UDim2.new(0, 0, 0, 24)
    msg.Font = Theme.Get("FontPrimary")
    msg.TextSize = 12
    msg.Text = props.Message
    msg.TextColor3 = Theme.Get("TextMuted")
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextYAlignment = Enum.TextYAlignment.Top
    msg.TextWrapped = true
    msg.ZIndex = 202
    msg.Parent = modal

    -- Action Buttons Row
    local btnRow = Instance.new("Frame")
    btnRow.Name = "ButtonRow"
    btnRow.BackgroundTransparency = 1
    btnRow.Size = UDim2.new(1, 0, 0, 32)
    btnRow.Position = UDim2.new(0, 0, 1, -32)
    btnRow.ZIndex = 202
    btnRow.Parent = modal

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.Parent = btnRow

    local function closeDialog()
        Animation.Tween(backdrop, Animation.Presets.Fast, { BackgroundTransparency = 1 }, function()
            cleanup:Destroy()
        end)
    end

    -- Cancel Button
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelBtn"
    cancelBtn.Size = UDim2.fromOffset(80, 28)
    cancelBtn.BackgroundColor3 = Theme.Get("Surface")
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Font = Theme.Get("FontPrimary")
    cancelBtn.TextSize = 12
    cancelBtn.TextColor3 = Theme.Get("Silver")
    cancelBtn.Text = props.CancelText or "Cancel"
    cancelBtn.ZIndex = 203
    cancelBtn.Parent = btnRow

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = cancelBtn

    local cStroke = Instance.new("UIStroke")
    cStroke.Thickness = 1
    cStroke.Color = Theme.Get("Border")
    cStroke.Parent = cancelBtn

    cancelBtn.MouseButton1Click:Connect(function()
        if props.OnCancel then pcall(props.OnCancel) end
        closeDialog()
    end)

    -- Confirm Button
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Name = "ConfirmBtn"
    confirmBtn.Size = UDim2.fromOffset(80, 28)
    confirmBtn.BackgroundColor3 = if props.Danger then Theme.Get("Error") else Theme.Get("Silver")
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Font = Theme.Get("FontBold")
    confirmBtn.TextSize = 12
    confirmBtn.TextColor3 = if props.Danger then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(16, 18, 22)
    confirmBtn.Text = props.ConfirmText or "Confirm"
    confirmBtn.ZIndex = 203
    confirmBtn.Parent = btnRow

    local cfCorner = Instance.new("UICorner")
    cfCorner.CornerRadius = UDim.new(0, 4)
    cfCorner.Parent = confirmBtn

    confirmBtn.MouseButton1Click:Connect(function()
        if props.OnConfirm then pcall(props.OnConfirm) end
        closeDialog()
    end)

    -- Fade in
    Animation.Tween(backdrop, Animation.Presets.Modal, { BackgroundTransparency = 0.5 })
end

return Dialog
