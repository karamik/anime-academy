local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local WeaponSystem = require(script.Parent:WaitForChild("WeaponSystem"))
local DialogueSystem = require(script.Parent:WaitForChild("DialogueSystem"))

local CombatHandler = {}

local ATTACK_COOLDOWN = 0.4
local lastAttack = {}

local function getCharacterRoot(player)
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

local function getTargetFromRay(origin, direction, range)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {}

	local result = workspace:Raycast(origin, direction * range, rayParams)
	if not result then return nil end

	local hit = result.Instance
	while hit do
		if hit:GetAttribute("IsGlitchEnemy") then
			return hit
		end
		hit = hit.Parent
	end
	return nil
end

local function applyDamage(target, amount, attacker)
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:TakeDamage(amount)

	if humanoid.Health <= 0 then
		DialogueSystem.speak(attacker, "onKill")
	end
end

RemoteEvents.UseAbility.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if now - (lastAttack[player.UserId] or 0) < ATTACK_COOLDOWN then return end
	lastAttack[player.UserId] = now

	if not WeaponSystem.canAttack(player) then return end

	local config = WeaponSystem.getEquippedConfig(player)
	if not config then return end

	local root = getCharacterRoot(player)
	if not root then return end

	local origin = root.Position
	local direction = root.CFrame.LookVector
	local target = getTargetFromRay(origin, direction, config.range)

	if target then
		applyDamage(target, config.damage, player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastAttack[player.UserId] = nil
end)

return CombatHandler
