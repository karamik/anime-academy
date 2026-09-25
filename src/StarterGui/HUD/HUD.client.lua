local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local function createLabel(name, position, size)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 0.25
    label.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    label.BorderSizePixel = 0
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = screenGui

    return label
end

local creditsLabel = createLabel(
    "Credits",
    UDim2.fromOffset(24, 24),
    UDim2.fromOffset(220, 42)
)

local weaponLabel = createLabel(
    "Weapon",
    UDim2.fromOffset(24, 74),
    UDim2.fromOffset(260, 42)
)

local glitchLabel = createLabel(
    "Glitch",
    UDim2.fromOffset(24, 124),
    UDim2.fromOffset(300, 42)
)

local function update()
    local credits = player:GetAttribute("Credits") or 0
    local weapon = player:GetAttribute("ActiveWeapon") or "Rasetsu"
    local glitch = player:GetAttribute("Glitch") or 0

    creditsLabel.Text = "  CREDITS  " .. tostring(credits)
    weaponLabel.Text = "  WEAPON  " .. string.upper(weapon)
    glitchLabel.Text = "  GLITCH  " .. tostring(glitch) .. "%"
end

for _, attribute in {
    "Credits",
    "ActiveWeapon",
    "Glitch",
} do
    player:GetAttributeChangedSignal(attribute):Connect(update)
end

update()
