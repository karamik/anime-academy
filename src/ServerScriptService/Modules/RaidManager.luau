local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlitchDrone = require(script.Parent:WaitForChild("GlitchDrone"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))

local RaidManager = {}

local DRONE_COUNT = 5
local SPAWN_RADIUS = 30
local RAID_ORIGIN = Vector3.new(100, 5, 0) -- временная точка, потом заменим на класс 3-E

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

local function watchDrones(player, drones, onComplete)
	task.spawn(function()
		while true do
			task.wait(0.5)
			local alive = 0
			for _, drone in ipairs(drones) do
				if drone.Parent and drone:FindFirstChildOfClass("Humanoid") then
					local hum = drone:FindFirstChildOfClass("Humanoid")
					if hum.Health > 0 then
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

function RaidManager.startRaid(player, onComplete)
	if activeRaids[player.UserId] then return end

	activeRaids[player.UserId] = true

	local drones = spawnDrones(RAID_ORIGIN)

	watchDrones(player, drones, function()
		activeRaids[player.UserId] = nil
		DataStoreManager.addCredits(player, 50)
		DataStoreManager.addGlitchCode(player, 3)
		print("[Raid] Игрок", player.Name, "зачистил волну")
		if onComplete then
			onComplete()
		end
	end)
end

function RaidManager.isActive(player)
	return activeRaids[player.UserId] == true
end

return RaidManager
