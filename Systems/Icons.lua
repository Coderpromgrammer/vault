--!strict
--[=[
    Silverline UI Framework
    Module: Systems/Icons.lua
    Purpose: Centralized silver icon registry with verified Roblox assets, dynamic tinting, and fallback support.
]=]

local Icons = {}

export type IconEntry = {
    AssetId: string,
    Fallback: string,
}

-- Standard Lucide/Feather Roblox UI asset registry
local Registry: { [string]: IconEntry } = {
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
    ["external-link"] = { AssetId = "rbxassetid://10709798836", Fallback = "↗" },
    ["play"]          = { AssetId = "rbxassetid://10734924340", Fallback = "▶" },
    ["pause"]         = { AssetId = "rbxassetid://10734924127", Fallback = "⏸" },
    ["shield"]        = { AssetId = "rbxassetid://10734950817", Fallback = "🛡" },
    ["terminal"]      = { AssetId = "rbxassetid://10734953683", Fallback = ">" },
    ["user"]          = { AssetId = "rbxassetid://10747373426", Fallback = "👤" },
    ["star"]          = { AssetId = "rbxassetid://10734952494", Fallback = "★" },
    ["layers"]        = { AssetId = "rbxassetid://10723416790", Fallback = "≡" },
    ["zap"]           = { AssetId = "rbxassetid://10747375267", Fallback = "⚡" },
    ["box"]           = { AssetId = "rbxassetid://10709790479", Fallback = "■" },
    ["activity"]      = { AssetId = "rbxassetid://10709789919", Fallback = "〰" },
    ["filter"]        = { AssetId = "rbxassetid://10709813585", Fallback = "Y" },
    ["pin"]           = { AssetId = "rbxassetid://10734924294", Fallback = "📌" },
    ["bell"]          = { AssetId = "rbxassetid://10709790352", Fallback = "🔔" },
    ["hash"]          = { AssetId = "rbxassetid://10723396387", Fallback = "#" },
}

function Icons.Get(name: string): string
    local entry = Registry[string.lower(name)]
    if entry then
        return entry.AssetId
    end
    return "rbxassetid://10709790479" -- fallback generic box
end

function Icons.GetFallback(name: string): string
    local entry = Registry[string.lower(name)]
    if entry then
        return entry.Fallback
    end
    return "•"
end

function Icons.Register(name: string, assetId: string, fallbackChar: string?)
    Registry[string.lower(name)] = {
        AssetId = assetId,
        Fallback = fallbackChar or "•",
    }
end

export type CreateIconProps = {
    Name: string,
    Size: UDim2?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Color: Color3?,
    Transparency: number?,
    Parent: Instance?,
    ZIndex: number?,
}

function Icons.Create(props: CreateIconProps): ImageLabel
    local iconName = string.lower(props.Name or "box")
    local assetId = Icons.Get(iconName)

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon_" .. iconName
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.Image = assetId
    icon.ImageColor3 = props.Color or Color3.fromRGB(198, 204, 213)
    icon.ImageTransparency = props.Transparency or 0
    icon.Size = props.Size or UDim2.fromOffset(16, 16)
    icon.Position = props.Position or UDim2.new(0, 0, 0, 0)
    icon.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
    icon.ZIndex = props.ZIndex or 1

    if props.Parent then
        icon.Parent = props.Parent
    end

    return icon
end

return Icons
