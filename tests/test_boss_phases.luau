-- Тест логики фаз босса: проверяем пороги переключения
-- Логика повторяет BossController, но без Roblox-зависимостей

local BOSS_MAX_HEALTH = 500
local PHASE_2_THRESHOLD = 0.6

local function getPhase(hp)
	local ratio = hp / BOSS_MAX_HEALTH
	if ratio <= PHASE_2_THRESHOLD then
		return 2
	end
	return 1
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

print("Тесты фаз босса:")

check("При 500 HP — фаза 1", getPhase(500) == 1)
check("При 400 HP — фаза 1", getPhase(400) == 1)
check("При 301 HP — фаза 1", getPhase(301) == 1)
check("При 300 HP — фаза 2 (ровно порог)", getPhase(300) == 2)
check("При 299 HP — фаза 2", getPhase(299) == 2)
check("При 150 HP — фаза 2", getPhase(150) == 2)
check("При 1 HP — фаза 2", getPhase(1) == 2)
check("При 0 HP — фаза 2", getPhase(0) == 2)

-- Проверка границы: 60% от 500 = 300
check("Порог = 300", BOSS_MAX_HEALTH * PHASE_2_THRESHOLD == 300)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
