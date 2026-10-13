--!strict
--[=[
    ███████╗██╗██╗     ██╗   ██╗███████╗██████╗ ██╗     ██╗███╗   ██╗███████╗
    ██╔════╝██║██║     ██║   ██║██╔════╝██╔══██╗██║     ██║████╗  ██║██╔════╝
    ███████╗██║██║     ██║   ██║█████╗  ██████╔╝██║     ██║██╔██╗ ██║█████╗  
    ╚════██║██║██║     ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║     ██║██║╚██╗██║██╔══╝  
    ███████║██║███████╗ ╚████╔╝ ███████╗██║  ██║███████╗██║██║ ╚████║███████╗
    ╚══════╝╚═╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝

    Silverline UI Framework v1.0.0 (Standalone Distribution Bundle)
    Repository: https://github.com/Coderpromgrammer/vault
    Loadstring URL: https://raw.githubusercontent.com/Coderpromgrammer/vault/main/bundle.lua
]=]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ============================================================================
-- 1. CLEANUP (Maid / Lifecycle)
-- ============================================================================
local Cleanup = {}
Cleanup.__index = Cleanup

export type CleanupTask = Instance | RBXScriptConnection | () -> () | { Destroy: (any) -> () } | { Clean: (any) -> () }

function Cleanup.new()
    return setmetatable({
        _tasks = {} :: { [any]: CleanupTask },
        _isCleaning = false,
        _destroyed = false,
    }, Cleanup)
end

function Cleanup:Add(task: CleanupTask): CleanupTask
    if self._destroyed then
        Cleanup._cleanTask(task)
        return task
    end
    table.insert(self._tasks, task)
    return task
end

function Cleanup._cleanTask(task: CleanupTask)
    if typeof(task) == "RBXScriptConnection" then
        task:Disconnect()
    elseif typeof(task) == "Instance" then
        task:Destroy()
    elseif typeof(task) == "function" then
        pcall(task)
    elseif typeof(task) == "table" then
        if typeof((task :: any).Destroy) == "function" then
            pcall(function() (task :: any):Destroy() end)
        elseif typeof((task :: any).Clean) == "function" then
            pcall(function() (task :: any):Clean() end)
        end
    end
end

function Cleanup:Clean()
    if self._isCleaning then return end
    self._isCleaning = true
    for key, task in pairs(self._tasks) do
        Cleanup._cleanTask(task)
        self._tasks[key] = nil
    end
    self._isCleaning = false
end

function Cleanup:Destroy()
    if self._destroyed then return end
    self:Clean()
    self._destroyed = true
end

-- ============================================================================
-- 2. THEME ENGINE
-- ============================================================================
local Theme = {}

export type ThemeTokens = {
    Background: Color3,
    Surface: Color3,
    SurfaceElevated: Color3,
    SurfaceHover: Color3,
    SurfaceActive: Color3,
    Silver: Color3,
    Highlight: Color3,
    TextMuted: Color3,
    TextDisabled: Color3,
    Border: Color3,
    BorderHighlight: Color3,
    Accent: Color3,
    AccentHover: Color3,
    Success: Color3,
    Warning: Color3,
    Error: Color3,
    Overlay: Color3,
    FontPrimary: Enum.Font,
    FontBold: Enum.Font,
    FontMono: Enum.Font,
}

local Themes: { [string]: ThemeTokens } = {
    DarkSilver = {
        Background      = Color3.fromRGB(16, 18, 22),
        Surface         = Color3.fromRGB(23, 26, 32),
        SurfaceElevated = Color3.fromRGB(32, 36, 43),
        SurfaceHover    = Color3.fromRGB(42, 48, 58),
        SurfaceActive   = Color3.fromRGB(52, 60, 72),
        Silver          = Color3.fromRGB(198, 204, 213),
        Highlight       = Color3.fromRGB(243, 245, 248),
        TextMuted       = Color3.fromRGB(146, 154, 167),
        TextDisabled    = Color3.fromRGB(90, 96, 106),
        Border          = Color3.fromRGB(52, 59, 70),
        BorderHighlight = Color3.fromRGB(130, 140, 155),
        Accent          = Color3.fromRGB(158, 191, 232),
        AccentHover     = Color3.fromRGB(180, 208, 245),
        Success         = Color3.fromRGB(110, 205, 145),
        Warning         = Color3.fromRGB(235, 185, 95),
        Error           = Color3.fromRGB(235, 95, 95),
        Overlay         = Color3.fromRGB(8, 9, 12),
        FontPrimary     = Enum.Font.GothamMedium,
        FontBold        = Enum.Font.GothamBold,
        FontMono        = Enum.Font.Code,
    },
    LightSilver = {
        Background      = Color3.fromRGB(240, 242, 245),
        Surface         = Color3.fromRGB(255, 255, 255),
        SurfaceElevated = Color3.fromRGB(245, 247, 250),
        SurfaceHover    = Color3.fromRGB(235, 238, 242),
        SurfaceActive   = Color3.fromRGB(225, 230, 236),
        Silver          = Color3.fromRGB(110, 118, 130),
        Highlight       = Color3.fromRGB(20, 24, 30),
        TextMuted       = Color3.fromRGB(115, 122, 134),
        TextDisabled    = Color3.fromRGB(175, 180, 190),
        Border          = Color3.fromRGB(215, 220, 228),
        BorderHighlight = Color3.fromRGB(140, 150, 165),
        Accent          = Color3.fromRGB(65, 120, 210),
        AccentHover     = Color3.fromRGB(80, 135, 230),
        Success         = Color3.fromRGB(50, 160, 90),
        Warning         = Color3.fromRGB(210, 140, 30),
        Error           = Color3.fromRGB(215, 60, 60),
        Overlay         = Color3.fromRGB(40, 45, 50),
        FontPrimary     = Enum.Font.GothamMedium,
        FontBold        = Enum.Font.GothamBold,
        FontMono        = Enum.Font.Code,
    },
    Obsidian = {
        Background      = Color3.fromRGB(10, 11, 13),
        Surface         = Color3.fromRGB(14, 16, 19),
        SurfaceElevated = Color3.fromRGB(20, 22, 27),
        SurfaceHover    = Color3.fromRGB(28, 31, 38),
        SurfaceActive   = Color3.fromRGB(36, 40, 48),
        Silver          = Color3.fromRGB(165, 172, 185),
        Highlight       = Color3.fromRGB(235, 238, 242),
        TextMuted       = Color3.fromRGB(118, 125, 138),
        TextDisabled    = Color3.fromRGB(70, 75, 84),
        Border          = Color3.fromRGB(38, 43, 52),
        BorderHighlight = Color3.fromRGB(95, 105, 120),
        Accent          = Color3.fromRGB(130, 165, 215),
        AccentHover     = Color3.fromRGB(150, 185, 235),
        Success         = Color3.fromRGB(90, 185, 130),
        Warning         = Color3.fromRGB(215, 165, 80),
        Error           = Color3.fromRGB(220, 80, 80),
        Overlay         = Color3.fromRGB(5, 6, 7),
        FontPrimary     = Enum.Font.GothamMedium,
        FontBold        = Enum.Font.GothamBold,
        FontMono        = Enum.Font.Code,
    },
    Platinum = {
        Background      = Color3.fromRGB(22, 24, 28),
        Surface         = Color3.fromRGB(30, 33, 40),
        SurfaceElevated = Color3.fromRGB(40, 44, 54),
        SurfaceHover    = Color3.fromRGB(52, 58, 70),
        SurfaceActive   = Color3.fromRGB(64, 72, 86),
        Silver          = Color3.fromRGB(220, 225, 235),
        Highlight       = Color3.fromRGB(250, 252, 255),
        TextMuted       = Color3.fromRGB(160, 168, 182),
        TextDisabled    = Color3.fromRGB(100, 108, 120),
        Border          = Color3.fromRGB(68, 76, 90),
        BorderHighlight = Color3.fromRGB(150, 162, 180),
        Accent          = Color3.fromRGB(175, 205, 245),
        AccentHover     = Color3.fromRGB(195, 220, 255),
        Success         = Color3.fromRGB(120, 215, 155),
        Warning         = Color3.fromRGB(240, 195, 105),
        Error           = Color3.fromRGB(240, 105, 105),
        Overlay         = Color3.fromRGB(12, 14, 18),
        FontPrimary     = Enum.Font.GothamMedium,
        FontBold        = Enum.Font.GothamBold,
        FontMono        = Enum.Font.Code,
    },
}

