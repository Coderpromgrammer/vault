--!strict
--[=[
    Silverline UI Framework
    Module: Systems/Theme.lua
    Purpose: Centralized theme token system with dynamic runtime updates.
]=]

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
        Background      = Color3.fromRGB(16, 18, 22),   -- #101216: Canvas base
        Surface         = Color3.fromRGB(23, 26, 32),   -- #171A20: Main window background
        SurfaceElevated = Color3.fromRGB(32, 36, 43),   -- #20242B: Cards, controls, header
        SurfaceHover    = Color3.fromRGB(42, 48, 58),   -- #2A303A: Hover state
        SurfaceActive   = Color3.fromRGB(52, 60, 72),   -- #343C48: Active/pressed state
        Silver          = Color3.fromRGB(198, 204, 213),-- #C6CCD5: Satin silver brand metal
        Highlight       = Color3.fromRGB(243, 245, 248),-- #F3F5F8: Primary readable text
        TextMuted       = Color3.fromRGB(146, 154, 167),-- #929AA7: Secondary labels & hints
        TextDisabled    = Color3.fromRGB(90, 96, 106),  -- #5A606A: Disabled text
        Border          = Color3.fromRGB(52, 59, 70),   -- #343B46: Fine satin borders
        BorderHighlight = Color3.fromRGB(130, 140, 155),-- #828C9B: Focused border accent
        Accent          = Color3.fromRGB(158, 191, 232),-- #9EBFE8: Restrained steel-blue
        AccentHover     = Color3.fromRGB(180, 208, 245),
        Success         = Color3.fromRGB(110, 205, 145),-- Muted emerald
        Warning         = Color3.fromRGB(235, 185, 95), -- Muted amber
        Error           = Color3.fromRGB(235, 95, 95),   -- Muted crimson
        Overlay         = Color3.fromRGB(8, 9, 12),     -- Backdrop overlay
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
    if val ~= nil then
        return val
    end
    -- Fallback to DarkSilver if token not present in custom theme
    return (Themes.DarkSilver :: any)[token]
end

function Theme.GetCurrentThemeName(): string
    return currentThemeName
end

function Theme.GetTokens(): ThemeTokens
    return currentThemeTokens
end

function Theme.RegisterTheme(name: string, tokens: ThemeTokens)
    assert(type(name) == "string", "Theme name must be a string")
    assert(type(tokens) == "table", "Theme tokens must be a table")
    Themes[name] = tokens
end

function Theme.SetTheme(themeNameOrTable: string | ThemeTokens)
    if type(themeNameOrTable) == "string" then
        local found = Themes[themeNameOrTable]
        if not found then
            warn("[Silverline Theme] Theme '" .. themeNameOrTable .. "' not found. Falling back to DarkSilver.")
            found = Themes.DarkSilver
            currentThemeName = "DarkSilver"
        else
            currentThemeName = themeNameOrTable
        end
        currentThemeTokens = found
    elseif type(themeNameOrTable) == "table" then
        currentThemeName = "Custom"
        currentThemeTokens = themeNameOrTable :: ThemeTokens
    end

    -- Update all bound UI objects
    for instance, propMap in pairs(boundElements) do
        if instance and instance.Parent then
            for propName, tokenName in pairs(propMap) do
                local tokenVal = Theme.Get(tokenName)
                if tokenVal ~= nil then
                    pcall(function()
                        (instance :: any)[propName] = tokenVal
                    end)
                end
            end
        else
            boundElements[instance] = nil
        end
    end

    -- Notify listeners
    for _, callback in ipairs(listeners) do
        pcall(callback, currentThemeName, currentThemeTokens)
    end
end

function Theme.Bind(instance: Instance, propertyMap: { [string]: string }): () -> ()
    boundElements[instance] = propertyMap

    -- Apply current values immediately
    for propName, tokenName in pairs(propertyMap) do
        local tokenVal = Theme.Get(tokenName)
        if tokenVal ~= nil then
            pcall(function()
                (instance :: any)[propName] = tokenVal
            end)
        end
    end

    -- Return unbind function
    return function()
        boundElements[instance] = nil
    end
end

function Theme.OnThemeChanged(callback: (string, ThemeTokens) -> ()): () -> ()
    table.insert(listeners, callback)
    return function()
        local idx = table.find(listeners, callback)
        if idx then
            table.remove(listeners, idx)
        end
    end
end

return Theme
