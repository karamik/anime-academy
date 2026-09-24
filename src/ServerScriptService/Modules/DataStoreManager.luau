-- Player data persistence. All strings in English.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("PlayerData_v1")

local DEFAULT_DATA = {
	credits = 0,
	glitchCode = 0,
	ownedWeapons = {},
	equippedWeapon = nil,
	weaponLevels = {},
	glitch = 0,
	questStage = 0,
}

local DataStoreManager = {}

local cache = {}

local function deepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function loadData(player)
	local key = "player_" .. player.UserId
	local success, result = pcall(function()
		return store:GetAsync(key)
	end)

	if success and result then
		local data = deepCopy(DEFAULT_DATA)
		for k, v in pairs(result) do
			data[k] = v
		end
		return data
	end

	if not success then
		warn("[DataStore] Load failed for", player.Name, ":", result)
	end

	return deepCopy(DEFAULT_DATA)
end

local function saveData(player)
	local data = cache[player.UserId]
	if not data then return end

	local key = "player_" .. player.UserId
	local success, err = pcall(function()
		store:SetAsync(key, data)
	end)

	if not success then
		warn("[DataStore] Save failed for", player.Name, ":", err)
	end
end

function DataStoreManager.get(player)
	return cache[player.UserId]
end

function DataStoreManager.addCredits(player, amount)
	local data = cache[player.UserId]
	if not data then return end
	data.credits = data.credits + amount
end

function DataStoreManager.spendCredits(player, amount)
	local data = cache[player.UserId]
	if not data then return false end
	if data.credits < amount then return false end
	data.credits = data.credits - amount
	return true
end

function DataStoreManager.addGlitchCode(player, amount)
	local data = cache[player.UserId]
	if not data then return end
	data.glitchCode = data.glitchCode + amount
end

function DataStoreManager.giveWeapon(player, weaponId)
	local data = cache[player.UserId]
	if not data then return end
	if not table.find(data.ownedWeapons, weaponId) then
		table.insert(data.ownedWeapons, weaponId)
	end
	if not data.weaponLevels[weaponId] then
		data.weaponLevels[weaponId] = 1
	end
end

function DataStoreManager.equipWeapon(player, weaponId)
	local data = cache[player.UserId]
	if not data then return end
	if table.find(data.ownedWeapons, weaponId) then
		data.equippedWeapon = weaponId
	end
end

function DataStoreManager.getWeaponLevel(player, weaponId)
	local data = cache[player.UserId]
	if not data then return 1 end
	if not data.weaponLevels then return 1 end
	return data.weaponLevels[weaponId] or 1
end

function DataStoreManager.setWeaponLevel(player, weaponId, level)
	local data = cache[player.UserId]
	if not data then return end
	if not data.weaponLevels then data.weaponLevels = {} end
	data.weaponLevels[weaponId] = level
end

function DataStoreManager.setGlitch(player, value)
	local data = cache[player.UserId]
	if not data then return end
	data.glitch = value
end

function DataStoreManager.getGlitch(player)
	local data = cache[player.UserId]
	if not data then return 0 end
	return data.glitch or 0
end

Players.PlayerAdded:Connect(function(player)
	cache[player.UserId] = loadData(player)
	print("[DataStore] Loaded for", player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player)
	cache[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveData(player)
	end
	task.wait(2)
end)

return DataStoreManager