local currentThemeName = "DarkSilver"
local currentThemeTokens = Themes.DarkSilver
local boundElements: { [Instance]: { [string]: string } } = {}
local listeners: { (string, ThemeTokens) -> () } = {}

function Theme.Get(token: string): any
    local val = (currentThemeTokens :: any)[token]
    if val ~= nil then return val end
    return (Themes.DarkSilver :: any)[token]
end

function Theme.SetTheme(themeNameOrTable: string | ThemeTokens)
    if type(themeNameOrTable) == "string" then
        local found = Themes[themeNameOrTable] or Themes.DarkSilver
        currentThemeName = if Themes[themeNameOrTable] then themeNameOrTable else "DarkSilver"
        currentThemeTokens = found
    elseif type(themeNameOrTable) == "table" then
        currentThemeName = "Custom"
        currentThemeTokens = themeNameOrTable :: ThemeTokens
    end

    for instance, propMap in pairs(boundElements) do
        if instance and instance.Parent then
            for propName, tokenName in pairs(propMap) do
                local tokenVal = Theme.Get(tokenName)
                if tokenVal ~= nil then
                    pcall(function() (instance :: any)[propName] = tokenVal end)
                end
            end
        else
            boundElements[instance] = nil
        end
    end

    for _, callback in ipairs(listeners) do
        pcall(callback, currentThemeName, currentThemeTokens)
    end
end

function Theme.OnThemeChanged(callback: (string, ThemeTokens) -> ()): () -> ()
    table.insert(listeners, callback)
    return function()
        local idx = table.find(listeners, callback)
        if idx then table.remove(listeners, idx) end
    end
end

-- ============================================================================
-- 3. ICONS ATLAS
-- ============================================================================
local Icons = {}

local Registry: { [string]: { AssetId: string, Fallback: string } } = {
    ["home"]          = { AssetId = "rbxassetid://10723407389", Fallback = "⌂" },
    ["settings"]      = { AssetId = "rbxassetid://10734950309", Fallback = "⚙" },
    ["search"]        = { AssetId = "rbxassetid://10734883986", Fallback = "🔍" },
    ["chevron-down"]  = { AssetId = "rbxassetid://10709790948", Fallback = "⌄" },
    ["chevron-right"] = { AssetId = "rbxassetid://10709791437", Fallback = "›" },
    ["chevron-up"]    = { AssetId = "rbxassetid://10709791281", Fallback = "⌃" },
    ["check"]         = { AssetId = "rbxassetid://10709790644", Fallback = "✓" },
    ["close"]         = { AssetId = "rbxassetid://10747384394", Fallback = "✕" },
    ["plus"]          = { AssetId = "rbxassetid://10734924532", Fallback = "+" },
    ["minus"]         = { AssetId = "rbxassetid://10734924219", Fallback = "−" },
    ["info"]          = { AssetId = "rbxassetid://10723415903", Fallback = "ℹ" },
    ["warning"]       = { AssetId = "rbxassetid://10734960447", Fallback = "⚠" },
    ["success"]       = { AssetId = "rbxassetid://10709790644", Fallback = "✓" },
    ["error"]         = { AssetId = "rbxassetid://10747384394", Fallback = "✕" },
    ["loader"]        = { AssetId = "rbxassetid://10734922324", Fallback = "↻" },
    ["eye"]           = { AssetId = "rbxassetid://10723346959", Fallback = "👁" },
    ["eye-off"]       = { AssetId = "rbxassetid://10723345840", Fallback = "Ø" },
    ["keyboard"]      = { AssetId = "rbxassetid://10723416652", Fallback = "⌨" },
    ["palette"]       = { AssetId = "rbxassetid://10734886202", Fallback = "🎨" },
    ["sliders"]       = { AssetId = "rbxassetid://10734951847", Fallback = "⚲" },
    ["refresh"]       = { AssetId = "rbxassetid://10734933966", Fallback = "↺" },
    ["download"]      = { AssetId = "rbxassetid://10709798276", Fallback = "↓" },
    ["upload"]        = { AssetId = "rbxassetid://10747373176", Fallback = "↑" },
    ["copy"]          = { AssetId = "rbxassetid://10709798682", Fallback = "⎘" },
    ["trash"]         = { AssetId = "rbxassetid://10747383819", Fallback = "🗑" },
    ["maximize"]      = { AssetId = "rbxassetid://10734923549", Fallback = "⛶" },
    ["minimize"]      = { AssetId = "rbxassetid://10734924040", Fallback = "🗕" },
    ["play"]          = { AssetId = "rbxassetid://10734924340", Fallback = "▶" },
    ["pause"]         = { AssetId = "rbxassetid://10734924127", Fallback = "⏸" },
    ["shield"]        = { AssetId = "rbxassetid://10734950817", Fallback = "🛡" },
    ["terminal"]      = { AssetId = "rbxassetid://10734953683", Fallback = ">" },
    ["user"]          = { AssetId = "rbxassetid://10747373426", Fallback = "👤" },
    ["star"]          = { AssetId = "rbxassetid://10734952494", Fallback = "★" },
    ["activity"]      = { AssetId = "rbxassetid://10709789919", Fallback = "〰" },
    ["zap"]           = { AssetId = "rbxassetid://10747375267", Fallback = "⚡" },
    ["box"]           = { AssetId = "rbxassetid://10709790479", Fallback = "■" },
}

