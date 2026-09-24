-- Скелет второго босса: Профессор Локус.
-- Без карманов и клонов — они будут добавлены после теста в Studio.
-- Что работает: 3 фазы, телепорт, луч по прямой, самоурон в 3 фазе.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocusConfig = require(ReplicatedStorage:WaitForChild("LocusConfig"))
local LocusLogic = require(ReplicatedStorage:WaitForChild("LocusLogic"))

local BossController_Locus = {}

local BOSS_MAX_HEALTH = LocusConfig.Phases.Collapse.bossHealth
local SPAWN_POSITION = Vector3.new(100, 8, 0)
local BEAM_DAMAGE = 20
local BEAM_LENGTH = 60
local BEAM_WIDTH = 2

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
	model.Name = "ProfessorLocus"

	local body = makePart("Body", Vector3.new(3, 7, 3), Color3.fromRGB(60, 100, 180), model)
	body.CFrame = CFrame.new(SPAWN_POSITION)

	local head = makePart("Head", Vector3.new(2.5, 2.5, 2.5), Color3.fromRGB(180, 220, 255), model)
	head.CFrame = CFrame.new(SPAWN_POSITION + Vector3.new(0, 5, 0))

	local core = makePart("Core", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(120, 180, 255), model)
	core.CFrame = CFrame.new(SPAWN_POSITION + Vector3.new(0, 0, -2))
	core:SetAttribute("IsBossCore", true)

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = BOSS_MAX_HEALTH
	humanoid.Health = BOSS_MAX_HEALTH
	humanoid.WalkSpeed = 0
	humanoid.Parent = model

	model.PrimaryPart = body
	model:SetAttribute("IsGlitchEnemy", true)
	model:SetAttribute("IsBoss", true)
	model:SetAttribute("BossId", "Locus")

	model.Parent = workspace
	return model, humanoid
end

local function teleportAround(boss)
	local body = boss.PrimaryPart
	if not body then return end
	local angle = math.random() * math.pi * 2
	local radius = math.random(20, 40)
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	body.CFrame = CFrame.new(SPAWN_POSITION + offset)
end

local function fireBeam(boss)
	local body = boss.PrimaryPart
	if not body then return end

	local origin = body.Position + body.CFrame.LookVector * 3
	local direction = body.CFrame.LookVector

	local beam = makePart("Beam", Vector3.new(BEAM_WIDTH, BEAM_WIDTH, BEAM_LENGTH),
		Color3.fromRGB(120, 200, 255), workspace)
	beam.CFrame = CFrame.new(origin + direction * (BEAM_LENGTH / 2), origin + direction * BEAM_LENGTH)
	beam.CanCollide = false

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {boss}

	local result = workspace:Raycast(origin, direction * BEAM_LENGTH, rayParams)
	if result then
		local hit = result.Instance
		local character = hit:FindFirstAncestorOfClass("Model")
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(BEAM_DAMAGE)
			end
		end
	end

	task.wait(0.4)
	if beam.Parent then
		beam:Destroy()
	end
end

local function startPhase1(boss)
	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == "Split" do
			task.wait(math.random(3, 5))
			if not boss.Parent then break end
			teleportAround(boss)
		end
	end)

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == "Split" do
			task.wait(math.random(6, 9))
			if not boss.Parent then break end
			fireBeam(boss)
		end
	end)
end

local function startPhase2(boss)
	print("[Локус] Фаза 2 — Схлопывание")

	local core = boss:FindFirstChild("Core")
	if core then
		core.Color = Color3.fromRGB(255, 200, 100)
	end

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == "Collapse" do
			task.wait(math.random(2, 3))
			if not boss.Parent then break end
			teleportAround(boss)
		end
	end)

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == "Collapse" do
			task.wait(math.random(3, 5))
			if not boss.Parent then break end
			fireBeam(boss)
		end
	end)
end

local function startPhase3(boss)
	print("[Локус] Фаза 3 — Схлопывание в точку")

	local body = boss.PrimaryPart
	if body then
		body.Size = Vector3.new(2, 2, 2)
		body.Color = Color3.fromRGB(255, 100, 100)
	end

	local core = boss:FindFirstChild("Core")
	if core then
		core.Size = Vector3.new(3, 3, 3)
		core.Color = Color3.fromRGB(255, 40, 40)
	end

	task.spawn(function()
		while boss.Parent and boss:GetAttribute("Phase") == "Singularity" do
			task.wait(1)
			if not boss.Parent then break end
			teleportAround(boss)
		end
	end)

	local humanoid = boss:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local startTime = os.clock()
	local config = LocusConfig.Phases.Singularity

	task.spawn(function()
		while boss.Parent do
			task.wait(0.5)
			if not boss.Parent then break end

			local elapsed = os.clock() - startTime
			local timeLeft = LocusLogic.timeToSelfDestruct(elapsed, LocusConfig)

			if timeLeft <= 0 then
				print("[Локус] Сфера взорвалась!")
				for _, player in ipairs(Players:GetPlayers()) do
					local character = player.Character
					if character then
						local root = character:FindFirstChild("HumanoidRootPart")
						local hum = character:FindFirstChildOfClass("Humanoid")
						if root and hum and boss.PrimaryPart then
							local dist = (root.Position - boss.PrimaryPart.Position).Magnitude
							if dist <= config.selfDestructRadius then
								hum.Health = 0
							end
						end
					end
				end

				if boss.Parent then
					local hum2 = boss:FindFirstChildOfClass("Humanoid")
					if hum2 then
						hum2.Health = 0
					end
				end
				return
			end
		end
	end)
end

local function bindPhaseChanges(boss)
	local humanoid = boss:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.HealthChanged:Connect(function(newHealth)
		local percent = newHealth / BOSS_MAX_HEALTH
		local phase = LocusLogic.getPhase(percent)
		local currentPhase = boss:GetAttribute("Phase")
		if phase ~= currentPhase then
			boss:SetAttribute("Phase", phase)
			if phase == "Collapse" then
				startPhase2(boss)
			elseif phase == "Singularity" then
				startPhase3(boss)
			end
		end
	end)
end

function BossController_Locus.spawn()
	if activeBoss then return activeBoss end

	local model, humanoid = createBossModel()
	model:SetAttribute("Phase", "Split")
	activeBoss = model

	startPhase1(model)
	bindPhaseChanges(model)

	humanoid.Died:Connect(function()
		print("[Локус] Профессор Локус побеждён")
		task.wait(2)
		model:Destroy()
		activeBoss = nil
	end)

	return model
end

function BossController_Locus.getActive()
	return activeBoss
end

return BossController_Locus
