-- Тест логики боя с Локусом
local LocusLogic = loadfile("src/ReplicatedStorage/LocusLogic.luau")()
local LocusConfig = loadfile("src/ReplicatedStorage/LocusConfig.luau")()
local WeaponConfig = loadfile("src/ReplicatedStorage/WeaponConfig.luau")()

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

print("Тесты LocusLogic:")

-- Фазы
check("HP 100% — Split", LocusLogic.getPhase(1.0) == "Split")
check("HP 70% — Split", LocusLogic.getPhase(0.7) == "Split")
check("HP 50% — Collapse", LocusLogic.getPhase(0.5) == "Collapse")
check("HP 40% — Collapse", LocusLogic.getPhase(0.4) == "Collapse")
check("HP 30% — Singularity", LocusLogic.getPhase(0.3) == "Singularity")
check("HP 10% — Singularity", LocusLogic.getPhase(0.1) == "Singularity")
check("HP 0% — Singularity", LocusLogic.getPhase(0) == "Singularity")

-- Задачи
local allDone = {Melee = true, Ranged = true, Support = true}
check("Все задачи выполнены", LocusLogic.allTasksComplete(allDone) == true)

local partial = {Melee = true, Ranged = false, Support = true}
check("Не все задачи", LocusLogic.allTasksComplete(partial) == false)

local none = {Melee = false, Ranged = false, Support = false}
check("Никто не справился", LocusLogic.allTasksComplete(none) == false)

check("Счёт: 3 задачи", LocusLogic.countCompleted(allDone) == 3)
check("Счёт: 2 задачи", LocusLogic.countCompleted(partial) == 2)
check("Счёт: 0 задач", LocusLogic.countCompleted(none) == 0)

-- Отражение урона
check("30% от 100 = 30", LocusLogic.reflectDamage(100, 0.3) == 30)
check("30% от 50 = 15", LocusLogic.reflectDamage(50, 0.3) == 15)
check("30% от 12 = 4", LocusLogic.reflectDamage(12, 0.3) == 4)
check("30% от 7 = 2", LocusLogic.reflectDamage(7, 0.3) == 2)

-- Самоурон в 3 фазе
check("Самоурон всегда 5", LocusLogic.selfDamage(999, 5) == 5)

-- Награды
local rewards4 = LocusLogic.rewardForRaid(4, LocusConfig)
check("Кредиты с 4 выжившими = 350", rewards4.credits == 350)

local rewards2 = LocusLogic.rewardForRaid(2, LocusConfig)
check("Кредиты с 2 выжившими = 250", rewards2.credits == 250)

local rewards0 = LocusLogic.rewardForRaid(0, LocusConfig)
check("Кредиты без выживших = 150", rewards0.credits == 150)

check("Глитч-код = 8", rewards0.glitchCode == 8)
check("Осколок Пространства = 1", rewards0.spaceShard == 1)

-- Таймер самоподрыва
check("В начале 20 сек", LocusLogic.timeToSelfDestruct(0, LocusConfig) == 20)
check("Через 5 сек — 15", LocusLogic.timeToSelfDestruct(5, LocusConfig) == 15)
check("Через 20 сек — 0", LocusLogic.timeToSelfDestruct(20, LocusConfig) == 0)
check("Через 25 сек — 0 (не уходит в минус)",
	LocusLogic.timeToSelfDestruct(25, LocusConfig) == 0)

-- Успеет ли добить
check("DPS 300, HP 3000, 20 сек: хватит",
	LocusLogic.canFinishBeforeExplosion(300, 3000, 20) == true)
check("DPS 100, HP 3000, 20 сек: не хватит",
	LocusLogic.canFinishBeforeExplosion(100, 3000, 20) == false)
check("DPS 150, HP 3000, 20 сек: ровно успеют",
	LocusLogic.canFinishBeforeExplosion(150, 3000, 20) == true)
check("DPS 0: невозможно",
	LocusLogic.canFinishBeforeExplosion(0, 3000, 20) == false)

-- Роли
local weapons = {
	["player1"] = "Rasetsu",
	["player2"] = "Aeter",
	["player3"] = "Mugen",
}
local roles = LocusLogic.assignRoles(weapons, WeaponConfig)
check("Игрок 1 — Melee", roles.player1 == "Melee")
check("Игрок 2 — Ranged", roles.player2 == "Ranged")
check("Игрок 3 — Support", roles.player3 == "Support")

check("Команда с 3 ролями валидна", LocusLogic.isTeamValid(roles) == true)

local badTeam = {["p1"] = "Melee", ["p2"] = "Melee"}
check("Команда без поддержки невалидна", LocusLogic.isTeamValid(badTeam) == false)

local noRanged = {["p1"] = "Melee", ["p2"] = "Support"}
check("Команда без дальнего боя невалидна", LocusLogic.isTeamValid(noRanged) == false)

-- Сценарий: команда добивает сферу в 3 фазе
-- Локус: 3000 HP, сфера начинается при 30% = 900 HP
local locusMaxHP = LocusConfig.Phases.Collapse.bossHealth
local sphereHP = math.floor(locusMaxHP * LocusConfig.Phases.Singularity.startHealthPercent)
local teamDPS = 65
local timeLeft = LocusConfig.Phases.Singularity.selfDestructTime

print(string.format("  Локус: %d HP", locusMaxHP))
print(string.format("  Сфера в 3 фазе: %d HP", sphereHP))
print(string.format("  DPS команды: %d", teamDPS))
print(string.format("  Время до взрыва: %d сек", timeLeft))
print(string.format("  Нужно времени: %.1f сек", sphereHP / teamDPS))

check("Команда успевает добить сферу",
	LocusLogic.canFinishBeforeExplosion(teamDPS, sphereHP, timeLeft) == true)

-- Слабая команда
local badDPS = 10
check("Слабая команда не успевает",
	LocusLogic.canFinishBeforeExplosion(badDPS, sphereHP, timeLeft) == false)

-- Проверка через конфиг: 4 игрока с полным составом
local fullTeamDPS = 65 -- из теста баланса (2 Расецу + Аэтер + Мугэн)
check("Полный состав 4 игроков — с запасом",
	LocusLogic.canFinishBeforeExplosion(fullTeamDPS, sphereHP, timeLeft) == true)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
