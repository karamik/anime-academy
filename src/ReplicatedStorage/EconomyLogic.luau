-- Чистая логика экономики. Без Roblox-зависимостей.
-- Позже используется магазином, гачей за кредиты и апгрейдами.

local EconomyLogic = {}

-- Награды за убийства и рейды
EconomyLogic.Rewards = {
	droneKill = 10,        -- кредитов за одного дрона
	bossKill = 100,        -- кредитов за босса
	raidComplete = 50,     -- бонус за полное прохождение
	glitchCodePerDrone = 1,
	glitchCodePerBoss = 5,
}

-- Цены в магазине
EconomyLogic.Prices = {
	gachaRoll = 200,           -- одна крутка оружия
	weaponUpgradeTier1 = 300,  -- апгрейд +1
	weaponUpgradeTier2 = 600,  -- апгрейд +2
	weaponUpgradeTier3 = 1200, -- апгрейд +3
}

-- Сколько кредитов дать за убийство врага
function EconomyLogic.rewardForKill(enemyType)
	if enemyType == "drone" then
		return EconomyLogic.Rewards.droneKill
	elseif enemyType == "boss" then
		return EconomyLogic.Rewards.bossKill
	end
	return 0
end

-- Итоговая награда за рейд (все дроны + босс + бонус)
function EconomyLogic.rewardForRaid(droneCount, hasBoss)
	local total = droneCount * EconomyLogic.Rewards.droneKill
	if hasBoss then
		total = total + EconomyLogic.Rewards.bossKill
	end
	total = total + EconomyLogic.Rewards.raidComplete
	return total
end

-- Глитч-коды за рейд
function EconomyLogic.glitchCodeForRaid(droneCount, hasBoss)
	local total = droneCount * EconomyLogic.Rewards.glitchCodePerDrone
	if hasBoss then
		total = total + EconomyLogic.Rewards.glitchCodePerBoss
	end
	return total
end

-- Хватает ли кредитов на покупку
function EconomyLogic.canAfford(credits, itemId)
	local price = EconomyLogic.Prices[itemId]
	if not price then return false end
	return credits >= price
end

-- Купить: возвращает новое количество кредитов или nil
function EconomyLogic.purchase(credits, itemId)
	if not EconomyLogic.canAfford(credits, itemId) then
		return nil
	end
	return credits - EconomyLogic.Prices[itemId]
end

-- Сколько рейдов нужно на покупку
function EconomyLogic.raidsNeededFor(itemId, droneCount, hasBoss)
	local price = EconomyLogic.Prices[itemId]
	if not price then return nil end
	local perRaid = EconomyLogic.rewardForRaid(droneCount, hasBoss)
	if perRaid <= 0 then return nil end
	return math.ceil(price / perRaid)
end

return EconomyLogic
