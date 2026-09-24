-- Единая формула урона. Чистая логика — принимает данные параметрами.
-- В игре CombatHandler сам подгружает WeaponConfig, WeaponUpgrade, GlitchMeter
-- и передаёт нужные значения сюда.

local DamageCalculator = {}

DamageCalculator.MAX_GLITCH = 100

-- Урон по врагу:
--   baseDamage  — базовый урон оружия
--   weaponLevel — уровень прокачки (1..5)
--   glitchValue — текущее заражение (0..100)
--
-- Формула:
--   финальный = baseDamage * (1 + 0.2 * (level - 1)) * glitchPenalty
--   glitchPenalty = 1 - (glitch/100) * 0.3, но не ниже 0.7
function DamageCalculator.calculate(baseDamage, weaponLevel, glitchValue)
	if weaponLevel < 1 then weaponLevel = 1 end
	if weaponLevel > 5 then weaponLevel = 5 end

	local levelMult = 1 + (weaponLevel - 1) * 0.2
	local glitchRatio = glitchValue / DamageCalculator.MAX_GLITCH
	local penalty = 1 - glitchRatio * 0.3
	if penalty < 0.7 then penalty = 0.7 end

	return math.floor(baseDamage * levelMult * penalty + 0.5)
end

-- Кулдаун с учётом уровня (база * (1 - 0.05 * (level-1)), не ниже 0.1)
function DamageCalculator.getCooldown(baseCooldown, weaponLevel)
	if weaponLevel < 1 then weaponLevel = 1 end
	if weaponLevel > 5 then weaponLevel = 5 end
	local mult = 1 - (weaponLevel - 1) * 0.05
	local result = baseCooldown * mult
	if result < 0.1 then result = 0.1 end
	return result
end

-- DPS
function DamageCalculator.dps(baseDamage, baseCooldown, weaponLevel, glitchValue)
	local dmg = DamageCalculator.calculate(baseDamage, weaponLevel, glitchValue)
	local cd = DamageCalculator.getCooldown(baseCooldown, weaponLevel)
	if cd <= 0 then return 0 end
	return dmg / cd
end

-- Командный бонус по ролям
function DamageCalculator.teamBonus(roles)
	local counts = {Melee = 0, Ranged = 0, Support = 0}
	for _, role in ipairs(roles) do
		if counts[role] then
			counts[role] = counts[role] + 1
		end
	end

	local damageBonus = 1.0
	if counts.Melee >= 2 then damageBonus = damageBonus + 0.05 end
	if counts.Ranged >= 2 then damageBonus = damageBonus + 0.03 end

	local glitchResist = 0
	if counts.Support >= 1 then glitchResist = 0.20 end

	return {
		damageBonus = damageBonus,
		glitchResist = glitchResist,
	}
end

-- Ударов до убийства
function DamageCalculator.hitsToKill(baseDamage, weaponLevel, glitchValue, targetHealth)
	local dmg = DamageCalculator.calculate(baseDamage, weaponLevel, glitchValue)
	if dmg <= 0 then return math.huge end
	return math.ceil(targetHealth / dmg)
end

-- Секунд до убийства
function DamageCalculator.timeToKill(baseDamage, baseCooldown, weaponLevel, glitchValue, targetHealth)
	local d = DamageCalculator.dps(baseDamage, baseCooldown, weaponLevel, glitchValue)
	if d <= 0 then return math.huge end
	return targetHealth / d
end

return DamageCalculator
