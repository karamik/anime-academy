local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage:WaitForChild("WeaponConfig"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))
local WeaponSystem = require(script.Parent:WaitForChild("WeaponSystem"))
local DialogueSystem = require(script.Parent:WaitForChild("DialogueSystem"))

local GachaAltar = {}

local ALTAR_POSITION = Vector3.new(0, 5, 10)
local ALTAR_SIZE = Vector3.new(4, 1, 4)
local COOLDOWN = 5

local weaponPool = {"Rasetsu", "Aeter", "Mugen"}

local cooldowns = {}

local function createAltar()
	local altar = Instance.new("Part")
	altar.Name = "GachaAltar"
	altar.Size = ALTAR_SIZE
	altar.Position = ALTAR_POSITION
	altar.Anchored = true
	altar.CanCollide = true
	altar.Material = Enum.Material.Neon
	altar.Color = Color3.fromRGB(120, 80, 220)
	altar.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(180, 120, 255)
	light.Range = 20
	light.Brightness = 2
	light.Parent = altar

	return altar
end

local function rollWeapon(player)
	local now = os.clock()
	if now - (cooldowns[player.UserId] or 0) < COOLDOWN then return end
	cooldowns[player.UserId] = now

	local data = DataStoreManager.get(player)
	if not data then return end

	local weaponId = weaponPool[math.random(1, #weaponPool)]

	DataStoreManager.giveWeapon(player, weaponId)
	DataStoreManager.equipWeapon(player, weaponId)

	WeaponSystem.equipWeapon(player, weaponId)
	DialogueSystem.speak(player, "onEquip")

	print("[Гача] Игрок", player.Name, "получил", weaponId)
end

function GachaAltar.start()
	local altar = createAltar()

	altar.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		rollWeapon(player)
	end)
end

return GachaAltar
