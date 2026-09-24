local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local DataStoreManager = require(script.Parent.Modules:WaitForChild("DataStoreManager"))
local WeaponSystem = require(script.Parent.Modules:WaitForChild("WeaponSystem"))
local DialogueSystem = require(script.Parent.Modules:WaitForChild("DialogueSystem"))
local RaidManager = require(script.Parent.Modules:WaitForChild("RaidManager"))
local BossController = require(script.Parent.Modules:WaitForChild("BossController"))
local GachaAltar = require(script.Parent.Modules:WaitForChild("GachaAltar"))
local WorldBuilder = require(script.Parent.Modules:WaitForChild("WorldBuilder"))

-- Загружаем CombatHandler, чтобы он подписался на RemoteEvents
require(script.Parent.Modules:WaitForChild("CombatHandler"))

local HUB_SPAWN = Vector3.new(0, 5, 0)
local RAID_SPAWN = Vector3.new(100, 5, 0)

-- Строим мир один раз при старте сервера
WorldBuilder.build()
GachaAltar.start()

local function teleportPlayer(player, position)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(position)
	end
end

Players.PlayerAdded:Connect(function(player)
	print("[Хроно] Подключился:", player.Name)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = 100
		humanoid.Health = 100

		task.wait(1)

		local data = DataStoreManager.get(player)
		if not data then return end

		-- Если оружия нет — НЕ выдаём автоматически. Пусть идёт к алтарю.
		if data.equippedWeapon then
			WeaponSystem.equipWeapon(player, data.equippedWeapon)
		end

		teleportPlayer(player, HUB_SPAWN)

		if data.equippedWeapon then
			task.wait(0.5)
			DialogueSystem.speak(player, "onEquip")
		end
	end)

	-- Кнопка «Взять квест» в HUD
	RemoteEvents.GiveQuest.OnServerEvent:Connect(function()
		if RaidManager.isActive(player) then return end

		-- Телепортируем игрока на арену
		teleportPlayer(player, RAID_SPAWN)

		task.wait(0.5)

		RaidManager.startRaid(player, function()
			RemoteEvents.CompleteQuest:FireClient(player)
			-- Возвращаем в хаб
			task.wait(2)
			teleportPlayer(player, HUB_SPAWN)
		end)
	end)
end)
