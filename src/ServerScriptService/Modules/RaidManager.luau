local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlitchDrone = require(script.Parent:WaitForChild("GlitchDrone"))
local BossController = require(script.Parent:WaitForChild("BossController"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))

local RaidManager = {}

local DRONE_COUNT = 5
local SPAWN_RADIUS = 30
local RAID_ORIGIN = Vector3.new(100, 5, 0)

local activeRaids = {}

local function spawnDrones(origin)
	local drones = {}
	for i = 1, DRONE_COUNT do
		local angle = (i / DRONE_COUNT) * math.pi * 2
		local offset = Vector3.new(
			math.cos(angle) * SPAWN_RADIUS,
			0,
			math.sin(angle) * SPAWN_RADIUS
		)
		local drone = GlitchDrone.spawn(origin + offset)
		table.insert(drones, drone)
	end
	return drones
end

local function watchDrones(drones, onComplete)
	task.spawn(function()
		while true do
			task.wait(0.5)
			local alive = 0
			for _, drone in ipairs(drones) do
				if drone.Parent then
					local hum = drone:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						alive = alive + 1
					end
				end
			end
			if alive == 0 then
				onComplete()
				return
			end
		end
	end)
end

local function watchBoss(boss, onComplete)
	local humanoid = boss:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.Died:Connect(function()
		task.wait(2.5)
		onComplete()
	end)
end

function RaidManager.startRaid(player, onComplete)
	if activeRaids[player.UserId] then return end
	activeRaids[player.UserId] = true

	local drones = spawnDrones(RAID_ORIGIN)

	watchDrones(drones, function()
		print("[Raid] Дроны зачищены. Спавн босса...")
		DataStoreManager.addCredits(player, 50)
		DataStoreManager.addGlitchCode(player, 3)

		local boss = BossController.spawn()

		watchBoss(boss, function()
			print("[Raid] Босс побеждён. Выдача финальной награды.")
			DataStoreManager.addCredits(player, 100)
			DataStoreManager.addGlitchCode(player, 5)
			activeRaids[player.UserId] = nil
			if onComplete then
				onComplete()
			end
		end)
	end)
end

function RaidManager.isActive(player)
	return activeRaids[player.UserId] == true
end

return RaidManager
