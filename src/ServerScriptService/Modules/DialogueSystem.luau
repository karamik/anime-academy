-- Weapon dialogue system. All strings in English.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local WeaponConfig = require(ReplicatedStorage:WaitForChild("WeaponConfig"))
local DataStoreManager = require(script.Parent:WaitForChild("DataStoreManager"))

local DialogueSystem = {}

local COOLDOWN = 3
local lastSpoke = {}

local function canSpeak(player)
	local now = os.clock()
	local last = lastSpoke[player.UserId] or 0
	if now - last < COOLDOWN then return false end
	lastSpoke[player.UserId] = now
	return true
end

function DialogueSystem.speak(player, eventKey)
	if not canSpeak(player) then return end

	local data = DataStoreManager.get(player)
	if not data or not data.equippedWeapon then return end

	local config = WeaponConfig.get(data.equippedWeapon)
	if not config or not config.dialogue then return end

	local line = config.dialogue[eventKey]
	if not line then return end

	local channel = TextChatService:FindFirstChild("RBXGeneral")
	if channel then
		channel:DisplaySystemMessage(string.format("[%s]: %s", config.displayName, line))
	else
		print(string.format("[%s]: %s", config.displayName, line))
	end
end

function DialogueSystem.reset(player)
	lastSpoke[player.UserId] = nil
end

return DialogueSystem
