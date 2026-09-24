local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local ATTACK_COOLDOWN = 0.4
local lastAttack = 0

local function attack()
	local now = os.clock()
	if now - lastAttack < ATTACK_COOLDOWN then return end
	lastAttack = now
	RemoteEvents.UseAbility:FireServer()
end

-- ПК: левая кнопка мыши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		attack()
	end
end)

-- Мобилка: кнопка на экране
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AttackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "AttackButton"
button.Size = UDim2.new(0, 120, 0, 120)
button.Position = UDim2.new(1, -150, 1, -150)
button.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "АТАКА"
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Visible = false
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- Показать кнопку только на мобилке
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	button.Visible = true
end

button.MouseButton1Click:Connect(attack)
button.TouchLongPress:Connect(attack)
</｜｜DSML｜｜ parameter>
</｜｜DSML｜｜ invoke>
</invoke>