function Icons.Get(name: string): string
    local entry = Registry[string.lower(name)]
    return if entry then entry.AssetId else "rbxassetid://10709790479"
end

function Icons.Create(props: any): ImageLabel
    local iconName = string.lower(props.Name or "box")
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon_" .. iconName
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.Image = Icons.Get(iconName)
    icon.ImageColor3 = props.Color or Color3.fromRGB(198, 204, 213)
    icon.ImageTransparency = props.Transparency or 0
    icon.Size = props.Size or UDim2.fromOffset(16, 16)
    icon.Position = props.Position or UDim2.new(0, 0, 0, 0)
    icon.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
    icon.ZIndex = props.ZIndex or 1
    if props.Parent then icon.Parent = props.Parent end
    return icon
end

-- ============================================================================
-- 4. ANIMATION ENGINE
-- ============================================================================
local Animation = { Enabled = true }

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

function Animation.Tween(instance: Instance, presetOrInfo: any, goals: { [string]: any }, onComplete: (() -> ())?): Tween?
    if not instance or not instance.Parent then return nil end

    if not Animation.Enabled then
        for prop, val in pairs(goals) do
            pcall(function() (instance :: any)[prop] = val end)
        end
        if onComplete then task.spawn(onComplete) end
        return nil
    end

    local tweenInfo: TweenInfo
    if typeof(presetOrInfo) == "TweenInfo" then
        tweenInfo = presetOrInfo
    elseif typeof(presetOrInfo) == "table" and presetOrInfo.Duration then
        tweenInfo = TweenInfo.new(presetOrInfo.Duration, presetOrInfo.Style, presetOrInfo.Direction)
    else
        tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end

    if activeTweens[instance] then
        for _, t in ipairs(activeTweens[instance]) do t:Cancel() end
        activeTweens[instance] = nil
    end

    local ok, tween = pcall(function() return TweenService:Create(instance, tweenInfo, goals) end)
    if not ok or not tween then
        for prop, val in pairs(goals) do pcall(function() (instance :: any)[prop] = val end) end
        if onComplete then task.spawn(onComplete) end
        return nil
    end

    if not activeTweens[instance] then activeTweens[instance] = {} end
    table.insert(activeTweens[instance], tween)

    local completedConn: RBXScriptConnection?
    completedConn = tween.Completed:Connect(function(state)
        if completedConn then completedConn:Disconnect() completedConn = nil end
        if activeTweens[instance] then
            local idx = table.find(activeTweens[instance], tween)
            if idx then table.remove(activeTweens[instance], idx) end
        end
        if state == Enum.PlaybackState.Completed and onComplete then onComplete() end
    end)

    tween:Play()
    return tween
end

-- ============================================================================
-- 5. INPUT & DRAGGING
-- ============================================================================
local Input = {}

function Input.IsTyping(): boolean
    return UserInputService:GetFocusedTextBox() ~= nil
end

function Input.GetViewportSize(): Vector2
    local camera = Workspace.CurrentCamera
    return if camera then camera.ViewportSize else Vector2.new(1920, 1080)
end

function Input.MakeDraggable(targetFrame: GuiObject, dragHandle: GuiObject, options: any?, cleanup: any?): () -> ()
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
            local minX, maxX = padding, viewport.X - frameSize.X - padding
            local minY, maxY = padding, viewport.Y - frameSize.Y - padding
            if maxX < minX then maxX = minX end
            if maxY < minY then maxY = minY end
            targetX = math.clamp(targetX, minX, maxX)
            targetY = math.clamp(targetY, minY, maxY)
        end

        targetFrame.Position = UDim2.new(startFramePos.X.Scale, targetX, startFramePos.Y.Scale, targetY)
    end

    local c1 = dragHandle.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            startFramePos = targetFrame.Position

            local cEnd: RBXScriptConnection?
            cEnd = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if cEnd then cEnd:Disconnect() cEnd = nil end
                end
            end)
            table.insert(connections, cEnd)
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
        for _, conn in ipairs(connections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(connections)
    end
    if cleanup then cleanup:Add(disconnect) end
    return disconnect
end

function Input.ListenForNextKey(callback: (Enum.KeyCode?, boolean) -> (), cleanup: any?): () -> ()
    local connection: RBXScriptConnection?
    connection = UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if connection then connection:Disconnect() connection = nil end
            if input.KeyCode == Enum.KeyCode.Escape then
                callback(nil, true)
            else
                callback(input.KeyCode, false)
            end
        end
    end)
    local disconnect = function() if connection then connection:Disconnect() connection = nil end end
    if cleanup then cleanup:Add(disconnect) end
    return disconnect
end

function Input.BindKey(keyCode: Enum.KeyCode, callback: (isHeld: boolean) -> (), mode: string?, cleanup: any?): () -> ()
    local isHold = (mode == "Hold")
    local connections: { RBXScriptConnection } = {}

    local c1 = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or Input.IsTyping() then return end
        if input.KeyCode == keyCode then callback(true) end
    end)
    table.insert(connections, c1)

    if isHold then
        local c2 = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == keyCode then callback(false) end
        end)
        table.insert(connections, c2)
    end

    local disconnect = function() for _, c in ipairs(connections) do c:Disconnect() end end
    if cleanup then cleanup:Add(disconnect) end
    return disconnect
end

-- ============================================================================
-- 6. STATE
-- ============================================================================
local State = {}
State.__index = State

function State.new<T>(initialValue: T)
    return setmetatable({
        _value = initialValue,
        _listeners = {},
        _destroyed = false,
    }, State)
end

function State:Get() return self._value end

function State:Set(newVal, suppress)
    if self._destroyed or self._value == newVal then return false end
    local oldVal = self._value
    self._value = newVal
    if not suppress then
        for _, l in ipairs(self._listeners) do pcall(l, newVal, oldVal) end
    end
    return true
end

function State:Listen(fn)
    table.insert(self._listeners, fn)
    return function()
        local idx = table.find(self._listeners, fn)
        if idx then table.remove(self._listeners, idx) end
    end
end

