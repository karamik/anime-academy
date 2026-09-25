local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local GlitchService = {}

function GlitchService:Add(player, amount)
    PlayerDataService:AddGlitch(player, amount)

    local glitch = player:GetAttribute("Glitch") or 0

    if glitch >= GameConfig.Glitch.CriticalThreshold then
        player:SetAttribute("GlitchState", "Critical")
    elseif glitch >= GameConfig.Glitch.WarningThreshold then
        player:SetAttribute("GlitchState", "Warning")
    else
        player:SetAttribute("GlitchState", "Stable")
    end
end

function GlitchService:Reset(player)
    PlayerDataService:SetGlitch(player, 0)
    player:SetAttribute("GlitchState", "Stable")
end

function GlitchService:Start()
    task.spawn(function()
        while true do
            task.wait(5)

            for _, player in Players:GetPlayers() do
                local glitch = player:GetAttribute("Glitch") or 0

                if glitch > 0 then
                    self:Add(player, -GameConfig.Glitch.PassiveDecay)
                end
            end
        end
    end)
end

return GlitchService
