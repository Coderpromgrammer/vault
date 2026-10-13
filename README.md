# ✦ SILVERLINE UI FRAMEWORK

**A Premium, Lightweight Roblox Luau UI Framework with Satin Silver Aesthetics**

Silverline is a modern, modular UI library engineered specifically for legitimate Roblox Studio experiences, developer dashboards, administrative suites, configuration panels, and in-game toolbars.

Unlike conventional script menus that rely on harsh neon outlines and pitch-black backgrounds, Silverline introduces an original **Satin-Silver & Graphite** design language characterized by subtle metallic highlights, meticulous typography hierarchy, fluid micro-motion, and deterministic resource lifecycle management.

---

## Key Highlights

- **Original Visual Identity**: Satin silver (`#C6CCD5`), graphite canvas (`#101216`), deep panel elevation (`#171A20` → `#20242B`), and restrained steel-blue highlights.
- **Cross-Platform Input**: Full mouse, keyboard, and touch screen support with viewport-clamped window dragging and a floating draggable reopen badge.
- **Complete Component Suite**:
  - Buttons (Primary, Secondary, Subtle, Danger) with loading states and 2-click confirmation
  - Smooth Switch Toggles with integrated keybind chips
  - Checkboxes with animated checks
  - Single & Dual-Handled Range Sliders with step constraints and editable readouts
  - Single & Multi-Select Dropdowns with live search filters and portal popovers
  - Text Input with numeric clamping, max length, and clear controls
  - Focus-Aware Keybind Pickers (Hold and Toggle modes)
  - Expandable HSV Color Pickers with hue bar, hex editor, and preview swatches
  - Managed Toast Notifications with decay progress bars
  - Modal Confirmation Dialogs with dimmed backdrops
  - Splash Loading Screens with stages and determinate progress
  - Presentation Prediction/Telemetry Panels
- **Dynamic Runtime Theming**: Instant theme switching (`DarkSilver`, `LightSilver`, `Obsidian`, `Platinum`) updating all live elements without recreating instances.
- **Memory & Lifecycle Safety**: Scoped `Cleanup` bags prevent memory leaks, disconnect events cleanly, and cancel tweens on teardown.

---

## Directory Architecture

```text
Silverline/
├── init.lua                   # Framework entry point & exports
├── Core/
│   ├── Window.lua             # Window manager, title bar, clamping, reopen badge
│   ├── Tab.lua                # Tab pages, navigation buttons, badges
│   ├── Section.lua            # Sections, accordions, and component factory
│   └── State.lua              # Reactive observable state container
├── Components/
│   ├── Button.lua             # Buttons with variants and confirmation
│   ├── Toggle.lua             # Pill switch with animated thumb & keybind chip
│   ├── Checkbox.lua           # Square box with checkmark animation
│   ├── Slider.lua             # Single value slider with drag & editable readout
│   ├── RangeSlider.lua        # Dual-handled range slider
│   ├── Dropdown.lua           # Single/multi-select search dropdown with portal layer
│   ├── Input.lua              # Textbox with validation, clear button, and focus styling
│   ├── Keybind.lua            # Keybind picker with listening state
│   ├── ColorPicker.lua        # Expandable HSV color picker
│   ├── Notifications.lua      # Toast notification stack with decay bar
│   ├── Dialog.lua             # Confirmation modal dialog with dimmed backdrop
│   ├── Tooltip.lua            # Floating hover tooltip
│   ├── LoadingScreen.lua      # Splash and loading screen with stages
│   └── PredictionPanel.lua    # Presentation metrics and telemetry card
├── Systems/
│   ├── Theme.lua              # Centralized theme tokens and runtime cascade
│   ├── Icons.lua              # Lucide icon atlas with fallback glyphs
│   ├── Animation.lua          # Standardized easing presets and tween coordinator
│   ├── Input.lua              # Dragging, viewport clamping, and typing filter
│   └── Cleanup.lua            # Maid-style resource lifecycle manager
├── Examples/
│   └── Demo.client.lua        # Complete interactive demonstration
└── Docs/
    ├── GETTING_STARTED.md     # Installation & quick-start guide
    ├── API.md                 # Complete public API reference
    ├── THEMES.md              # Theme tokens & custom palette creation
    └── CUSTOM_COMPONENTS.md   # Extending Silverline with custom UI
```

---

## Quick Start

```lua
local Silverline = require(game.ReplicatedStorage.Silverline)

local app = Silverline.new({
    Title = "My Application",
    Subtitle = "Control Center",
    Theme = "DarkSilver",
    Animations = true,
})

local window = app:CreateWindow({
    Size = UDim2.fromOffset(680, 440),
})

local tab = window:CreateTab({
    Name = "General",
    Icon = "home",
})

local section = tab:CreateSection({
    Name = "Settings",
})

section:CreateToggle({
    Name = "Auto Update",
    Default = true,
    Callback = function(val)
        print("Auto update is:", val)
    end,
})

section:CreateButton({
    Name = "Save Changes",
    Variant = "Primary",
    Icon = "check",
    Callback = function()
        app:Notify({
            Title = "Saved",
            Content = "Your preferences have been saved.",
            Type = "Success",
        })
    end,
})
```

---

## Documentation Links

- [Getting Started Guide](Docs/GETTING_STARTED.md)
- [API Reference](Docs/API.md)
- [Theming & Color Tokens](Docs/THEMES.md)
- [Custom Components Guide](Docs/CUSTOM_COMPONENTS.md)
