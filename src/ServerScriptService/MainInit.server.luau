local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local DataStoreManager = require(script.Parent.Modules:WaitForChild("DataStoreManager"))
local WeaponSystem = require(script.Parent.Modules:WaitForChild("WeaponSystem"))
local DialogueSystem = require(script.Parent.Modules:WaitForChild("DialogueSystem"))
local RaidManager = require(script.Parent.Modules:WaitForChild("RaidManager"))

-- Точка спавна хаба (потом заменим на настоящую)
local HUB_SPAWN = Vector3.new(0, 5, 0)

local function teleportToHub(player)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(HUB_SPAWN)
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

		-- Если оружия нет — выдаём стартовое (Расецу)
		if #data.ownedWeapons == 0 then
			DataStoreManager.giveWeapon(player, "Rasetsu")
			DataStoreManager.equipWeapon(player, "Rasetsu")
			task.wait(0.3)
			WeaponSystem.equipWeapon(player, "Rasetsu")
		elseif data.equippedWeapon then
			WeaponSystem.equipWeapon(player, data.equippedWeapon)
		elseif #data.ownedWeapons > 0 then
			DataStoreManager.equipWeapon(player, data.ownedWeapons[1])
			task.wait(0.3)
			WeaponSystem.equipWeapon(player, data.ownedWeapons[1])
		end

		teleportToHub(player)

		task.wait(0.5)
		DialogueSystem.speak(player, "onEquip")
	end)

	-- Запуск рейда по команде с клиента
	RemoteEvents.GiveQuest.OnServerEvent:Connect(function()
		if RaidManager.isActive(player) then return end
		RaidManager.startRaid(player, function()
			RemoteEvents.CompleteQuest:FireClient(player)
		end)
	end)
end)
