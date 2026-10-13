# Silverline Public API Reference

## 1. Silverline Root

### `Silverline.new(config: AppConfig)`
Creates a new Silverline application instance.

**Config Options:**
| Parameter | Type | Default | Description |
|---|---|---|---|
| `Title` | `string?` | `"SILVERLINE"` | Global application title |
| `Subtitle` | `string?` | `"Control Center"` | Global subtitle |
| `Theme` | `string?` | `"DarkSilver"` | Active theme name (`DarkSilver`, `LightSilver`, `Obsidian`, `Platinum`) |
| `Animations` | `boolean?` | `true` | Enables or disables tweening micro-interactions |
| `Icon` | `string?` | `"shield"` | Default brand icon identifier |
| `ParentGui` | `ScreenGui?` | `nil` | Optional custom parent ScreenGui |

### `app:CreateWindow(props: WindowProps) -> Window`
Instantiates a new UI Window.

---

## 2. Window Object

### Methods
- `window:CreateTab(props: TabProps) -> Tab`: Adds a navigation tab.
- `window:SelectTab(tab: Tab)`: Switches active tab.
- `window:Minimize()`: Minimizes the window to the floating reopen badge.
- `window:Restore()`: Restores the window.
- `window:SetTitle(title: string, subtitle: string?)`: Updates title bar text dynamically.
- `window:SetTheme(themeName: string)`: Changes theme at runtime.
- `window:Destroy()`: Teardown and clean up all connections, instances, and tweens.

---

## 3. Tab Object

### Methods
- `tab:CreateSection(props: SectionProps) -> Section`: Creates a categorized section container.
- `tab:SetBadge(text: string?)`: Sets or clears a small metadata chip on the tab item.
- `tab:Select()`: Selects this tab.
- `tab:Deselect()`: Hides this tab.
- `tab:Destroy()`: Destroys this tab and its child sections.

---

## 4. Section Object

### Component Factory Methods

#### `section:CreateButton(props)`
- `Name`: Button label text.
- `Description?`: Subtitle description.
- `Icon?`: Icon name from `Icons` registry.
- `Variant?`: `"Primary"`, `"Secondary"`, `"Subtle"`, `"Danger"`.
- `Confirm?`: Requires clicking twice to execute callback.
- `ConfirmText?`: Prompt shown on first click (e.g. `"Click again to confirm"`).
- `Callback?`: `() -> ()`.
- **Methods**: `SetText(text)`, `SetDescription(desc)`, `SetDisabled(bool)`, `SetLoading(bool)`, `SetVisible(bool)`, `Destroy()`.

#### `section:CreateToggle(props)`
- `Name`: Toggle label.
- `Description?`: Explanatory subtext.
- `Default?`: Boolean initial state.
- `Keybind?`: Optional `Enum.KeyCode` displayed alongside switch.
- `Callback?`: `(value: boolean) -> ()`.
- **Methods**: `GetValue() -> boolean`, `SetValue(bool, triggerCallback?)`, `SetDisabled(bool)`, `SetVisible(bool)`, `Destroy()`.

