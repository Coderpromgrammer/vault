--!strict
--[=[
    ███████╗██╗██╗     ██╗   ██╗███████╗██████╗ ██╗     ██╗███╗   ██╗███████╗
    ██╔════╝██║██║     ██║   ██║██╔════╝██╔══██╗██║     ██║████╗  ██║██╔════╝
    ███████╗██║██║     ██║   ██║█████╗  ██████╔╝██║     ██║██╔██╗ ██║█████╗  
    ╚════██║██║██║     ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║     ██║██║╚██╗██║██╔══╝  
    ███████║██║███████╗ ╚████╔╝ ███████╗██║  ██║███████╗██║██║ ╚████║███████╗
    ╚══════╝╚═╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝

    Silverline UI Framework v1.0.0
    A Premium, Lightweight Roblox Luau UI Framework with Satin Silver Aesthetics.
]=]

local Core = script:WaitForChild("Core")
local Systems = script:WaitForChild("Systems")
local Components = script:WaitForChild("Components")

local Window = require(Core:WaitForChild("Window"))
local State = require(Core:WaitForChild("State"))
local Theme = require(Systems:WaitForChild("Theme"))
local Icons = require(Systems:WaitForChild("Icons"))
local Animation = require(Systems:WaitForChild("Animation"))
local Input = require(Systems:WaitForChild("Input"))
local Cleanup = require(Systems:WaitForChild("Cleanup"))

local Notifications = require(Components:WaitForChild("Notifications"))
local Dialog = require(Components:WaitForChild("Dialog"))
local Tooltip = require(Components:WaitForChild("Tooltip"))
local LoadingScreen = require(Components:WaitForChild("LoadingScreen"))

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

export type AppConfig = {
    Title: string?,
    Subtitle: string?,
    Theme: string?,
    Animations: boolean?,
    Icon: string?,
    ParentGui: ScreenGui?,
}

function Silverline.new(config: AppConfig?)
    local cfg = config or {}

    if cfg.Theme then
        Theme.SetTheme(cfg.Theme)
    end

    if cfg.Animations ~= nil then
        Animation.Enabled = cfg.Animations
    end

    local self = setmetatable({
        _config = cfg,
    }, Silverline)

    return self
end

function Silverline:CreateWindow(windowProps: any): any
    local props = windowProps or {}
    if not props.Title and self._config.Title then
        props.Title = self._config.Title
    end
    if not props.Subtitle and self._config.Subtitle then
        props.Subtitle = self._config.Subtitle
    end
    if not props.Icon and self._config.Icon then
        props.Icon = self._config.Icon
    end
    if not props.ParentGui and self._config.ParentGui then
        props.ParentGui = self._config.ParentGui
    end

    local win = Window.new(props)

    -- Initialize notifications on the window's ScreenGui
    Notifications.Init(win._screenGui)

    return win
end

function Silverline:CreateLoadingScreen(props: any): any
    return LoadingScreen.new(props)
end

function Silverline:Notify(props: any)
    Notifications.Notify(props)
end

return Silverline
