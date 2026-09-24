-- Locus boss configuration. All player-facing strings in English.

local LocusConfig = {}

LocusConfig.id = "Locus"
LocusConfig.displayName = "Professor Locus — Space Rift"
LocusConfig.location = "Broken Geometry Classroom"

LocusConfig.Phases = {
	Split = {
		name = "Rift",
		duration = 120,
		cloneHealth = 500,
		playerTaskTimeout = 30,
		reflectDamagePercent = 0.3,
	},
	Collapse = {
		name = "Collapse",
		startHealthPercent = 0.5,
		bossHealth = 3000,
		teleportInterval = 20,
		beamInterval = 8,
		cloneSpawnInterval = 30,
		cloneCount = 4,
		cloneHealth = 200,
		cloneExplodeTime = 10,
		cloneExplodeDamage = 40,
	},
	Singularity = {
		name = "Point Singularity",
		startHealthPercent = 0.3,
		reflectDamage = 5,
		selfDestructTime = 20,
		selfDestructDamage = 999,
		selfDestructRadius = 10,
	},
}

LocusConfig.RoleTasks = {
	Melee = {
		name = "Destroy space nodes",
		targetCount = 3,
		description = "Destroy 3 neon cubes",
	},
	Ranged = {
		name = "Shoot down coordinates",
		targetCount = 5,
		description = "Shoot down 5 flying coordinates",
	},
	Support = {
		name = "Maintain barrier",
		targetCount = 1,
		description = "Keep your allies alive from clones",
	},
}

LocusConfig.Rewards = {
	credits = 150,
	glitchCode = 8,
	bonusPerSurvivor = 50,
	spaceShard = 1,
}

LocusConfig.Dialogue = {
	onStart = "D-did you l-like staying t-together? N-not anymore.",
	onTaskFail = "O-one of y-you... s-stayed in the p-pocket... f-forever.",
	onPhase2 = "C-collapsing... t-to a p-point...",
	onPhase3 = "Y-you can't hit... w-without h-hurting yourself...",
	onDeath = "...between two points... there is always... a third path...",
}

return LocusConfig
