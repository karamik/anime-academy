-- Тест логики прокачки оружия
local path = "src/ReplicatedStorage/WeaponUpgrade.luau"
local WeaponUpgrade = loadfile(path)()

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

print("Тесты WeaponUpgrade:")

-- Урон на уровнях (база 100, чтобы легко считать)
check("Урон на ур.1 = 100", WeaponUpgrade.damageAtLevel(100, 1) == 100)
check("Урон на ур.2 = 120", WeaponUpgrade.damageAtLevel(100, 2) == 120)
check("Урон на ур.3 = 140", WeaponUpgrade.damageAtLevel(100, 3) == 140)
check("Урон на ур.4 = 160", WeaponUpgrade.damageAtLevel(100, 4) == 160)
check("Урон на ур.5 = 180", WeaponUpgrade.damageAtLevel(100, 5) == 180)

-- Кулдаун на уровнях (база 1.0)
check("Кулдаун на ур.1 = 1.0", WeaponUpgrade.cooldownAtLevel(1.0, 1) == 1.0)
check("Кулдаун на ур.2 = 0.95", math.abs(WeaponUpgrade.cooldownAtLevel(1.0, 2) - 0.95) < 0.001)
check("Кулдаун на ур.3 = 0.90", math.abs(WeaponUpgrade.cooldownAtLevel(1.0, 3) - 0.90) < 0.001)
check("Кулдаун на ур.5 = 0.80", math.abs(WeaponUpgrade.cooldownAtLevel(1.0, 5) - 0.80) < 0.001)

-- Защита от переполнения
check("Уровень 0 = уровень 1", WeaponUpgrade.damageAtLevel(100, 0) == 100)
check("Уровень 99 = уровень 5", WeaponUpgrade.damageAtLevel(100, 99) == 180)

-- Минимальный кулдаун
local lowCd = WeaponUpgrade.cooldownAtLevel(0.05, 5)
check("Кулдаун не ниже 0.1", lowCd >= 0.1)

-- Стоимость
check("Стоимость 1→2 = 300", WeaponUpgrade.costToUpgrade(1) == 300)
check("Стоимость 2→3 = 600", WeaponUpgrade.costToUpgrade(2) == 600)
check("Стоимость 3→4 = 1200", WeaponUpgrade.costToUpgrade(3) == 1200)
check("Стоимость 4→5 = 2400", WeaponUpgrade.costToUpgrade(4) == 2400)
check("Стоимость 5→6 = nil (максимум)", WeaponUpgrade.costToUpgrade(5) == nil)

-- Проверка возможности апгрейда
check("С 500 кредитами апгрейд 1→2 можно", WeaponUpgrade.canUpgrade(1, 500))
check("С 299 кредитами апгрейд 1→2 нельзя", not WeaponUpgrade.canUpgrade(1, 299))
check("На максимуме апгрейд нельзя", not WeaponUpgrade.canUpgrade(5, 9999))

-- Сам апгрейд
local newLevel, newCredits = WeaponUpgrade.upgrade(1, 1000)
check("После апгрейда уровень = 2", newLevel == 2)
check("После апгрейда кредиты = 700", newCredits == 700)

local failLevel = WeaponUpgrade.upgrade(1, 100)
check("Апгрейд без денег = nil", failLevel == nil)

-- Полная стоимость до максимума
local totalFrom1 = WeaponUpgrade.totalCostToMax(1)
print(string.format("  Полная прокачка с ур.1 до ур.5: %d кредитов", totalFrom1))
check("Всего от 1 до 5 = 4500", totalFrom1 == 300 + 600 + 1200 + 2400)

local totalFrom4 = WeaponUpgrade.totalCostToMax(4)
check("Всего от 4 до 5 = 2400", totalFrom4 == 2400)

local totalFromMax = WeaponUpgrade.totalCostToMax(5)
check("С максимума = 0", totalFromMax == 0)

-- DPS на разных уровнях
local dpsBase = WeaponUpgrade.dpsAtLevel(12, 0.6, 1)
local dpsMax = WeaponUpgrade.dpsAtLevel(12, 0.6, 5)
print(string.format("  DPS Расецу: ур.1 = %.2f, ур.5 = %.2f", dpsBase, dpsMax))
check("DPS на максимуме выше базового", dpsMax > dpsBase)
check("DPS вырос примерно в 2.25 раза",
	math.abs(dpsMax / dpsBase - 2.25) < 0.05)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