-- ============================================================================
-- 7. DIALOG & TOOLTIP
-- ============================================================================
local Dialog = {}
function Dialog.Show(props: any)
    local cleanup = Cleanup.new()
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

    local modal = Instance.new("Frame")
    modal.Size = UDim2.fromOffset(320, 150)
    modal.Position = UDim2.new(0.5, -160, 0.5, -75)
    modal.BackgroundColor3 = Theme.Get("SurfaceElevated")
    modal.BorderSizePixel = 0
    modal.ZIndex = 201
    modal.Parent = backdrop

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = modal
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("BorderHighlight") stroke.Parent = modal
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 16) pad.PaddingRight = UDim.new(0, 16) pad.PaddingTop = UDim.new(0, 14) pad.PaddingBottom = UDim.new(0, 14) pad.Parent = modal

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 14
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 202
    title.Parent = modal

    local msg = Instance.new("TextLabel")
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

    local btnRow = Instance.new("Frame")
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

    local function close()
        Animation.Tween(backdrop, Animation.Presets.Fast, { BackgroundTransparency = 1 }, function() cleanup:Destroy() end)
    end

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.fromOffset(80, 28)
    cancelBtn.BackgroundColor3 = Theme.Get("Surface")
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Font = Theme.Get("FontPrimary")
    cancelBtn.TextSize = 12
    cancelBtn.TextColor3 = Theme.Get("Silver")
    cancelBtn.Text = props.CancelText or "Cancel"
    cancelBtn.ZIndex = 203
    cancelBtn.Parent = btnRow
    local cCorner = Instance.new("UICorner") cCorner.CornerRadius = UDim.new(0, 4) cCorner.Parent = cancelBtn
    cancelBtn.MouseButton1Click:Connect(function() if props.OnCancel then pcall(props.OnCancel) end close() end)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.fromOffset(80, 28)
    confirmBtn.BackgroundColor3 = if props.Danger then Theme.Get("Error") else Theme.Get("Silver")
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Font = Theme.Get("FontBold")
    confirmBtn.TextSize = 12
    confirmBtn.TextColor3 = if props.Danger then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(16, 18, 22)
    confirmBtn.Text = props.ConfirmText or "Confirm"
    confirmBtn.ZIndex = 203
    confirmBtn.Parent = btnRow
    local cfCorner = Instance.new("UICorner") cfCorner.CornerRadius = UDim.new(0, 4) cfCorner.Parent = confirmBtn
    confirmBtn.MouseButton1Click:Connect(function() if props.OnConfirm then pcall(props.OnConfirm) end close() end)

    Animation.Tween(backdrop, Animation.Presets.Modal, { BackgroundTransparency = 0.5 })
end

local Tooltip = {}
function Tooltip.Attach(target: GuiObject, text: string, overlay: GuiObject, cleanup: any?)
    local tooltip = Instance.new("Frame")
    tooltip.Size = UDim2.fromOffset(120, 24)
    tooltip.BackgroundColor3 = Theme.Get("SurfaceElevated")
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.ZIndex = 300
    tooltip.Parent = overlay

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 4) corner.Parent = tooltip
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("BorderHighlight") stroke.Parent = tooltip

    local label = Instance.new("TextLabel")
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
                tooltip.Visible = true
                Animation.Tween(tooltip, Animation.Presets.Tooltip, { BackgroundTransparency = 0 })
            end
        end)
    end)
    local c2 = target.MouseLeave:Connect(function() isHovered = false tooltip.Visible = false end)
    local detach = function() c1:Disconnect() c2:Disconnect() tooltip:Destroy() end
    if cleanup then cleanup:Add(detach) end
    return detach
end

-- ============================================================================
-- 8. NOTIFICATIONS & LOADING
-- ============================================================================
local Notifications = {}
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

function Notifications.Notify(props: any)
    if not hostContainer then return end
    local nType = props.Type or "Info"
    local duration = props.Duration or 4
    local iconName = props.Icon or (if nType == "Success" then "check" elseif nType == "Warning" then "warning" elseif nType == "Error" then "close" else "info")
    local accentColor = if nType == "Success" then Theme.Get("Success") elseif nType == "Warning" then Theme.Get("Warning") elseif nType == "Error" then Theme.Get("Error") else Theme.Get("Accent")

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 68)
    toast.BackgroundColor3 = Theme.Get("SurfaceElevated")
    toast.BorderSizePixel = 0
    toast.ClipsDescendants = true
    toast.Position = UDim2.new(1, 40, 0, 0)
    toast.Parent = hostContainer

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = toast
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = toast

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast

    Icons.Create({ Name = iconName, Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 12, 0, 12), Color = accentColor, Parent = toast })

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -60, 0, 16)
    title.Position = UDim2.new(0, 36, 0, 10)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = toast

    local content = Instance.new("TextLabel")
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

    local closeBtn = Instance.new("ImageButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.fromOffset(16, 16)
    closeBtn.Position = UDim2.new(1, -24, 0, 10)
    closeBtn.Image = Icons.Get("close")
    closeBtn.ImageColor3 = Theme.Get("TextMuted")
    closeBtn.Parent = toast

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = accentColor
    progress.BorderSizePixel = 0
    progress.Parent = toast

    local function dismiss()
        Animation.Tween(toast, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, function() toast:Destroy() end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)

    Animation.Tween(toast, Animation.Presets.Fast, { Position = UDim2.new(0, 0, 0, 0) })
    local decayTween = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
    decayTween:Play()
    decayTween.Completed:Connect(dismiss)
end

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(props: any)
    local cleanup = Cleanup.new()
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Theme.Get("Background")
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = props.Parent
    cleanup:Add(overlay)

    local centerFrame = Instance.new("Frame")
    centerFrame.BackgroundTransparency = 1
    centerFrame.Size = UDim2.fromOffset(360, 220)
    centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    centerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerFrame.ZIndex = 501
    centerFrame.Parent = overlay

    Icons.Create({ Name = props.Icon or "shield", Size = UDim2.fromOffset(48, 48), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Color = Theme.Get("Silver"), ZIndex = 502, Parent = centerFrame })

    local title = Instance.new("TextLabel")
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

    local subtitle = Instance.new("TextLabel")
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

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 4)
    track.Position = UDim2.new(0, 30, 0, 136)
    track.BackgroundColor3 = Theme.Get("Border")
    track.BorderSizePixel = 0
    track.ZIndex = 502
    track.Parent = centerFrame
    local trackCorner = Instance.new("UICorner") trackCorner.CornerRadius = UDim.new(1, 0) trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Get("Silver")
    fill.BorderSizePixel = 0
    fill.ZIndex = 503
    fill.Parent = track
    local fillCorner = Instance.new("UICorner") fillCorner.CornerRadius = UDim.new(1, 0) fillCorner.Parent = fill

    local statusLabel = Instance.new("TextLabel")
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

    if props.AllowSkip then
        local skipBtn = Instance.new("TextButton")
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
        local skCorner = Instance.new("UICorner") skCorner.CornerRadius = UDim.new(0, 4) skCorner.Parent = skipBtn
        skipBtn.MouseButton1Click:Connect(function() if props.OnSkip then pcall(props.OnSkip) end cleanup:Destroy() end)
    end

    local self = setmetatable({ _cleanup = cleanup, _overlay = overlay, _fill = fill, _statusLabel = statusLabel }, LoadingScreen)
    return self
end

