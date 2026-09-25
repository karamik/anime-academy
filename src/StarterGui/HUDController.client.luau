-- HUD controller. Reads player attributes directly (no RemoteEvents for stats).
-- All strings in English.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local GlitchMeter = require(ReplicatedStorage:WaitForChild("GlitchMeter"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- HP bar
local hpFrame = Instance.new("Frame")
hpFrame.Name = "HPFrame"
hpFrame.Size = UDim2.new(0, 250, 0, 30)
hpFrame.Position = UDim2.new(0, 20, 0, 20)
hpFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hpFrame.BorderSizePixel = 0
hpFrame.Parent = screenGui

local hpBar = Instance.new("Frame")
hpBar.Name = "HPBar"
hpBar.Size = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
hpBar.BorderSizePixel = 0
hpBar.Parent = hpFrame

local hpLabel = Instance.new("TextLabel")
hpLabel.Name = "HPLabel"
hpLabel.Size = UDim2.new(1, 0, 1, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.TextStrokeTransparency = 0.5
hpLabel.Font = Enum.Font.GothamBold
hpLabel.TextScaled = true
hpLabel.Text = "HP: 100 / 100"
hpLabel.Parent = hpFrame

-- Glitch bar
local glitchFrame = Instance.new("Frame")
glitchFrame.Name = "GlitchFrame"
glitchFrame.Size = UDim2.new(0, 250, 0, 18)
glitchFrame.Position = UDim2.new(0, 20, 0, 55)
glitchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
glitchFrame.BorderSizePixel = 0
glitchFrame.Parent = screenGui

local glitchBar = Instance.new("Frame")
glitchBar.Name = "GlitchBar"
glitchBar.Size = UDim2.new(0, 0, 1, 0)
glitchBar.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
glitchBar.BorderSizePixel = 0
glitchBar.Parent = glitchFrame

local glitchLabel = Instance.new("TextLabel")
glitchLabel.Name = "GlitchLabel"
glitchLabel.Size = UDim2.new(1, 0, 1, 0)
glitchLabel.BackgroundTransparency = 1
glitchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
glitchLabel.TextStrokeTransparency = 0.5
glitchLabel.Font = Enum.Font.GothamBold
glitchLabel.TextScaled = true
glitchLabel.Text = "GLITCH: 0"
glitchLabel.Parent = glitchFrame

-- Currency
local currencyFrame = Instance.new("Frame")
currencyFrame.Name = "CurrencyFrame"
currencyFrame.Size = UDim2.new(0, 250, 0, 60)
currencyFrame.Position = UDim2.new(1, -270, 0, 20)
currencyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
currencyFrame.BorderSizePixel = 0
currencyFrame.Parent = screenGui

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Name = "CreditsLabel"
creditsLabel.Size = UDim2.new(1, -10, 0, 28)
creditsLabel.Position = UDim2.new(0, 10, 0, 2)
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
creditsLabel.Font = Enum.Font.GothamBold
creditsLabel.TextScaled = true
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.Text = "Credits: 0"
creditsLabel.Parent = currencyFrame

local codesLabel = Instance.new("TextLabel")
codesLabel.Name = "CodesLabel"
codesLabel.Size = UDim2.new(1, -10, 0, 28)
codesLabel.Position = UDim2.new(0, 10, 0, 30)
codesLabel.BackgroundTransparency = 1
codesLabel.TextColor3 = Color3.fromRGB(120, 220, 255)
codesLabel.Font = Enum.Font.GothamBold
codesLabel.TextScaled = true
codesLabel.TextXAlignment = Enum.TextXAlignment.Left
codesLabel.Text = "Glitch Code: 0"
codesLabel.Parent = currencyFrame

-- Quest button
local questButton = Instance.new("TextButton")
questButton.Name = "QuestButton"
questButton.Size = UDim2.new(0, 220, 0, 70)
questButton.Position = UDim2.new(0, 20, 1, -90)
questButton.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
questButton.TextColor3 = Color3.fromRGB(255, 255, 255)
questButton.Font = Enum.Font.GothamBold
questButton.TextScaled = true
questButton.Text = "TAKE QUEST"
questButton.Parent = screenGui

local questCorner = Instance.new("UICorner")
questCorner.CornerRadius = UDim.new(0, 12)
questCorner.Parent = questButton

-- Notification
local notifyLabel = Instance.new("TextLabel")
notifyLabel.Name = "Notify"
notifyLabel.Size = UDim2.new(0, 500, 0, 40)
notifyLabel.Position = UDim2.new(0.5, -250, 1, -180)
notifyLabel.BackgroundTransparency = 1
notifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyLabel.TextStrokeTransparency = 0.3
notifyLabel.Font = Enum.Font.GothamBold
notifyLabel.TextScaled = true
notifyLabel.Text = ""
notifyLabel.Parent = screenGui

local function showNotify(text)
	notifyLabel.Text = text
	task.spawn(function()
		task.wait(3)
		if notifyLabel.Text == text then
			notifyLabel.Text = ""
		end
	end)
end

-- HP
local function bindCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	local function update()
		local ratio = humanoid.Health / humanoid.MaxHealth
		hpBar.Size = UDim2.new(ratio, 0, 1, 0)
		hpLabel.Text = string.format("HP: %d / %d",
			math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
	end

	humanoid.HealthChanged:Connect(update)
	update()
end

if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

-- Read stats from attributes
local function updateCredits()
	local credits = player:GetAttribute("Credits") or 0
	creditsLabel.Text = "Credits: " .. tostring(credits)
end

local function updateCodes()
	local codes = player:GetAttribute("GlitchCode") or 0
	codesLabel.Text = "Glitch Code: " .. tostring(codes)
end

local function updateGlitchFromAttribute()
	local value = player:GetAttribute("Glitch") or 0
	local ratio = value / GlitchMeter.MAX
	glitchBar.Size = UDim2.new(ratio, 0, 1, 0)
	glitchLabel.Text = string.format("GLITCH: %d", math.floor(value))

	local stage = GlitchMeter.getStage(value)
	if stage == "critical" then
		glitchBar.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
	elseif stage == "distortion" then
		glitchBar.BackgroundColor3 = Color3.fromRGB(220, 60, 180)
	else
		glitchBar.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
	end
end

player:GetAttributeChangedSignal("Credits"):Connect(updateCredits)
player:GetAttributeChangedSignal("GlitchCode"):Connect(updateCodes)
player:GetAttributeChangedSignal("Glitch"):Connect(updateGlitchFromAttribute)

updateCredits()
updateCodes()
updateGlitchFromAttribute()

-- Quest button
questButton.MouseButton1Click:Connect(function()
	questButton.Text = "LOADING..."
	RemoteEvents.GiveQuest:FireServer()
end)

RemoteEvents.CompleteQuest.OnClientEvent:Connect(function()
	questButton.Text = "TAKE QUEST"
	showNotify("Raid complete! Reward received.")
end)
