-- Логика шкалы Глитч-Заражения.
-- Растёт во время рейда, снижается поддержкой (Куб Мугэн).
-- Чистая логика — тестируется без Roblox.

local GlitchMeter = {}

GlitchMeter.MAX = 100
GlitchMeter.MIN = 0

-- Скорость роста в секунду (базовая)
GlitchMeter.BASE_GROWTH = 1.5

-- Насколько снижает саппорт за одно применение
GlitchMeter.SUPPORT_REDUCTION = 25

-- Пороги эффектов
GlitchMeter.THRESHOLDS = {
	whisper = 30,    -- шёпот, лёгкие помехи
	distortion = 60, -- искажение экрана, монстры видят лучше
	critical = 90,   -- критические глюки, риск потери контроля
}

-- Создать новое значение (0)
function GlitchMeter.new()
	return 0
end

-- Увеличить на amount (по умолчанию — за 1 секунду)
function GlitchMeter.grow(current, amount)
	amount = amount or GlitchMeter.BASE_GROWTH
	local new = current + amount
	if new > GlitchMeter.MAX then
		new = GlitchMeter.MAX
	end
	return new
end

-- Снизить саппортом
function GlitchMeter.reduce(current, amount)
	amount = amount or GlitchMeter.SUPPORT_REDUCTION
	local new = current - amount
	if new < GlitchMeter.MIN then
		new = GlitchMeter.MIN
	end
	return new
end

-- Какой уровень эффекта сейчас
function GlitchMeter.getStage(current)
	if current >= GlitchMeter.THRESHOLDS.critical then
		return "critical"
	elseif current >= GlitchMeter.THRESHOLDS.distortion then
		return "distortion"
	elseif current >= GlitchMeter.THRESHOLDS.whisper then
		return "whisper"
	end
	return "clear"
end

-- Множитель урона монстров в зависимости от заражения
function GlitchMeter.damageMultiplier(current)
	local ratio = current / GlitchMeter.MAX
	return 1 + ratio * 0.5 -- от 1.0 до 1.5
end

-- Сколько секунд до максимума при текущей скорости
function GlitchMeter.secondsToMax(current, growthRate)
	growthRate = growthRate or GlitchMeter.BASE_GROWTH
	if growthRate <= 0 then return math.huge end
	local remaining = GlitchMeter.MAX - current
	return remaining / growthRate
end

return GlitchMeter