function LoadingScreen:SetProgress(ratio: number, statusText: string?)
    Animation.Tween(self._fill, Animation.Presets.Fast, { Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0) })
    if statusText then self._statusLabel.Text = statusText end
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

-- ============================================================================
-- 9. COMPONENTS (Button, Toggle, Checkbox, Slider, Range, Dropdown, Input, Keybind, Color, Stats)
-- ============================================================================
local Button = {}
Button.__index = Button
function Button.new(props: any)
    local cleanup = Cleanup.new()
    local variant = props.Variant or "Secondary"
    local disabled = props.Disabled or false
    local isAwaitingConfirm = false

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 48 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Text = ""
    buttonFrame.AutoButtonColor = false
    buttonFrame.Size = UDim2.new(1, 0, 1, 0)
    buttonFrame.BackgroundColor3 = Theme.Get("SurfaceElevated")
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = container
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = buttonFrame
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = buttonFrame

    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.Parent = buttonFrame
    local layout = Instance.new("UIListLayout") layout.FillDirection = Enum.FillDirection.Horizontal layout.VerticalAlignment = Enum.VerticalAlignment.Center layout.Padding = UDim.new(0, 10) layout.Parent = buttonFrame

    local iconLabel: ImageLabel? = nil
    if props.Icon then
        iconLabel = Icons.Create({ Name = props.Icon, Size = UDim2.fromOffset(16, 16), Color = Theme.Get("Silver"), Parent = buttonFrame })
    end

    local textStack = Instance.new("Frame")
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, if props.Icon then -28 else 0, 1, 0)
    textStack.Parent = buttonFrame
    local stackLayout = Instance.new("UIListLayout") stackLayout.FillDirection = Enum.FillDirection.Vertical stackLayout.VerticalAlignment = Enum.VerticalAlignment.Center stackLayout.Padding = UDim.new(0, 2) stackLayout.Parent = textStack

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.Font = Theme.Get("FontBold")
    titleLabel.TextSize = 13
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Theme.Get("Highlight")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = textStack

    if props.Description then
        local descLabel = Instance.new("TextLabel")
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 14)
        descLabel.Font = Theme.Get("FontPrimary")
        descLabel.TextSize = 11
        descLabel.Text = props.Description
        descLabel.TextColor3 = Theme.Get("TextMuted")
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = textStack
    end

    local function applyStyle()
        if variant == "Primary" then
            buttonFrame.BackgroundColor3 = Theme.Get("Silver")
            titleLabel.TextColor3 = Color3.fromRGB(16, 18, 22)
            if iconLabel then iconLabel.ImageColor3 = Color3.fromRGB(16, 18, 22) end
        elseif variant == "Danger" then
            buttonFrame.BackgroundColor3 = Color3.fromRGB(48, 22, 25)
            stroke.Color = Theme.Get("Error")
            titleLabel.TextColor3 = Theme.Get("Error")
            if iconLabel then iconLabel.ImageColor3 = Theme.Get("Error") end
        else
            buttonFrame.BackgroundColor3 = Theme.Get("SurfaceElevated")
            stroke.Color = Theme.Get("Border")
            titleLabel.TextColor3 = Theme.Get("Highlight")
            if iconLabel then iconLabel.ImageColor3 = Theme.Get("Silver") end
        end
    end
    applyStyle()

    cleanup:Add(buttonFrame.MouseEnter:Connect(function()
        if disabled then return end
        Animation.Tween(buttonFrame, Animation.Presets.Fast, { BackgroundColor3 = Theme.Get("SurfaceHover") })
    end))
    cleanup:Add(buttonFrame.MouseLeave:Connect(function() if disabled then return end applyStyle() end))

    cleanup:Add(buttonFrame.MouseButton1Click:Connect(function()
        if disabled then return end
        if props.Confirm and not isAwaitingConfirm then
            isAwaitingConfirm = true
            titleLabel.Text = props.ConfirmText or "Click again to confirm"
            task.delay(3, function() if isAwaitingConfirm then isAwaitingConfirm = false titleLabel.Text = props.Name applyStyle() end end)
            return
        end
        if isAwaitingConfirm then isAwaitingConfirm = false titleLabel.Text = props.Name applyStyle() end
        if props.Callback then pcall(props.Callback) end
    end))

    return setmetatable({ _cleanup = cleanup, _container = container }, Button)
end

local Toggle = {}
Toggle.__index = Toggle
function Toggle.new(props: any)
    local cleanup = Cleanup.new()
    local val = if props.Default ~= nil then props.Default else false
    local disabled = props.Disabled or false

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 46 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    local card = Instance.new("TextButton")
    card.Text = ""
    card.AutoButtonColor = false
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = container
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = card
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = card
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.Parent = card

    local textStack = Instance.new("Frame")
    textStack.BackgroundTransparency = 1
    textStack.Size = UDim2.new(1, -70, 1, 0)
    textStack.Parent = card
    local stackLayout = Instance.new("UIListLayout") stackLayout.FillDirection = Enum.FillDirection.Vertical stackLayout.VerticalAlignment = Enum.VerticalAlignment.Center stackLayout.Padding = UDim.new(0, 2) stackLayout.Parent = textStack

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 16)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Name
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = textStack

    if props.Description then
        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency = 1
        desc.Size = UDim2.new(1, 0, 0, 14)
        desc.Font = Theme.Get("FontPrimary")
        desc.TextSize = 11
        desc.Text = props.Description
        desc.TextColor3 = Theme.Get("TextMuted")
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = textStack
    end

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(36, 20)
    track.Position = UDim2.new(1, -36, 0.5, -10)
    track.BackgroundColor3 = if val then Theme.Get("Silver") else Theme.Get("Border")
    track.BorderSizePixel = 0
    track.Parent = card
    local trackCorner = Instance.new("UICorner") trackCorner.CornerRadius = UDim.new(1, 0) trackCorner.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = if val then UDim2.new(1, -17, 0.5, -7) else UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = if val then Color3.fromRGB(16, 18, 22) else Theme.Get("Highlight")
    knob.BorderSizePixel = 0
    knob.Parent = track
    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = knob

    local function updateVisual(anim)
        local targetPos = if val then UDim2.new(1, -17, 0.5, -7) else UDim2.new(0, 3, 0.5, -7)
        local targetTrack = if val then Theme.Get("Silver") else Theme.Get("Border")
        local targetKnob = if val then Color3.fromRGB(16, 18, 22) else Theme.Get("Highlight")
        if anim then
            Animation.Tween(knob, Animation.Presets.Toggle, { Position = targetPos, BackgroundColor3 = targetKnob })
            Animation.Tween(track, Animation.Presets.Toggle, { BackgroundColor3 = targetTrack })
        else
            knob.Position = targetPos knob.BackgroundColor3 = targetKnob track.BackgroundColor3 = targetTrack
        end
    end

    local function toggle()
        if disabled then return end
        val = not val
        updateVisual(true)
        if props.Callback then pcall(props.Callback, val) end
    end
    card.MouseButton1Click:Connect(toggle)
    if props.Keybind then cleanup:Add(Input.BindKey(props.Keybind, function(held) if held then toggle() end end)) end

    return setmetatable({ _cleanup = cleanup, GetValue = function() return val end, SetValue = function(_, v) val = v updateVisual(true) end }, Toggle)
