-- Weapon configuration. All player-facing strings in English.

local WeaponConfig = {}

WeaponConfig.Weapons = {
	Rasetsu = {
		id = "Rasetsu",
		displayName = "Rasetsu — Segmented Fang",
		type = "Melee",
		damage = 12,
		cooldown = 0.6,
		range = 8,
		rarity = "R",
		dialogue = {
			onEquip = "Wake up, they're about to eat us!",
			onKill = "That's one down. Keep going!",
			onLowHP = "Fall back, I'll cover you!",
		},
	},
	Aeter = {
		id = "Aeter",
		displayName = "Aeter Twins",
		type = "Ranged",
		damage = 8,
		cooldown = 0.4,
		range = 60,
		rarity = "R",
		dialogue = {
			onEquip = "Keep your distance, kid.",
			onKill = "Clean shot.",
			onLowHP = "Get to the wall. Now.",
		},
	},
	Mugen = {
		id = "Mugen",
		displayName = "Fractal Cube \"Mugen\"",
		type = "Support",
		damage = 5,
		cooldown = 1.0,
		range = 20,
		rarity = "R",
		dialogue = {
			onEquip = "Missed again? Fine, I'll bend space for you...",
			onKill = "Hmph. Acceptable.",
			onLowHP = "Don't panic. Barrier's up.",
		},
	},
}

function WeaponConfig.get(weaponId)
	return WeaponConfig.Weapons[weaponId]
end

return WeaponConfig
