-- Upgrade altar: touch to upgrade equipped weapon. All strings in English.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponUpgrade = require(ReplicatedStorage:WaitForChild("WeaponUpgrade"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))
local WeaponSystem = require(script.Parent:WaitForChild("WeaponSystem"))
local DialogueSystem = require(script.Parent:WaitForChild("DialogueSystem"))

local UpgradeAltar = {}

local ALTAR_POSITION = Vector3.new(-15, 5, 10)
local ALTAR_SIZE = Vector3.new(4, 1, 4)
local COOLDOWN = 2

local cooldowns = {}

local function createAltar()
	local altar = Instance.new("Part")
	altar.Name = "UpgradeAltar"
	altar.Size = ALTAR_SIZE
	altar.Position = ALTAR_POSITION
	altar.Anchored = true
	altar.CanCollide = true
	altar.Material = Enum.Material.Neon
	altar.Color = Color3.fromRGB(220, 160, 60)
	altar.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 200, 100)
	light.Range = 20
	light.Brightness = 2
	light.Parent = altar

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.Parent = altar

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Text = "UPGRADE"
	text.Parent = gui

	return altar
end

local function tryUpgrade(player)
	local now = os.clock()
	if now - (cooldowns[player.UserId] or 0) < COOLDOWN then return end
	cooldowns[player.UserId] = now

	local data = DataStoreManager.get(player)
	if not data then return end
	if not data.equippedWeapon then return end

	local weaponId = data.equippedWeapon
	local currentLevel = DataStoreManager.getWeaponLevel(player, weaponId)
	local credits = data.credits

	local newLevel, newCredits = WeaponUpgrade.upgrade(currentLevel, credits)
	if not newLevel then
		if currentLevel >= WeaponUpgrade.MAX_LEVEL then
			DialogueSystem.speak(player, "onLowHP")
		end
		return
	end

	DataStoreManager.setWeaponLevel(player, weaponId, newLevel)
	DataStoreManager.spendCredits(player, credits - newCredits)

	WeaponSystem.equipWeapon(player, weaponId)

	DialogueSystem.speak(player, "onKill")
	print(string.format("[Upgrade] %s upgraded %s to level %d", player.Name, weaponId, newLevel))
end

function UpgradeAltar.start()
	local altar = createAltar()

	altar.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		tryUpgrade(player)
	end)
end

return UpgradeAltar
