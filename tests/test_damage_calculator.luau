-- Тест единой формулы урона
local path = "src/ReplicatedStorage/DamageCalculator.luau"
local DamageCalculator = loadfile(path)()

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

print("Тесты DamageCalculator:")

-- Базовые случаи
check("Ур.1, глитч 0: урон = база",
	DamageCalculator.calculate(100, 1, 0) == 100)

check("Ур.2, глитч 0: +20%",
	DamageCalculator.calculate(100, 2, 0) == 120)

check("Ур.5, глитч 0: +80%",
	DamageCalculator.calculate(100, 5, 0) == 180)

-- Штраф от Глитча
check("Ур.1, глитч 100: -30%",
	DamageCalculator.calculate(100, 1, 100) == 70)

check("Ур.1, глитч 50: -15%",
	DamageCalculator.calculate(100, 1, 50) == 85)

check("Ур.5, глитч 100: 180 * 0.7 = 126",
	DamageCalculator.calculate(100, 5, 100) == 126)

check("Ур.5, глитч 50: 180 * 0.85 = 153",
	DamageCalculator.calculate(100, 5, 50) == 153)

-- Кулдаун
check("Кулдаун ур.1 = 1.0",
	DamageCalculator.getCooldown(1.0, 1) == 1.0)

check("Кулдаун ур.5 = 0.80",
	math.abs(DamageCalculator.getCooldown(1.0, 5) - 0.80) < 0.001)

check("Кулдаун не ниже 0.1",
	DamageCalculator.getCooldown(0.05, 5) >= 0.1)

-- DPS
local dps1 = DamageCalculator.dps(12, 0.6, 1, 0)
print(string.format("  Расецу ур.1, глитч 0: %.2f DPS", dps1))
check("DPS Расецу ур.1 = 20", math.abs(dps1 - 20) < 0.01)

-- При заражении урон округляется вниз: 12 * 0.7 = 8.4 → 8
-- DPS = 8 / 0.6 = 13.33. Проверяем, что штраф есть и заметный (от 30% до 40%).
local dpsWeak = DamageCalculator.dps(12, 0.6, 1, 100)
local ratio = dpsWeak / dps1
print(string.format("  Расецу ур.1, глитч 100: %.2f DPS (%.1f%% от базового)", dpsWeak, ratio * 100))
check("При макс. заражении DPS падает на 30–40%",
	ratio >= 0.60 and ratio <= 0.70)

-- Командные бонусы
local solo = DamageCalculator.teamBonus({"Melee"})
check("Соло: без бонусов", solo.damageBonus == 1.0 and solo.glitchResist == 0)

local duo = DamageCalculator.teamBonus({"Melee", "Melee"})
check("2 ближних: +5% урона", duo.damageBonus == 1.05)

local duoRanged = DamageCalculator.teamBonus({"Ranged", "Ranged"})
check("2 дальних: +3% урона", duoRanged.damageBonus == 1.03)

local withSupport = DamageCalculator.teamBonus({"Melee", "Support"})
check("С поддержкой: resist 20%", withSupport.glitchResist == 0.20)

local fullTeam = DamageCalculator.teamBonus({"Melee", "Melee", "Ranged", "Support"})
check("Полный состав: +5% урона, 20% resist",
	fullTeam.damageBonus == 1.05 and fullTeam.glitchResist == 0.20)

-- Практика: сколько ударов убить дрона
local hits = DamageCalculator.hitsToKill(12, 1, 0, 50)
check("Дрон (50 HP) за 5 ударов Расецу ур.1", hits == 5)

local hitsMax = DamageCalculator.hitsToKill(12, 5, 0, 50)
check("Дрон (50 HP) за 3 удара Расецу ур.5", hitsMax == 3)

-- При глитч 100 урон = 8, 50/8 = 6.25 → 7 ударов
local hitsGlitch = DamageCalculator.hitsToKill(12, 1, 100, 50)
print(string.format("  Дрон при глитч 100 — %d ударов", hitsGlitch))
check("Дрон при глитч 100 — 7 ударов", hitsGlitch == 7)

-- Время до убийства
local ttkDrone = DamageCalculator.timeToKill(12, 0.6, 1, 0, 50)
print(string.format("  Дрон убивается за %.2f сек (Расецу ур.1)", ttkDrone))
check("TTK дрона ~2.5 сек", math.abs(ttkDrone - 2.5) < 0.1)

local ttkBoss = DamageCalculator.timeToKill(12, 0.6, 5, 0, 8000)
print(string.format("  Босс соло на ур.5: %.1f сек", ttkBoss))
check("Босс соло на ур.5 ~ 174 сек",
	math.abs(ttkBoss - 174.5) < 1.0)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
