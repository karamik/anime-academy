-- Тест логики шкалы Глитч-Заражения
local path = "src/ReplicatedStorage/GlitchMeter.luau"
local GlitchMeter = loadfile(path)()

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

print("Тесты GlitchMeter:")

-- Начальное значение
check("new() = 0", GlitchMeter.new() == 0)

-- Рост
local g1 = GlitchMeter.grow(0)
check("grow(0) = 1.5", g1 == 1.5)

local g2 = GlitchMeter.grow(50, 10)
check("grow(50, 10) = 60", g2 == 60)

-- Не превышает MAX
local g3 = GlitchMeter.grow(95, 20)
check("grow(95, 20) не превышает 100", g3 == 100)

-- Снижение
local r1 = GlitchMeter.reduce(50)
check("reduce(50) = 25", r1 == 25)

local r2 = GlitchMeter.reduce(50, 60)
check("reduce(50, 60) не уходит ниже 0", r2 == 0)

local r3 = GlitchMeter.reduce(100, 25)
check("reduce(100, 25) = 75", r3 == 75)

-- Стадии
check("Стадия при 0 = clear", GlitchMeter.getStage(0) == "clear")
check("Стадия при 29 = clear", GlitchMeter.getStage(29) == "clear")
check("Стадия при 30 = whisper", GlitchMeter.getStage(30) == "whisper")
check("Стадия при 59 = whisper", GlitchMeter.getStage(59) == "whisper")
check("Стадия при 60 = distortion", GlitchMeter.getStage(60) == "distortion")
check("Стадия при 89 = distortion", GlitchMeter.getStage(89) == "distortion")
check("Стадия при 90 = critical", GlitchMeter.getStage(90) == "critical")
check("Стадия при 100 = critical", GlitchMeter.getStage(100) == "critical")

-- Множитель урона
check("Множитель при 0 = 1.0", GlitchMeter.damageMultiplier(0) == 1.0)
check("Множитель при 100 = 1.5", GlitchMeter.damageMultiplier(100) == 1.5)
check("Множитель при 50 = 1.25", GlitchMeter.damageMultiplier(50) == 1.25)

-- Время до максимума
local t1 = GlitchMeter.secondsToMax(0)
print(string.format("  С 0 до 100 при базовой скорости: %.1f сек", t1))
check("С 0 до 100 ~ 66.7 сек", math.abs(t1 - 66.666) < 0.01)

local t2 = GlitchMeter.secondsToMax(50)
check("С 50 до 100 ~ 33.3 сек", math.abs(t2 - 33.333) < 0.01)

local t3 = GlitchMeter.secondsToMax(50, 5)
check("С 50 при скорости 5 = 10 сек", t3 == 10)

-- Сценарий рейда: 60 секунд без саппорта
print("  Симуляция: 60 сек без саппорта")
local val = 0
for i = 1, 60 do
	val = GlitchMeter.grow(val)
end
print(string.format("    Итог: %.1f, стадия: %s", val, GlitchMeter.getStage(val)))
check("Через 60 сек — critical", GlitchMeter.getStage(val) == "critical")

-- С саппортом каждые 20 сек
print("  Симуляция: 60 сек с саппортом каждые 20 сек")
val = 0
for i = 1, 60 do
	val = GlitchMeter.grow(val)
	if i % 20 == 0 then
		val = GlitchMeter.reduce(val)
	end
end
print(string.format("    Итог: %.1f, стадия: %s", val, GlitchMeter.getStage(val)))
check("С саппортом шкала ниже 100", val < 100)

print(string.format("\nИтог: %d прошло, %d провалено", passed, failed))

if failed > 0 then
	os.exit(1)
end
