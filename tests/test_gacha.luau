-- Тест логики гачи: проверяем, что рандом всегда выдаёт валидное оружие
local path = "src/ReplicatedStorage/WeaponConfig.luau"
local WeaponConfig = loadfile(path)()

local weaponPool = {"Rasetsu", "Aeter", "Mugen"}

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

print("Тесты гачи:")

-- 1. Пул не пустой
check("Пул содержит 3 оружия", #weaponPool == 3)

-- 2. Каждое оружие из пула существует в конфиге
for _, id in ipairs(weaponPool) do
	local w = WeaponConfig.get(id)
	check("Оружие " .. id .. " есть в конфиге", w ~= nil)
end

-- 3. 1000 прокрутов — все валидные
math.randomseed(os.time())
local valid = 0
for i = 1, 1000 do
	local roll = weaponPool[math.random(1, #weaponPool)]
	if WeaponConfig.get(roll) then
		valid = valid + 1
	end
end
check("1000 прокрутов, все валидные", valid == 1000)

-- 4. Распределение: все оружия выпадают
local counts = {Rasetsu = 0, Aeter = 0, Mugen = 0}
for i = 1, 3000 do
	local roll = weaponPool[math.random(1, #weaponPool)]
	counts[roll] = counts[roll] + 1
end
print(string.format("  Распределение: Rasetsu=%d, Aeter=%d, Mugen=%d",
	counts.Rasetsu, counts.Aeter, counts.Mugen))
check("Rasetsu выпал", counts.Rasetsu > 0)
check("Aeter выпал", counts.Aeter > 0)
check("Mugen выпал", counts.Mugen > 0)

-- 5. Нет сильного перекоса (каждое оружие от 20% до 46%)
for id, count in pairs(counts) do
	local percent = count / 3000
	check(string.format("%s в диапазоне 20%%–46%% (%.1f%%)", id, percent * 100),
		percent >= 0.20 and percent <= 0.46)
end

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
