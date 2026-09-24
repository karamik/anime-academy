-- Тест боевого баланса: сколько ударов надо на дрона и босса
local path = "src/ReplicatedStorage/WeaponConfig.luau"
local WeaponConfig = loadfile(path)()

local DRONE_HEALTH = 50
local BOSS_HEALTH = 8000

local function hitsToKill(damage, health)
	return math.ceil(health / damage)
end

local function dps(weaponId)
	local w = WeaponConfig.get(weaponId)
	return w.damage / w.cooldown
end

local passed = 0
local failed = 0

local function check(name, condition)
	if condition then
		passed = passed + 1
		print("  [OK]   " .. name)
	else
		failed = failed + 1
		print("  [FAIL] " .. name)
	end
end

print("Тесты боевого баланса:")

-- Дрон (50 HP)
local rasetsuHits = hitsToKill(WeaponConfig.get("Rasetsu").damage, DRONE_HEALTH)
local aeterHits = hitsToKill(WeaponConfig.get("Aeter").damage, DRONE_HEALTH)
local mugenHits = hitsToKill(WeaponConfig.get("Mugen").damage, DRONE_HEALTH)

print(string.format("  Дрон (50 HP): Расецу=%d ударов, Аэтер=%d, Мугэн=%d",
	rasetsuHits, aeterHits, mugenHits))

check("Дрон убивается за 3–6 ударов Расецу", rasetsuHits >= 3 and rasetsuHits <= 6)
check("Дрон убивается за 5–8 ударов Аэтер", aeterHits >= 5 and aeterHits <= 8)
check("Дрон убивается за 8–12 ударов Мугэн", mugenHits >= 8 and mugenHits <= 12)

-- Реалистичный состав команды:
-- 2x Расецу (ближний), 1x Аэтер (дальний), 1x Мугэн (поддержка)
local teamDPS = dps("Rasetsu") * 2 + dps("Aeter") + dps("Mugen")
local teamSeconds = BOSS_HEALTH / teamDPS

print(string.format("  DPS команды (2 Расецу + Аэтер + Мугэн): %.1f", teamDPS))
print(string.format("  Босс (8000 HP) вчетвером: %.1f сек", teamSeconds))

check("Босс убивается командой за 60–180 секунд",
	teamSeconds >= 60 and teamSeconds <= 180)

-- Соло игрок должен страдать, но убить
local soloDPS = dps("Rasetsu")
local soloSeconds = BOSS_HEALTH / soloDPS
print(string.format("  Босс в одиночку: %.1f сек", soloSeconds))
check("Соло занимает дольше, чем команда в 3 раза",
	soloSeconds > teamSeconds * 3)

-- Роли
check("Мугэн слабее Расецу по урону",
	WeaponConfig.get("Mugen").damage < WeaponConfig.get("Rasetsu").damage)
check("Мугэн слабее Аэтер по урону",
	WeaponConfig.get("Mugen").damage < WeaponConfig.get("Aeter").damage)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