#### `section:CreateCheckbox(props)`
- `Name`: Checkbox label.
- `Description?`: Explanatory subtext.
- `Default?`: Boolean initial state.
- `Callback?`: `(value: boolean) -> ()`.
- **Methods**: `GetValue()`, `SetValue()`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreateSlider(props)`
- `Name`: Slider title.
- `Min`: Lower numeric bound.
- `Max`: Upper numeric bound.
- `Default?`: Initial numeric value.
- `Step?`: Stepping interval (supports integers or decimals like `0.1`).
- `Suffix?`: Units suffix appended to readout (`"%"`, `" studs"`, `" ms"`).
- `Callback?`: `(value: number) -> ()`.
- **Methods**: `GetValue() -> number`, `SetValue(val, triggerCallback?)`, `SetDisabled(bool)`, `SetVisible(bool)`, `Destroy()`.

#### `section:CreateRangeSlider(props)`
- `Name`: Title.
- `Min`, `Max`: Outer boundary bounds.
- `DefaultMin`, `DefaultMax`: Initial values.
- `Step?`: Step constraint.
- `Suffix?`: Suffix string.
- `Callback?`: `(minVal: number, maxVal: number) -> ()`.
- **Methods**: `GetValues() -> (number, number)`, `SetValues(min, max, triggerCallback?)`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreateDropdown(props)`
- `Name`: Dropdown label.
- `Options`: Array of option strings `{ "Option 1", "Option 2" }`.
- `Default?`: Initial selected string or array (if multi-select).
- `Multi?`: Boolean enabling multi-selection.
- `Searchable?`: Enables real-time text filter in popover.
- `Callback?`: `(selected: string | { string }) -> ()`.
- **Methods**: `GetSelected()`, `SetSelected(selection, triggerCallback?)`, `SetOptions(newOptions)`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreateInput(props)`
- `Name`: Label text.
- `Placeholder?`: Ghost text shown when input is blank.
- `Default?`: Starting string.
- `NumericOnly?`: Strips non-numeric characters automatically.
- `MaxLength?`: Character limit.
- `Callback?`: `(submittedText: string) -> ()` (fires on focus lost or enter).
- `OnChanged?`: `(text: string) -> ()` (fires on every keystroke).
- **Methods**: `GetText() -> string`, `SetText(text, triggerCallback?)`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreateKeybind(props)`
- `Name`: Label text.
- `Default?`: `Enum.KeyCode` default.
- `Mode?`: `"Toggle"` (fires once on press) or `"Hold"` (fires true on press, false on release).
- `Callback?`: `(state: boolean) -> ()`.
- `OnKeyChanged?`: `(key: Enum.KeyCode?) -> ()`.
- **Methods**: `GetKey() -> Enum.KeyCode?`, `SetKey(keyCode, triggerCallback?)`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreateColorPicker(props)`
- `Name`: Label.
- `Default?`: Initial `Color3`.
- `Alpha?`: Enables transparency slider channel.
- `DefaultAlpha?`: Initial alpha value (`0` to `1`).
- `Callback?`: `(color: Color3, alpha: number) -> ()`.
- **Methods**: `GetColor() -> (Color3, number)`, `SetColor(color, alpha?, triggerCallback?)`, `SetDisabled()`, `SetVisible()`, `Destroy()`.

#### `section:CreatePredictionPanel(props)`
- `Title`: Card title.
- `Status?`: Status chip text.
- `Value?`: Hero measurement readout string.
- `Confidence?`: Metric uncertainty explanation.
- `OnRefresh?`: Recalculation callback.
- **Methods**: `Update(value, status?, confidence?)`, `Destroy()`.

#### `section:CreateLabel(text: string, description: string?) -> TextLabel`
#### `section:CreateDivider() -> Frame`
#### `section:AddCustom(customInstance: Instance)`

---

## 5. Global Notification & Loading Managers

### `app:Notify(props: NotificationProps)`
Pushes a toast notification to the screen stack.
- `Title`: Header text.
- `Content`: Descriptive body.
- `Duration?`: Time before auto-dismiss in seconds (default `4`).
- `Type?`: `"Info"`, `"Success"`, `"Warning"`, `"Error"`.
- `Icon?`: Optional icon name override.
- `OnClick?`: Optional callback executed if user clicks the toast.

### `app:CreateLoadingScreen(props: LoadingProps) -> LoadingScreen`
Displays an introductory or transition splash screen.
- `loading:SetProgress(ratio: number, statusText: string?)`: Updates bar fill (`0` to `1`).
- `loading:SetStage(stageName: string)`: Updates stage label.
- `loading:Complete(onFinished: () -> ())`: Fills to 100% and smoothly fades out.
- `loading:Destroy()`: Immediately tears down loading elements.