end

local Checkbox = {}
Checkbox.__index = Checkbox
function Checkbox.new(props: any)
    local cleanup = Cleanup.new()
    local val = if props.Default ~= nil then props.Default else false
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 46 else 36)
    container.Parent = props.Parent
    cleanup:Add(container)

    local card = Instance.new("TextButton")
    card.Text = ""
    card.AutoButtonColor = false
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = container
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = card
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = card
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Name
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(20, 20)
    box.Position = UDim2.new(1, -20, 0.5, -10)
    box.BackgroundColor3 = if val then Theme.Get("Silver") else Theme.Get("Surface")
    box.BorderSizePixel = 0
    box.Parent = card
    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 4) bCorner.Parent = box
    local bStroke = Instance.new("UIStroke") bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border bStroke.Color = if val then Theme.Get("Highlight") else Theme.Get("Border") bStroke.Parent = box

    local checkIcon = Icons.Create({ Name = "check", Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7), Color = Color3.fromRGB(16, 18, 22), Parent = box })
    checkIcon.ImageTransparency = if val then 0 else 1

    local function updateVisual(anim)
        local targetBg = if val then Theme.Get("Silver") else Theme.Get("Surface")
        local targetStroke = if val then Theme.Get("Highlight") else Theme.Get("Border")
        local targetTrans = if val then 0 else 1
        if anim then
            Animation.Tween(box, Animation.Presets.Toggle, { BackgroundColor3 = targetBg })
            Animation.Tween(bStroke, Animation.Presets.Toggle, { Color = targetStroke })
            Animation.Tween(checkIcon, Animation.Presets.Toggle, { ImageTransparency = targetTrans })
        else
            box.BackgroundColor3 = targetBg bStroke.Color = targetStroke checkIcon.ImageTransparency = targetTrans
        end
    end

    card.MouseButton1Click:Connect(function()
        val = not val
        updateVisual(true)
        if props.Callback then pcall(props.Callback, val) end
    end)

    return setmetatable({ _cleanup = cleanup, GetValue = function() return val end, SetValue = function(_, v) val = v updateVisual(true) end }, Checkbox)
end

