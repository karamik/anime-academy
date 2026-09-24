-- Тест конфига оружия: работает через обычный Lua 5.4
local path = "src/ReplicatedStorage/WeaponConfig.luau"

local chunk, err = loadfile(path)
if not chunk then
	error("Не удалось загрузить WeaponConfig: " .. tostring(err))
end

local WeaponConfig = chunk()

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

print("Тесты WeaponConfig:")

check("Weapons — это таблица", type(WeaponConfig.Weapons) == "table")

local ids = {"Rasetsu", "Aeter", "Mugen"}
for _, id in ipairs(ids) do
	local w = WeaponConfig.get(id)
	check(id .. " существует", w ~= nil)
	if w then
		check(id .. " damage > 0", w.damage > 0)
		check(id .. " cooldown > 0", w.cooldown > 0)
		check(id .. " range > 0", w.range > 0)
		check(id .. " dialogue.onEquip", w.dialogue ~= nil and w.dialogue.onEquip ~= nil)
	end
end

check("Несуществующее оружие = nil", WeaponConfig.get("Nonexistent") == nil)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
