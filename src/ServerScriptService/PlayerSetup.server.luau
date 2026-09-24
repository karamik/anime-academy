local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	print("[Хроно] Игрок зашёл:", player.Name)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end)
end)
