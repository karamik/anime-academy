local Players = game:GetService("Players")

local BossController = {}

local BOSS_MAX_HEALTH = 8000
local PHASE_2_THRESHOLD = 0.6
local SPAWN_POSITION = Vector3.new(100, 8, 0)
local TENTACLE_DAMAGE = 15

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

	local core = makePart("Core", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 80, 80), model)
	core.CFrame = CFrame.new(SPAWN_POSITION + Vector3.new(0, 0, -2.5))
	core:SetAttribute("IsBossCore", true)

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

local function teleportAround(boss)
	local body = boss.PrimaryPart
	if not body then return end
	local angle = math.random() * math.pi * 2
	local radius = math.random(15, 35)
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	body.CFrame = CFrame.new(SPAWN_POSITION + offset)
end

local function flickerLight(boss)
	local lighting = game:GetService("Lighting")
	local original = lighting.Ambient
	lighting.Ambient = Color3.fromRGB(20, 5, 30)
	task.wait(3)
	if boss.Parent then
		lighting.Ambient = original
	end
end

local function startPhase1(boss)
	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == 1 do
			task.wait(math.random(3, 5))
			if not boss.Parent then break end
			teleportAround(boss)
		end
	end)

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == 1 do
			task.wait(math.random(8, 12))
			if not boss.Parent then break end
			flickerLight(boss)
		end
	end)
end

local function spawnTentacle(boss)
	local angle = math.random() * math.pi * 2
	local radius = math.random(10, 20)
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local pos = boss.PrimaryPart.Position + offset

	local tentacle = makePart("Tentacle", Vector3.new(1, 6, 1), Color3.fromRGB(20, 0, 40), boss)
	tentacle.CFrame = CFrame.new(pos)

	tentacle.Touched:Connect(function(hit)
		local char = hit:FindFirstAncestorOfClass("Model")
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			hum:TakeDamage(TENTACLE_DAMAGE)
		end
	end)

	task.wait(4)
	if tentacle.Parent then
		tentacle:Destroy()
	end
end

local function startPhase2(boss)
	boss:SetAttribute("Phase", 2)
	print("[Босс] Переход в фазу 2 — Щупальца")

	local core = boss:FindFirstChild("Core")
	if core then
		core.Color = Color3.fromRGB(255, 30, 30)
	end

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == 2 do
			task.wait(2)
			if not boss.Parent then break end
			for i = 1, 3 do
				spawnTentacle(boss)
				task.wait(0.3)
			end
		end
	end)
end

local function onPhaseChange(boss, phase)
	if phase == 2 then
		startPhase2(boss)
	end
end

function BossController.spawn()
	if activeBoss then return activeBoss end

	local model, humanoid = createBossModel()
	model:SetAttribute("Phase", 1)
	activeBoss = model

	startPhase1(model)

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
