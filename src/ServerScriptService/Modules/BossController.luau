local Players = game:GetService("Players")

local BossController = {}

local BOSS_MAX_HEALTH = 500
local PHASE_2_THRESHOLD = 0.6 -- 60% HP
local SPAWN_POSITION = Vector3.new(100, 8, 0)

local activeBoss = nil

local function makePart(name, size, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Parent = parent
	return part
end

local function createBossModel()
	local model = Instance.new("Model")
	model.Name = "ProfessorNyux"

	local body = makePart("Body", Vector3.new(4, 6, 4), Color3.fromRGB(80, 60, 140), model)
	body.CFrame = CFrame.new(SPAWN_POSITION)

	local head = makePart("Head", Vector3.new(3, 3, 3), Color3.fromRGB(255, 220, 60), model)
	head.CFrame = CFrame.new(SPAWN_POSITION + Vector3.new(0, 4.5, 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = BOSS_MAX_HEALTH
	humanoid.Health = BOSS_MAX_HEALTH
	humanoid.WalkSpeed = 0
	humanoid.Parent = model

	model.PrimaryPart = body
	model:SetAttribute("IsGlitchEnemy", true)
	model:SetAttribute("IsBoss", true)

	model.Parent = workspace
	return model, humanoid
end

local function onPhaseChange(boss, phase)
	if phase == 2 then
		boss:SetAttribute("Phase", 2)
		print("[Босс] Переход в фазу 2 — Щупальца")
	end
end

function BossController.spawn()
	if activeBoss then return activeBoss end

	local model, humanoid = createBossModel()
	model:SetAttribute("Phase", 1)
	activeBoss = model

	humanoid.HealthChanged:Connect(function(hp)
		local ratio = hp / BOSS_MAX_HEALTH
		if ratio <= PHASE_2_THRESHOLD and model:GetAttribute("Phase") == 1 then
			onPhaseChange(model, 2)
		end
	end)

	humanoid.Died:Connect(function()
		print("[Босс] Профессор Нюкс побеждён")
		task.wait(2)
		model:Destroy()
		activeBoss = nil
	end)

	return model
end

function BossController.getActive()
	return activeBoss
end

return BossController
