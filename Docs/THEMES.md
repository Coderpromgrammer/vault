# Silverline Theming & Design Tokens

Silverline features a token-driven theme system with live cascade updates. Changing the theme alters all bound components instantly without requiring the developer to reconstruct the interface.

---

## 1. Built-in Theme Presets

### `DarkSilver` (Default)
Our signature satin-silver and graphite aesthetic.
- **Background**: `#101216` (Deep charcoal canvas)
- **Surface**: `#171A20` (Window main background)
- **SurfaceElevated**: `#20242B` (Cards, dropdowns, headers)
- **Silver**: `#C6CCD5` (Satin silver metallic text & active details)
- **Highlight**: `#F3F5F8` (High-contrast bright headers)
- **Border**: `#343B46` (Restrained fine outlines)
- **Accent**: `#9EBFE8` (Subtle steel-blue highlights)

### `LightSilver`
Clean, professional metallic silver day-mode.
- High readability in bright studio viewports.

### `Obsidian`
Pitch-graphite dark theme with muted silver accents.

### `Platinum`
High-luminance satin steel with crisp blue-tinted borders.

---

## 2. Switching Themes at Runtime

Switching themes is straightforward:

```lua
-- Via window method:
window:SetTheme("LightSilver")

-- Or directly through the Theme module:
local Theme = require(Silverline.Systems.Theme)
Theme.SetTheme("Obsidian")
```

All existing controls, borders, labels, and icons bound to theme tokens update immediately.

---

## 3. Registering Custom Themes

You can register custom themes using `Theme.RegisterTheme`:

```lua
local Theme = require(Silverline.Systems.Theme)

Theme.RegisterTheme("CyberSilver", {
    Background      = Color3.fromRGB(12, 14, 18),
    Surface         = Color3.fromRGB(18, 22, 28),
    SurfaceElevated = Color3.fromRGB(26, 32, 42),
    SurfaceHover    = Color3.fromRGB(36, 44, 56),
    SurfaceActive   = Color3.fromRGB(48, 58, 72),
    Silver          = Color3.fromRGB(200, 215, 230),
    Highlight       = Color3.fromRGB(245, 250, 255),
    TextMuted       = Color3.fromRGB(130, 145, 165),
    TextDisabled    = Color3.fromRGB(80, 90, 105),
    Border          = Color3.fromRGB(45, 55, 70),
    BorderHighlight = Color3.fromRGB(100, 140, 190),
    Accent          = Color3.fromRGB(110, 180, 245),
    AccentHover     = Color3.fromRGB(140, 200, 255),
    Success         = Color3.fromRGB(90, 210, 140),
    Warning         = Color3.fromRGB(240, 180, 70),
    Error           = Color3.fromRGB(240, 80, 80),
    Overlay         = Color3.fromRGB(6, 8, 10),
    FontPrimary     = Enum.Font.GothamMedium,
    FontBold        = Enum.Font.GothamBold,
    FontMono        = Enum.Font.Code,
})

-- Activate custom theme
window:SetTheme("CyberSilver")
```
