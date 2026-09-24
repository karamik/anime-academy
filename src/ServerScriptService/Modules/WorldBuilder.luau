-- Builds the hub and raid arena. All strings in English.

local WorldBuilder = {}

local function makePart(name, size, position, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Parent = parent or workspace
	return part
end

local function makeSpawn(position)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = position
	spawn.Anchored = true
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(80, 200, 160)
	spawn.Parent = workspace
	return spawn
end

function WorldBuilder.build()
	-- Hub
	makePart("HubFloor", Vector3.new(80, 2, 80), Vector3.new(0, 3, 0), Color3.fromRGB(40, 45, 60))

	makePart("HubWall_N", Vector3.new(80, 8, 2), Vector3.new(0, 7, -40), Color3.fromRGB(30, 35, 50))
	makePart("HubWall_S", Vector3.new(80, 8, 2), Vector3.new(0, 7, 40), Color3.fromRGB(30, 35, 50))
	makePart("HubWall_W", Vector3.new(2, 8, 80), Vector3.new(-40, 7, 0), Color3.fromRGB(30, 35, 50))
	makePart("HubWall_E", Vector3.new(2, 8, 80), Vector3.new(40, 7, 0), Color3.fromRGB(30, 35, 50))

	makeSpawn(Vector3.new(0, 5, 0))

	-- Raid arena
	makePart("RaidFloor", Vector3.new(80, 2, 80), Vector3.new(100, 3, 0), Color3.fromRGB(50, 25, 40))

	makePart("RaidWall_N", Vector3.new(80, 12, 2), Vector3.new(100, 8, -40), Color3.fromRGB(40, 15, 30))
	makePart("RaidWall_S", Vector3.new(80, 12, 2), Vector3.new(100, 8, 40), Color3.fromRGB(40, 15, 30))
	makePart("RaidWall_W", Vector3.new(2, 12, 80), Vector3.new(60, 8, 0), Color3.fromRGB(40, 15, 30))
	makePart("RaidWall_E", Vector3.new(2, 12, 80), Vector3.new(140, 8, 0), Color3.fromRGB(40, 15, 30))

	-- Bridge
	makePart("Bridge", Vector3.new(20, 2, 6), Vector3.new(50, 3, 0), Color3.fromRGB(60, 60, 80))

	-- Sign
	local sign = Instance.new("Part")
	sign.Name = "RaidSign"
	sign.Size = Vector3.new(10, 4, 1)
	sign.Position = Vector3.new(45, 8, 0)
	sign.Anchored = true
	sign.Material = Enum.Material.Neon
	sign.Color = Color3.fromRGB(255, 60, 60)
	sign.Parent = workspace

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Right
	gui.Parent = sign

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Text = "RAID →"
	text.Parent = gui

	-- Lighting
	local lighting = game:GetService("Lighting")
	lighting.Ambient = Color3.fromRGB(80, 80, 100)
	lighting.OutdoorAmbient = Color3.fromRGB(60, 60, 80)
	lighting.Brightness = 1
end

return WorldBuilder
