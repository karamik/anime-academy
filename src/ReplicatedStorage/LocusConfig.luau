-- Конфиг второго босса: Профессор Локус.
-- Чистые данные, без Roblox-зависимостей.

local LocusConfig = {}

LocusConfig.id = "Locus"
LocusConfig.displayName = "Профессор Локус — Разрыв Пространства"
LocusConfig.location = "Сломанный Класс Геометрии"

-- Фазы
LocusConfig.Phases = {
	Split = {
		name = "Разрыв",
		duration = 120,            -- максимум 2 минуты
		cloneHealth = 500,          -- HP мини-Локуса в каждом кармане
		playerTaskTimeout = 30,     -- если игрок не справился за 30 сек — клон атакует союзника
		reflectDamagePercent = 0.3, -- 30% урона по клону летит в случайного союзника
	},
	Collapse = {
		name = "Схлопывание",
		startHealthPercent = 0.5,   -- начинается при 50% HP
		bossHealth = 3000,
		teleportInterval = 20,      -- каждые 20 сек телепортирует игрока
		beamInterval = 8,           -- каждые 8 сек бьёт лучом
		cloneSpawnInterval = 30,    -- каждые 30 сек выпускает 4 клонов
		cloneCount = 4,
		cloneHealth = 200,
		cloneExplodeTime = 10,      -- если не убить за 10 сек — взрыв
		cloneExplodeDamage = 40,
	},
	Singularity = {
		name = "Схлопывание в точку",
		startHealthPercent = 0.3,   -- начинается при 30% HP
		reflectDamage = 5,          -- 5 урона атакующему за удар
		selfDestructTime = 20,      -- через 20 сек взрыв
		selfDestructDamage = 999,   -- мгновенная смерть в радиусе
		selfDestructRadius = 10,
	},
}

-- Задачи по ролям в фазе «Разрыв»
LocusConfig.RoleTasks = {
	Melee = {
		name = "Разрубить узлы пространства",
		targetCount = 3,
		description = "Уничтожь 3 неоновых куба",
	},
	Ranged = {
		name = "Сбить координаты",
		targetCount = 5,
		description = "Сбей 5 летающих координат",
	},
	Support = {
		name = "Держать барьер",
		targetCount = 1,
		description = "Не дай союзникам умереть от клонов",
	},
}

-- Награды
LocusConfig.Rewards = {
	credits = 150,
	glitchCode = 8,
	bonusPerSurvivor = 50,       -- бонус за каждого выжившего союзника
	spaceShard = 1,              -- Осколок Пространства
}

-- Реплики босса
LocusConfig.Dialogue = {
	onStart = "В-вы лю-любили держаться вм-вместе? Бо-больше не по-получится.",
	onTaskFail = "О-один из в-вас... о-остался в к-кармане... на-навсегда.",
	onPhase2 = "С-схлопываемся... в т-точку...",
	onPhase3 = "Т-ты не мо-можешь бить... не ра-ранив себя...",
	onDeath = "...между двумя точками... всегда есть... третий путь...",
}

return LocusConfig
