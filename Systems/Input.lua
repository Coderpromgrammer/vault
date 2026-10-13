--!strict
--[=[
    Silverline UI Framework
    Module: Systems/Input.lua
    Purpose: Cross-platform input handling (Mouse, Touch, Keyboard) with viewport clamping and focus awareness.
]=]

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Input = {}

-- Checks whether the user is actively focused on typing in a TextBox
function Input.IsTyping(): boolean
    return UserInputService:GetFocusedTextBox() ~= nil
end

-- Screen viewport bounds helper
function Input.GetViewportSize(): Vector2
    local camera = Workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1920, 1080)
end

export type DraggableOptions = {
    ClampToScreen: boolean?,
    Padding: number?,
    OnDragStart: (() -> ())?,
    OnDragEnd: ((position: UDim2) -> ())?,
}

-- Make a frame draggable by mouse or touch with screen bounds clamping
function Input.MakeDraggable(targetFrame: GuiObject, dragHandle: GuiObject, options: DraggableOptions?, cleanup: any?): () -> ()
    local opts = options or {}
    local clamp = if opts.ClampToScreen ~= nil then opts.ClampToScreen else true
    local padding = opts.Padding or 10

    local dragging = false
    local dragInput: InputObject? = nil
    local dragStartPos: Vector3 = Vector3.zero
    local startFramePos: UDim2 = targetFrame.Position

    local connections: { RBXScriptConnection } = {}

    local function updatePosition(input: InputObject)
        local delta = input.Position - dragStartPos
        local viewport = Input.GetViewportSize()
        local frameSize = targetFrame.AbsoluteSize

        local targetX = startFramePos.X.Offset + delta.X
        local targetY = startFramePos.Y.Offset + delta.Y

        if clamp then
            local minX = padding
            local maxX = viewport.X - frameSize.X - padding
            local minY = padding
            local maxY = viewport.Y - frameSize.Y - padding

            if maxX < minX then maxX = minX end
            if maxY < minY then maxY = minY end

            targetX = math.clamp(targetX, minX, maxX)
            targetY = math.clamp(targetY, minY, maxY)
        end

        targetFrame.Position = UDim2.new(
            startFramePos.X.Scale,
            targetX,
            startFramePos.Y.Scale,
            targetY
        )
    end

    local c1 = dragHandle.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            startFramePos = targetFrame.Position

            if opts.OnDragStart then
                opts.OnDragStart()
            end

            local cInputEnded: RBXScriptConnection?
            cInputEnded = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if cInputEnded then
                        cInputEnded:Disconnect()
                        cInputEnded = nil
                    end
                    if opts.OnDragEnd then
                        opts.OnDragEnd(targetFrame.Position)
                    end
                end
            end)
            table.insert(connections, cInputEnded)
        end
    end)
    table.insert(connections, c1)

    local c2 = dragHandle.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(connections, c2)

    local c3 = UserInputService.InputChanged:Connect(function(input: InputObject)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updatePosition(input)
        end
    end)
    table.insert(connections, c3)

    local disconnect = function()
        dragging = false
        for _, conn in ipairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        table.clear(connections)
    end

    if cleanup then
        cleanup:Add(disconnect)
    end

    return disconnect
end

-- Capture next key press (for Keybind picker)
function Input.ListenForNextKey(callback: (Enum.KeyCode?, boolean) -> (), cleanup: any?): () -> ()
    local connection: RBXScriptConnection?

    connection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        -- Ignore mouse movement
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if connection then
                connection:Disconnect()
                connection = nil
            end

            -- If Escape, consider cancelled
            if input.KeyCode == Enum.KeyCode.Escape then
                callback(nil, true)
            else
                callback(input.KeyCode, false)
            end
        end
    end)

    local disconnect = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end

    if cleanup then
        cleanup:Add(disconnect)
    end

    return disconnect
end

-- Listen to active keybind with hold and toggle modes
function Input.BindKey(keyCode: Enum.KeyCode, callback: (isHeld: boolean) -> (), mode: string?, cleanup: any?): () -> ()
    local isHoldMode = (mode == "Hold")
    local connections: { RBXScriptConnection } = {}

    local c1 = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed or Input.IsTyping() then return end
        if input.KeyCode == keyCode then
            callback(true)
        end
    end)
    table.insert(connections, c1)

    if isHoldMode then
        local c2 = UserInputService.InputEnded:Connect(function(input: InputObject)
            if input.KeyCode == keyCode then
                callback(false)
            end
        end)
        table.insert(connections, c2)
    end

    local disconnect = function()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        table.clear(connections)
    end

    if cleanup then
        cleanup:Add(disconnect)
    end

    return disconnect
end

return Input
