local WeaponConfig = {}

WeaponConfig.Weapons = {
	Rasetsu = {
		id = "Rasetsu",
		displayName = "Расецу — Сегментированный Клык",
		type = "Melee",
		damage = 15,
		cooldown = 0.4,
		range = 8,
		rarity = "R",
		dialogue = {
			onEquip = "Не спи, нас сожрут!",
			onKill = "Вот так, ещё одного!",
			onLowHP = "Отходи, я прикрою!",
		},
	},
	Aeter = {
		id = "Aeter",
		displayName = "Близнецы Аэтер",
		type = "Ranged",
		damage = 10,
		cooldown = 0.3,
		range = 60,
		rarity = "R",
		dialogue = {
			onEquip = "Держи дистанцию, юнец.",
			onKill = "Чисто.",
			onLowHP = "Отходи к стене. Сейчас.",
		},
	},
	Mugen = {
		id = "Mugen",
		displayName = "Фрактальный Куб «Мугэн»",
		type = "Support",
		damage = 5,
		cooldown = 1.0,
		range = 20,
		rarity = "R",
		dialogue = {
			onEquip = "Ты опять промахнёшься? Ладно, искривлю пространство…",
			onKill = "Хм. Сойдёт.",
			onLowHP = "Не паникуй. Держу барьер.",
		},
	},
}

function WeaponConfig.get(weaponId)
	return WeaponConfig.Weapons[weaponId]
end

return WeaponConfig
