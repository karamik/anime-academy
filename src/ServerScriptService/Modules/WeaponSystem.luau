local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage:WaitForChild("WeaponConfig"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))

local WeaponSystem = {}

local playerCooldowns = {}

local function createTool(weaponId)
	local config = WeaponConfig.get(weaponId)
	if not config then return nil end

	local tool = Instance.new("Tool")
	tool.Name = weaponId
	tool.CanBeDropped = false
	tool.RequiresHandle = false
	tool.ToolTip = config.displayName
	return tool
end

function WeaponSystem.giveWeapon(player, weaponId)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name == weaponId then
			return
		end
	end

	local tool = createTool(weaponId)
	if tool then
		tool.Parent = backpack
	end
end

function WeaponSystem.equipWeapon(player, weaponId)
	DataStoreManager.equipWeapon(player, weaponId)

	for _, item in ipairs(player:GetChildren()) do
		if item:IsA("Tool") then
			item:Destroy()
		end
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
	end

	WeaponSystem.giveWeapon(player, weaponId)
end

function WeaponSystem.canAttack(player)
	local now = os.clock()
	local last = playerCooldowns[player.UserId] or 0
	local data = DataStoreManager.get(player)
	if not data or not data.equippedWeapon then return false end
	local config = WeaponConfig.get(data.equippedWeapon)
	if not config then return false end
	if now - last < config.cooldown then return false end
	playerCooldowns[player.UserId] = now
	return true
end

function WeaponSystem.getEquippedConfig(player)
	local data = DataStoreManager.get(player)
	if not data or not data.equippedWeapon then return nil end
	return WeaponConfig.get(data.equippedWeapon)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		local data = DataStoreManager.get(player)
		if data and data.equippedWeapon then
			WeaponSystem.giveWeapon(player, data.equippedWeapon)
		end
	end)
end)

return WeaponSystem
