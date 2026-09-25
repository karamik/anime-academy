local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local GameConfig = require(Shared:WaitForChild("GameConfig"))

local PlayerDataService = {}

local profiles = {}

local function createProfile()
    return {
        Credits = GameConfig.StartingCredits,
        Level = GameConfig.StartingLevel,
        Experience = 0,
        Glitch = GameConfig.StartingGlitch,
        ActiveWeapon = GameConfig.Weapons.StartingWeapon,
        UnlockedWeapons = {
            Rasetsu = true,
        },
        CompletedRaids = {},
    }
end

local function syncAttributes(player, profile)
    player:SetAttribute("Credits", profile.Credits)
    player:SetAttribute("Level", profile.Level)
    player:SetAttribute("Experience", profile.Experience)
    player:SetAttribute("Glitch", profile.Glitch)
    player:SetAttribute("ActiveWeapon", profile.ActiveWeapon)
end

function PlayerDataService:Get(player)
    return profiles[player]
end

function PlayerDataService:AddCredits(player, amount)
    local profile = profiles[player]
    if not profile then
        return false
    end

    profile.Credits += amount
    syncAttributes(player, profile)

    return true
end

function PlayerDataService:SpendCredits(player, amount)
    local profile = profiles[player]

    if not profile or profile.Credits < amount then
        return false
    end

    profile.Credits -= amount
    syncAttributes(player, profile)

    return true
end

function PlayerDataService:SetGlitch(player, value)
    local profile = profiles[player]
    if not profile then
        return
    end

    profile.Glitch = math.clamp(value, 0, GameConfig.Glitch.Max)
    syncAttributes(player, profile)
end

function PlayerDataService:AddGlitch(player, amount)
    local profile = profiles[player]
    if not profile then
        return
    end

    self:SetGlitch(player, profile.Glitch + amount)
end

function PlayerDataService:SetActiveWeapon(player, weaponId)
    local profile = profiles[player]
    if not profile or not profile.UnlockedWeapons[weaponId] then
        return false
    end

    profile.ActiveWeapon = weaponId
    syncAttributes(player, profile)

    return true
end

function PlayerDataService:Init()
    Players.PlayerAdded:Connect(function(player)
        local profile = createProfile()
        profiles[player] = profile

        syncAttributes(player, profile)
    end)

    Players.PlayerRemoving:Connect(function(player)
        profiles[player] = nil
    end)
end

return PlayerDataService
