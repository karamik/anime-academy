local GlitchDrone = {}

local DEFAULT_HEALTH = 50
local DEFAULT_SPEED = 8
local DEFAULT_DAMAGE = 5

local function makePart(name, size, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Anchored = false
	part.CanCollide = true
	part.Parent = parent
	return part
end

function GlitchDrone.spawn(position)
	local model = Instance.new("Model")
	model.Name = "GlitchDrone"

	local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 2), Color3.fromRGB(180, 40, 200), model)
	root.CFrame = CFrame.new(position)

	local head = makePart("Head", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 60, 60), model)
	head.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = DEFAULT_HEALTH
	humanoid.Health = DEFAULT_HEALTH
	humanoid.WalkSpeed = DEFAULT_SPEED
	humanoid.Parent = model

	model.PrimaryPart = root
	model:SetAttribute("IsGlitchEnemy", true)

	-- Сварка головы к руту
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = head
	weld.Parent = root

	model.Parent = workspace

	humanoid.Died:Connect(function()
		task.wait(0.2)
		model:Destroy()
	end)

	return model
end

return GlitchDrone
