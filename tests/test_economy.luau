-- Тест логики экономики: награды, цены, покупки
local path = "src/ReplicatedStorage/EconomyLogic.luau"
local EconomyLogic = loadfile(path)()

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

print("Тесты экономики:")

-- Награды за убийство
check("Дрон даёт 10 кредитов", EconomyLogic.rewardForKill("drone") == 10)
check("Босс даёт 100 кредитов", EconomyLogic.rewardForKill("boss") == 100)
check("Неизвестный враг = 0", EconomyLogic.rewardForKill("ghost") == 0)

-- Награда за рейд: 5 дронов + босс + бонус
local fullRaid = EconomyLogic.rewardForRaid(5, true)
local expected = 5 * 10 + 100 + 50
check("Полный рейд = 200 кредитов", fullRaid == expected)
print(string.format("  Полный рейд: %d кредитов", fullRaid))

-- Рейд без босса
local droneOnly = EconomyLogic.rewardForRaid(5, false)
check("Рейд без босса = 100 кредитов", droneOnly == 5 * 10 + 50)

-- Глитч-коды
local codes = EconomyLogic.glitchCodeForRaid(5, true)
check("Глитч-коды за полный рейд = 10", codes == 5 * 1 + 5)
print(string.format("  Глитч-коды за рейд: %d", codes))

-- Проверка покупки
check("С 200 кредитами можно купить крутку", EconomyLogic.canAfford(200, "gachaRoll"))
check("С 199 кредитами нельзя купить крутку", not EconomyLogic.canAfford(199, "gachaRoll"))
check("С 0 кредитами нельзя купить ничего", not EconomyLogic.canAfford(0, "gachaRoll"))
check("Несуществующий товар = false", not EconomyLogic.canAfford(9999, "spaceship"))

-- Покупка
local afterPurchase = EconomyLogic.purchase(500, "gachaRoll")
check("После покупки крутки (500-200) = 300", afterPurchase == 300)

local failedPurchase = EconomyLogic.purchase(100, "gachaRoll")
check("Покупка без денег = nil", failedPurchase == nil)

-- Сколько рейдов на крутку
local raids = EconomyLogic.raidsNeededFor("gachaRoll", 5, true)
print(string.format("  Рейдов на крутку (200 кредитов): %d", raids))
check("На крутку нужно 1 рейд (200 = 200)", raids == 1)

-- Сколько рейдов на топовый апгрейд (1200)
local raidsTop = EconomyLogic.raidsNeededFor("weaponUpgradeTier3", 5, true)
print(string.format("  Рейдов на апгрейд +3 (1200 кредитов): %d", raidsTop))
check("На топовый апгрейд нужно 6 рейдов", raidsTop == 6)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
