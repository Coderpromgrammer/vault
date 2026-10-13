--!strict
--[=[
    Silverline UI Framework
    Module: Systems/Animation.lua
    Purpose: Centralized tween and micro-interaction animation engine.
]=]

local TweenService = game:GetService("TweenService")

local Animation = {
    Enabled = true,
}

export type Preset = {
    Duration: number,
    Style: Enum.EasingStyle,
    Direction: Enum.EasingDirection,
}

Animation.Presets = {
    ButtonPress = { Duration = 0.10, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Toggle      = { Duration = 0.14, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Tooltip     = { Duration = 0.12, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Dropdown    = { Duration = 0.16, Style = Enum.EasingStyle.Quart, Direction = Enum.EasingDirection.Out },
    Tab         = { Duration = 0.18, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Window      = { Duration = 0.22, Style = Enum.EasingStyle.Quart, Direction = Enum.EasingDirection.Out },
    Modal       = { Duration = 0.18, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Fast        = { Duration = 0.12, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
    Normal      = { Duration = 0.20, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
}

local activeTweens: { [Instance]: { Tween } } = {}

function Animation.Tween(instance: Instance, presetOrInfo: Preset | TweenInfo, goals: { [string]: any }, onComplete: (() -> ())?): Tween?
    if not instance or not instance.Parent then
        return nil
    end

    -- If animations are globally disabled, apply goals immediately
    if not Animation.Enabled then
        for prop, val in pairs(goals) do
            pcall(function()
                (instance :: any)[prop] = val
            end)
        end
        if onComplete then
            task.spawn(onComplete)
        end
        return nil
    end

    local tweenInfo: TweenInfo
    if typeof(presetOrInfo) == "TweenInfo" then
        tweenInfo = presetOrInfo
    elseif typeof(presetOrInfo) == "table" and (presetOrInfo :: any).Duration then
        local p = presetOrInfo :: Preset
        tweenInfo = TweenInfo.new(p.Duration, p.Style, p.Direction)
    else
        tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end

    -- Cancel any previously active tweens on this instance to prevent fights
    if activeTweens[instance] then
        for _, t in ipairs(activeTweens[instance]) do
            t:Cancel()
        end
        activeTweens[instance] = nil
    end

    local tween: Tween
    local ok, res = pcall(function()
        return TweenService:Create(instance, tweenInfo, goals)
    end)

    if not ok or not res then
        for prop, val in pairs(goals) do
            pcall(function()
                (instance :: any)[prop] = val
            end)
        end
        if onComplete then task.spawn(onComplete) end
        return nil
    end

    tween = res
    if not activeTweens[instance] then
        activeTweens[instance] = {}
    end
    table.insert(activeTweens[instance], tween)

    local completedConn: RBXScriptConnection?
    completedConn = tween.Completed:Connect(function(state)
        if completedConn then
            completedConn:Disconnect()
            completedConn = nil
        end
        if activeTweens[instance] then
            local idx = table.find(activeTweens[instance], tween)
            if idx then
                table.remove(activeTweens[instance], idx)
            end
            if #activeTweens[instance] == 0 then
                activeTweens[instance] = nil
            end
        end
        if state == Enum.PlaybackState.Completed and onComplete then
            onComplete()
        end
    end)

    tween:Play()
    return tween
end

function Animation.Cancel(instance: Instance)
    if activeTweens[instance] then
        for _, t in ipairs(activeTweens[instance]) do
            t:Cancel()
        end
        activeTweens[instance] = nil
    end
end

function Animation.AddHover(button: GuiButton, normalGoals: { [string]: any }, hoverGoals: { [string]: any }, pressGoals: { [string]: any }?, cleanup: any?): () -> ()
    local isHovered = false
    local isPressed = false

    local c1 = button.MouseEnter:Connect(function()
        isHovered = true
        if not isPressed then
            Animation.Tween(button, Animation.Presets.Fast, hoverGoals)
        end
    end)

    local c2 = button.MouseLeave:Connect(function()
        isHovered = false
        isPressed = false
        Animation.Tween(button, Animation.Presets.Fast, normalGoals)
    end)

    local c3 = button.MouseButton1Down:Connect(function()
        isPressed = true
        if pressGoals then
            Animation.Tween(button, Animation.Presets.ButtonPress, pressGoals)
        end
    end)

    local c4 = button.MouseButton1Up:Connect(function()
        isPressed = false
        if isHovered then
            Animation.Tween(button, Animation.Presets.Fast, hoverGoals)
        else
            Animation.Tween(button, Animation.Presets.Fast, normalGoals)
        end
    end)

    local disconnectAll = function()
        c1:Disconnect()
        c2:Disconnect()
        c3:Disconnect()
        c4:Disconnect()
    end

    if cleanup then
        cleanup:Add(disconnectAll)
    end

    return disconnectAll
end

return Animation