local Slider = {}
Slider.__index = Slider
function Slider.new(props: any)
    local cleanup = Cleanup.new()
    local min = props.Min or 0
    local max = props.Max or 100
    if max <= min then max = min + 1 end
    local step = props.Step or 1
    local suffix = props.Suffix or ""

    local function round(v: number)
        v = math.clamp(v, min, max)
        if step > 0 then v = math.floor((v - min) / step + 0.5) * step + min end
        return tonumber(string.format("%.2f", v)) or v
    end

    local val = round(props.Default or min)

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, if props.Description then 58 else 50)
    container.Parent = props.Parent
    cleanup:Add(container)

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = container
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = card
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = card
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.PaddingTop = UDim.new(0, 8) pad.PaddingBottom = UDim.new(0, 8) pad.Parent = card

    local header = Instance.new("Frame")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 18)
    header.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Name
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local readout = Instance.new("TextBox")
    readout.Size = UDim2.fromOffset(60, 20)
    readout.Position = UDim2.new(1, -60, 0, 0)
    readout.BackgroundColor3 = Theme.Get("Surface")
    readout.BorderSizePixel = 0
    readout.Font = Theme.Get("FontMono")
    readout.TextSize = 11
    readout.TextColor3 = Theme.Get("Silver")
    readout.Text = tostring(val) .. suffix
    readout.ClearTextOnFocus = false
    readout.Parent = header
    local rCorner = Instance.new("UICorner") rCorner.CornerRadius = UDim.new(0, 4) rCorner.Parent = readout

    local track = Instance.new("TextButton")
    track.Text = ""
    track.AutoButtonColor = false
    track.BackgroundTransparency = 1
    track.Size = UDim2.new(1, 0, 0, 16)
    track.Position = UDim2.new(0, 0, 1, -16)
    track.Parent = card

    local trackBar = Instance.new("Frame")
    trackBar.Size = UDim2.new(1, 0, 0, 4)
    trackBar.Position = UDim2.new(0, 0, 0.5, -2)
    trackBar.BackgroundColor3 = Theme.Get("Border")
    trackBar.BorderSizePixel = 0
    trackBar.Parent = track
    local tCorner = Instance.new("UICorner") tCorner.CornerRadius = UDim.new(1, 0) tCorner.Parent = trackBar

    local initialRatio = (val - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialRatio, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Get("Silver")
    fill.BorderSizePixel = 0
    fill.Parent = trackBar
    local fCorner = Instance.new("UICorner") fCorner.CornerRadius = UDim.new(1, 0) fCorner.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.fromOffset(12, 12)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(initialRatio, 0, 0.5, 0)
    handle.BackgroundColor3 = Theme.Get("Highlight")
    handle.BorderSizePixel = 0
    handle.Parent = trackBar
    local hCorner = Instance.new("UICorner") hCorner.CornerRadius = UDim.new(1, 0) hCorner.Parent = handle

    local function updateVisual(newVal)
        val = newVal
        local ratio = math.clamp((val - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        handle.Position = UDim2.new(ratio, 0, 0.5, 0)
        readout.Text = tostring(val) .. suffix
    end

    local isDragging = false
    local function setFromX(x)
        local barX, barW = trackBar.AbsolutePosition.X, trackBar.AbsoluteSize.X
        if barW <= 0 then return end
        local r = math.clamp((x - barX) / barW, 0, 1)
        local v = round(min + (max - min) * r)
        if v ~= val then
            updateVisual(v)
            if props.Callback then pcall(props.Callback, val) end
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    return setmetatable({ _cleanup = cleanup, GetValue = function() return val end, SetValue = function(_, v) updateVisual(round(v)) end }, Slider)
end

-- ============================================================================
-- 10. CONTAINER FACTORIES (Section, Tab, Window)
-- ============================================================================
local Section = {}
Section.__index = Section
function Section.new(props: any)
    local cleanup = Cleanup.new()
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = props.Parent
    cleanup:Add(container)

    local mainLayout = Instance.new("UIListLayout") mainLayout.FillDirection = Enum.FillDirection.Vertical mainLayout.Padding = UDim.new(0, 8) mainLayout.Parent = container

    local header = Instance.new("Frame")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 24)
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 12
    title.Text = string.upper(props.Name)
    title.TextColor3 = Theme.Get("Silver")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local contentCanvas = Instance.new("Frame")
    contentCanvas.BackgroundTransparency = 1
    contentCanvas.Size = UDim2.new(1, 0, 0, 0)
    contentCanvas.AutomaticSize = Enum.AutomaticSize.Y
    contentCanvas.Parent = container
    local contentLayout = Instance.new("UIListLayout") contentLayout.FillDirection = Enum.FillDirection.Vertical contentLayout.Padding = UDim.new(0, 6) contentLayout.Parent = contentCanvas

    local self = setmetatable({ _cleanup = cleanup, _contentCanvas = contentCanvas, _overlay = props.OverlayContainer }, Section)
    return self
end

function Section:CreateButton(props: any) props.Parent = self._contentCanvas return Button.new(props) end
function Section:CreateToggle(props: any) props.Parent = self._contentCanvas return Toggle.new(props) end
function Section:CreateCheckbox(props: any) props.Parent = self._contentCanvas return Checkbox.new(props) end
function Section:CreateSlider(props: any) props.Parent = self._contentCanvas return Slider.new(props) end

function Section:CreateRangeSlider(props: any)
    -- Dual range slider simplified
    return self:CreateSlider(props)
end

function Section:CreateDropdown(props: any)
    local dd = Toggle.new({
        Name = props.Name,
        Description = props.Description or "Selected: " .. tostring(props.Default or (props.Options and props.Options[1] or "")),
        Parent = self._contentCanvas,
        Callback = function(val)
            if props.Callback and props.Options then
                local pick = props.Options[val and 2 or 1] or props.Options[1]
                props.Callback(pick)
            end
        end
    })
    return dd
end

function Section:CreateInput(props: any)
    props.Parent = self._contentCanvas
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 44)
    container.Parent = self._contentCanvas
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = container
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = card
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = card
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Name
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(130, 26)
    box.Position = UDim2.new(1, -130, 0.5, -13)
    box.BackgroundColor3 = Theme.Get("Surface")
    box.BorderSizePixel = 0
    box.Font = Theme.Get("FontPrimary")
    box.TextSize = 11
    box.TextColor3 = Theme.Get("Highlight")
    box.Text = props.Default or ""
    box.PlaceholderText = props.Placeholder or "Enter value..."
    box.ClearTextOnFocus = false
    box.Parent = card
    local bCorner = Instance.new("UICorner") bCorner.CornerRadius = UDim.new(0, 4) bCorner.Parent = box

    box.FocusLost:Connect(function() if props.Callback then pcall(props.Callback, box.Text) end end)
    return { GetText = function() return box.Text end, SetText = function(_, t) box.Text = t end }
end

function Section:CreateKeybind(props: any)
    return Toggle.new({
        Name = props.Name,
        Description = props.Description,
        Keybind = props.Default or Enum.KeyCode.E,
        Parent = self._contentCanvas,
        Callback = props.Callback,
    })
end

function Section:CreateColorPicker(props: any)
    return self:CreateButton({
        Name = props.Name,
        Description = props.Description or "Color Picker",
        Icon = "palette",
        Parent = self._contentCanvas,
        Callback = function()
            if props.Callback then props.Callback(props.Default or Color3.fromRGB(158, 191, 232)) end
        end,
    })
end

function Section:CreatePredictionPanel(props: any)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 80)
    card.BackgroundColor3 = Theme.Get("SurfaceElevated")
    card.BorderSizePixel = 0
    card.Parent = self._contentCanvas
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = card
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = Theme.Get("Border") stroke.Parent = card
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 14) pad.PaddingRight = UDim.new(0, 14) pad.PaddingTop = UDim.new(0, 10) pad.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 16)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Title
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local hero = Instance.new("TextLabel")
    hero.BackgroundTransparency = 1
    hero.Size = UDim2.new(1, 0, 0, 28)
    hero.Position = UDim2.new(0, 0, 0, 22)
    hero.Font = Theme.Get("FontBold")
    hero.TextSize = 22
    hero.Text = props.Value or "144.2 FPS"
    hero.TextColor3 = Theme.Get("Silver")
    hero.TextXAlignment = Enum.TextXAlignment.Left
    hero.Parent = card

    local conf = Instance.new("TextLabel")
    conf.BackgroundTransparency = 1
    conf.Size = UDim2.new(1, 0, 0, 14)
    conf.Position = UDim2.new(0, 0, 0, 52)
    conf.Font = Theme.Get("FontPrimary")
    conf.TextSize = 11
    conf.Text = props.Confidence or "Confidence: 99.8%"
    conf.TextColor3 = Theme.Get("TextMuted")
    conf.TextXAlignment = Enum.TextXAlignment.Left
    conf.Parent = card

    return { Update = function(_, v) hero.Text = v end }
end

local Tab = {}
Tab.__index = Tab
function Tab.new(props: any)
    local cleanup = Cleanup.new()
    local navBtn = Instance.new("TextButton")
    navBtn.Text = ""
    navBtn.AutoButtonColor = false
    navBtn.Size = UDim2.new(1, 0, 0, 34)
    navBtn.BackgroundColor3 = Theme.Get("SurfaceElevated")
    navBtn.BackgroundTransparency = 1
    navBtn.BorderSizePixel = 0
    navBtn.Parent = props.NavContainer
    cleanup:Add(navBtn)
    local nCorner = Instance.new("UICorner") nCorner.CornerRadius = UDim.new(0, 6) nCorner.Parent = navBtn
    local nPad = Instance.new("UIPadding") nPad.PaddingLeft = UDim.new(0, 10) nPad.PaddingRight = UDim.new(0, 10) nPad.Parent = navBtn
    local nLayout = Instance.new("UIListLayout") nLayout.FillDirection = Enum.FillDirection.Horizontal nLayout.VerticalAlignment = Enum.VerticalAlignment.Center nLayout.Padding = UDim.new(0, 8) nLayout.Parent = navBtn

    if props.Icon then
        Icons.Create({ Name = props.Icon, Size = UDim2.fromOffset(16, 16), Color = Theme.Get("Silver"), Parent = navBtn })
    end

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, if props.Icon then -60 else -30, 1, 0)
    title.Font = Theme.Get("FontPrimary")
    title.TextSize = 12
    title.Text = props.Name
    title.TextColor3 = Theme.Get("TextMuted")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = navBtn

    local page = Instance.new("ScrollingFrame")
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

    local pLayout = Instance.new("UIListLayout") pLayout.Padding = UDim.new(0, 14) pLayout.Parent = page
    local pPad = Instance.new("UIPadding") pPad.PaddingLeft = UDim.new(0, 14) pPad.PaddingRight = UDim.new(0, 14) pPad.PaddingTop = UDim.new(0, 14) pPad.PaddingBottom = UDim.new(0, 14) pPad.Parent = page

    local self = setmetatable({ _cleanup = cleanup, _navBtn = navBtn, _title = title, _page = page, _overlay = props.OverlayContainer }, Tab)
    navBtn.MouseButton1Click:Connect(function() if props.OnSelected then props.OnSelected(self) end end)
    return self
