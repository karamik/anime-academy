local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlitchMeter = require(ReplicatedStorage:WaitForChild("GlitchMeter"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))

local GlitchController = {}

local TICK_RATE = 1 -- раз в секунду
local activePlayers = {}

local function tickPlayer(player)
	local data = DataStoreManager.get(player)
	if not data then return end

	local current = data.glitch or 0
	local new = GlitchMeter.grow(current, GlitchMeter.BASE_GROWTH)
	DataStoreManager.setGlitch(player, new)
end

function GlitchController.startFor(player)
	if activePlayers[player.UserId] then return end
	activePlayers[player.UserId] = true

	task.spawn(function()
		while activePlayers[player.UserId] do
			task.wait(TICK_RATE)
			if not player.Parent then break end
			tickPlayer(player)
		end
	end)
end

function GlitchController.stopFor(player)
	activePlayers[player.UserId] = nil
end

function GlitchController.applySupport(player)
	local data = DataStoreManager.get(player)
	if not data then return end
	local current = data.glitch or 0
	local new = GlitchMeter.reduce(current, GlitchMeter.SUPPORT_REDUCTION)
	DataStoreManager.setGlitch(player, new)
end

function GlitchController.resetFor(player)
	DataStoreManager.setGlitch(player, 0)
end

function GlitchController.getStage(player)
	local data = DataStoreManager.get(player)
	if not data then return "clear" end
	return GlitchMeter.getStage(data.glitch or 0)
end

Players.PlayerRemoving:Connect(function(player)
	GlitchController.stopFor(player)
end)

return GlitchController
