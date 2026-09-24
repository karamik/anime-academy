-- Логика прокачки оружия. Чистая логика, без Roblox.
-- Каждый уровень даёт +20% к базовому урону и -5% к кулдауну.

local WeaponUpgrade = {}

WeaponUpgrade.MAX_LEVEL = 5

-- Стоимость перехода на уровень (индекс = уровень)
WeaponUpgrade.Costs = {
	[1] = 0,     -- стартовый уровень
	[2] = 300,
	[3] = 600,
	[4] = 1200,
	[5] = 2400,
}

-- Множители
local DAMAGE_PER_LEVEL = 0.20 -- +20% за уровень
local COOLDOWN_PER_LEVEL = 0.05 -- -5% за уровень

-- Урон с учётом уровня
function WeaponUpgrade.damageAtLevel(baseDamage, level)
	if level < 1 then level = 1 end
	if level > WeaponUpgrade.MAX_LEVEL then level = WeaponUpgrade.MAX_LEVEL end
	local multiplier = 1 + (level - 1) * DAMAGE_PER_LEVEL
	return math.floor(baseDamage * multiplier + 0.5)
end

-- Кулдаун с учётом уровня (не ниже 0.1 сек)
function WeaponUpgrade.cooldownAtLevel(baseCooldown, level)
	if level < 1 then level = 1 end
	if level > WeaponUpgrade.MAX_LEVEL then level = WeaponUpgrade.MAX_LEVEL end
	local multiplier = 1 - (level - 1) * COOLDOWN_PER_LEVEL
	local result = baseCooldown * multiplier
	if result < 0.1 then result = 0.1 end
	return result
end

-- Стоимость апгрейда с уровня N на N+1
function WeaponUpgrade.costToUpgrade(currentLevel)
	local nextLevel = currentLevel + 1
	if nextLevel > WeaponUpgrade.MAX_LEVEL then return nil end
	return WeaponUpgrade.Costs[nextLevel]
end

-- Можно ли апгрейднуть
function WeaponUpgrade.canUpgrade(currentLevel, credits)
	if currentLevel >= WeaponUpgrade.MAX_LEVEL then return false end
	local cost = WeaponUpgrade.costToUpgrade(currentLevel)
	if not cost then return false end
	return credits >= cost
end

-- Апгрейд: возвращает новую пару (level, credits) или nil
function WeaponUpgrade.upgrade(currentLevel, credits)
	if not WeaponUpgrade.canUpgrade(currentLevel, credits) then return nil end
	local cost = WeaponUpgrade.costToUpgrade(currentLevel)
	return currentLevel + 1, credits - cost
end

-- Полная стоимость прокачки до максимума
function WeaponUpgrade.totalCostToMax(fromLevel)
	local total = 0
	for lvl = fromLevel + 1, WeaponUpgrade.MAX_LEVEL do
		total = total + WeaponUpgrade.Costs[lvl]
	end
	return total
end

-- Итоговое DPS оружия с учётом уровня
function WeaponUpgrade.dpsAtLevel(baseDamage, baseCooldown, level)
	local dmg = WeaponUpgrade.damageAtLevel(baseDamage, level)
	local cd = WeaponUpgrade.cooldownAtLevel(baseCooldown, level)
	return dmg / cd
end

return WeaponUpgrade
