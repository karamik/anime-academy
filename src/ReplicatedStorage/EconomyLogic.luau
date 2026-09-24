-- Economy logic. Pure logic, no Roblox dependencies.
-- Used later by shop, gacha rolls, and weapon upgrades.

local EconomyLogic = {}

-- Rewards for kills and raids
EconomyLogic.Rewards = {
	droneKill = 10,        -- credits per drone
	bossKill = 100,        -- credits per boss
	raidComplete = 50,     -- bonus for full clear
	glitchCodePerDrone = 1,
	glitchCodePerBoss = 5,
}

-- Shop prices
EconomyLogic.Prices = {
	gachaRoll = 200,           -- one weapon roll
	weaponUpgradeTier1 = 300,  -- upgrade +1
	weaponUpgradeTier2 = 600,  -- upgrade +2
	weaponUpgradeTier3 = 1200, -- upgrade +3
}

-- Credits granted for killing an enemy
function EconomyLogic.rewardForKill(enemyType)
	if enemyType == "drone" then
		return EconomyLogic.Rewards.droneKill
	elseif enemyType == "boss" then
		return EconomyLogic.Rewards.bossKill
	end
	return 0
end

-- Total reward for a full raid (all drones + boss + bonus)
function EconomyLogic.rewardForRaid(droneCount, hasBoss)
	local total = droneCount * EconomyLogic.Rewards.droneKill
	if hasBoss then
		total = total + EconomyLogic.Rewards.bossKill
	end
	total = total + EconomyLogic.Rewards.raidComplete
	return total
end

-- Glitch codes for a raid
function EconomyLogic.glitchCodeForRaid(droneCount, hasBoss)
	local total = droneCount * EconomyLogic.Rewards.glitchCodePerDrone
	if hasBoss then
		total = total + EconomyLogic.Rewards.glitchCodePerBoss
	end
	return total
end

-- Can the player afford an item
function EconomyLogic.canAfford(credits, itemId)
	local price = EconomyLogic.Prices[itemId]
	if not price then return false end
	return credits >= price
end

-- Purchase: returns new credit balance or nil
function EconomyLogic.purchase(credits, itemId)
	if not EconomyLogic.canAfford(credits, itemId) then
		return nil
	end
	return credits - EconomyLogic.Prices[itemId]
end

-- Raids needed to afford an item
function EconomyLogic.raidsNeededFor(itemId, droneCount, hasBoss)
	local price = EconomyLogic.Prices[itemId]
	if not price then return nil end
	local perRaid = EconomyLogic.rewardForRaid(droneCount, hasBoss)
	if perRaid <= 0 then return nil end
	return math.ceil(price / perRaid)
end

return EconomyLogic
