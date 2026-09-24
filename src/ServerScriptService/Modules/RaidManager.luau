local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlitchDrone = require(script.Parent:WaitForChild("GlitchDrone"))
local BossController = require(script.Parent:WaitForChild("BossController"))
local BossController_Locus = require(script.Parent:WaitForChild("BossController_Locus"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))
local EconomyLogic = require(ReplicatedStorage:WaitForChild("EconomyLogic"))
local LocusConfig = require(ReplicatedStorage:WaitForChild("LocusConfig"))
local LocusLogic = require(ReplicatedStorage:WaitForChild("LocusLogic"))

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

-- Выбор босса: 50/50 между Нюксом и Локусом
local function pickBoss()
	if math.random() < 0.5 then
		return "Nyux", BossController.spawn()
	else
		return "Locus", BossController_Locus.spawn()
	end
end

local function grantRaidReward(player, bossId, droneCredits, droneCodes)
	if bossId == "Locus" then
		-- Локус использует свою формулу награды (пока считаем как 1 выживший)
		local reward = LocusLogic.rewardForRaid(1, LocusConfig)
		DataStoreManager.addCredits(player, reward.credits)
		DataStoreManager.addGlitchCode(player, reward.glitchCode)
		print(string.format("[Raid] Локус побеждён. Награда: %d кредитов, %d кодов, %d осколков",
			reward.credits, reward.glitchCode, reward.spaceShard))
	else
		local fullCredits = EconomyLogic.rewardForRaid(DRONE_COUNT, true)
		local fullCodes = EconomyLogic.glitchCodeForRaid(DRONE_COUNT, true)
		DataStoreManager.addCredits(player, fullCredits - droneCredits)
		DataStoreManager.addGlitchCode(player, fullCodes - droneCodes)
	end
end

function RaidManager.startRaid(player, onComplete)
	if activeRaids[player.UserId] then return end
	activeRaids[player.UserId] = true

	local drones = spawnDrones(RAID_ORIGIN)

	watchDrones(drones, function()
		print("[Raid] Дроны зачищены. Спавн босса...")

		local droneCredits = EconomyLogic.rewardForRaid(DRONE_COUNT, false)
		local droneCodes = EconomyLogic.glitchCodeForRaid(DRONE_COUNT, false)
		DataStoreManager.addCredits(player, droneCredits)
		DataStoreManager.addGlitchCode(player, droneCodes)

		local bossId, boss = pickBoss()
		print("[Raid] Выпал босс:", bossId)

		watchBoss(boss, function()
			print("[Raid] Босс побеждён. Выдача финальной награды.")
			grantRaidReward(player, bossId, droneCredits, droneCodes)

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