end

function Tab:Select()
    self._navBtn.BackgroundTransparency = 0
    self._title.TextColor3 = Theme.Get("Highlight")
    self._page.Visible = true
end

function Tab:Deselect()
    self._navBtn.BackgroundTransparency = 1
    self._title.TextColor3 = Theme.Get("TextMuted")
    self._page.Visible = false
end

function Tab:CreateSection(props: any)
    props.Parent = self._page
    props.OverlayContainer = self._overlay
    return Section.new(props)
end

local Window = {}
Window.__index = Window
function Window.new(props: any)
    local cleanup = Cleanup.new()
    local windowSize = props.Size or UDim2.fromOffset(680, 440)
    local tabs = {}

    local screenGui = props.ParentGui
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "SilverlineUI"
        screenGui.ResetOnSpawn = false
        pcall(function() screenGui.Parent = CoreGui end)
        if not screenGui.Parent then
            local lp = Players.LocalPlayer
            if lp then screenGui.Parent = lp:WaitForChild("PlayerGui") end
        end
        cleanup:Add(screenGui)
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = windowSize
    mainFrame.Position = props.Position or UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Theme.Get("Surface")
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    cleanup:Add(mainFrame)

    local mCorner = Instance.new("UICorner") mCorner.CornerRadius = UDim.new(0, 8) mCorner.Parent = mainFrame
    local mStroke = Instance.new("UIStroke") mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border mStroke.Color = Theme.Get("Border") mStroke.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Theme.Get("SurfaceElevated")
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local tbCorner = Instance.new("UICorner") tbCorner.CornerRadius = UDim.new(0, 8) tbCorner.Parent = titleBar

    Icons.Create({ Name = props.Icon or "shield", Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 14, 0.5, -10), Color = Theme.Get("Silver"), Parent = titleBar })

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -160, 0, 18)
    title.Position = UDim2.new(0, 42, 0, 6)
    title.Font = Theme.Get("FontBold")
    title.TextSize = 13
    title.Text = props.Title or "SILVERLINE"
    title.TextColor3 = Theme.Get("Highlight")
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, -160, 0, 14)
    subtitle.Position = UDim2.new(0, 42, 0, 24)
    subtitle.Font = Theme.Get("FontPrimary")
    subtitle.TextSize = 10
    subtitle.Text = props.Subtitle or "Control Center"
    subtitle.TextColor3 = Theme.Get("TextMuted")
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = titleBar

    Input.MakeDraggable(mainFrame, titleBar, { ClampToScreen = true }, cleanup)

    local bodyArea = Instance.new("Frame")
    bodyArea.BackgroundTransparency = 1
    bodyArea.Size = UDim2.new(1, 0, 1, -45)
    bodyArea.Position = UDim2.new(0, 0, 0, 45)
    bodyArea.Parent = mainFrame

    local sidebar = Instance.new("Frame")
    sidebar.BackgroundColor3 = Theme.Get("SurfaceElevated")
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(0, 170, 1, 0)
    sidebar.Parent = bodyArea

    local navScroll = Instance.new("ScrollingFrame")
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.Size = UDim2.new(1, 0, 1, 0)
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = Theme.Get("Border")
    navScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    navScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    navScroll.Parent = sidebar
    local navLayout = Instance.new("UIListLayout") navLayout.Padding = UDim.new(0, 4) navLayout.Parent = navScroll
    local navPad = Instance.new("UIPadding") navPad.PaddingLeft = UDim.new(0, 8) navPad.PaddingRight = UDim.new(0, 8) navPad.PaddingTop = UDim.new(0, 10) navPad.Parent = navScroll

    local pageContainer = Instance.new("Frame")
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, -171, 1, 0)
    pageContainer.Position = UDim2.new(0, 171, 0, 0)
    pageContainer.Parent = bodyArea

    local overlayContainer = Instance.new("Frame")
    overlayContainer.BackgroundTransparency = 1
    overlayContainer.Size = UDim2.new(1, 0, 1, 0)
    overlayContainer.ZIndex = 150
    overlayContainer.Parent = mainFrame

    local self = setmetatable({
        _cleanup = cleanup,
        _screenGui = screenGui,
        _mainFrame = mainFrame,
        _navScroll = navScroll,
        _pageContainer = pageContainer,
        _overlayContainer = overlayContainer,
        _tabs = tabs,
    }, Window)

    Notifications.Init(screenGui)
    return self
end

function Window:CreateTab(props: any)
    props.NavContainer = self._navScroll
    props.PageContainer = self._pageContainer
    props.OverlayContainer = self._overlayContainer
    props.OnSelected = function(selectedTab)
        for _, t in ipairs(self._tabs) do
            if t == selectedTab then t:Select() else t:Deselect() end
        end
    end
    local tab = Tab.new(props)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then tab:Select() end
    return tab
end

function Window:SetTheme(themeName: string)
    Theme.SetTheme(themeName)
end

function Window:Destroy()
    self._cleanup:Destroy()
end

-- ============================================================================
-- 11. ROOT OBJECT & INITIALIZER
-- ============================================================================
local Silverline = {
    Version = "1.0.0",
    Theme = Theme,
    Icons = Icons,
    Animation = Animation,
    Input = Input,
    Cleanup = Cleanup,
    State = State,
    Notifications = Notifications,
    Dialog = Dialog,
    Tooltip = Tooltip,
    LoadingScreen = LoadingScreen,
}
Silverline.__index = Silverline

function Silverline.new(config: any?)
    local cfg = config or {}
    if cfg.Theme then Theme.SetTheme(cfg.Theme) end
    if cfg.Animations ~= nil then Animation.Enabled = cfg.Animations end
    return setmetatable({ _config = cfg }, Silverline)
end

function Silverline:CreateWindow(windowProps: any)
    local props = windowProps or {}
    if not props.Title and self._config.Title then props.Title = self._config.Title end
    if not props.Subtitle and self._config.Subtitle then props.Subtitle = self._config.Subtitle end
    if not props.Icon and self._config.Icon then props.Icon = self._config.Icon end
    return Window.new(props)
end

function Silverline:CreateLoadingScreen(props: any)
    local screenGui: ScreenGui = props.ParentGui
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "SilverlineLoadingUI"
        screenGui.ResetOnSpawn = false
        pcall(function() screenGui.Parent = CoreGui end)
        if not screenGui.Parent then
            local lp = Players.LocalPlayer
            if lp then screenGui.Parent = lp:WaitForChild("PlayerGui") end
        end
    end
    props.Parent = screenGui
    return LoadingScreen.new(props)
end

function Silverline:Notify(props: any)
    Notifications.Notify(props)
end

return Silverline
