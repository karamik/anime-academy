-- Чистая логика боя с Локусом. Без Roblox-зависимостей.
-- Принимает данные параметрами, возвращает решения.

local LocusLogic = {}

-- Какая фаза при данном проценте HP
function LocusLogic.getPhase(healthPercent)
	if healthPercent <= 0.3 then
		return "Singularity"
	elseif healthPercent <= 0.5 then
		return "Collapse"
	end
	return "Split"
end

-- Сколько игроков справилось с задачей
-- tasks: {Melee = true, Ranged = false, Support = true}
function LocusLogic.allTasksComplete(tasks)
	for _, role in ipairs({"Melee", "Ranged", "Support"}) do
		if not tasks[role] then
			return false
		end
	end
	return true
end

function LocusLogic.countCompleted(tasks)
	local count = 0
	for _, role in ipairs({"Melee", "Ranged", "Support"}) do
		if tasks[role] then
			count = count + 1
		end
	end
	return count
end

-- Сколько урона уйдёт в союзника при ударе по клону
-- reflectPercent — из конфига (0.3 = 30%)
function LocusLogic.reflectDamage(playerDamage, reflectPercent)
	return math.floor(playerDamage * reflectPercent + 0.5)
end

-- Сколько урона босс получит от игрока с отражением
-- В фазе Singularity каждый удар возвращается атакующему
function LocusLogic.selfDamage(attackerDamage, reflectFlat)
	return reflectFlat
end

-- Итоговая награда за Локуса
-- survivors — сколько игроков выжило (0..4)
function LocusLogic.rewardForRaid(survivors, config)
	local credits = config.Rewards.credits
	credits = credits + survivors * config.Rewards.bonusPerSurvivor
	return {
		credits = credits,
		glitchCode = config.Rewards.glitchCode,
		spaceShard = config.Rewards.spaceShard,
	}
end

-- Сколько времени осталось до самоподрыва сферы в 3 фазе
-- elapsed — секунд прошло
function LocusLogic.timeToSelfDestruct(elapsed, config)
	local remain = config.Phases.Singularity.selfDestructTime - elapsed
	if remain < 0 then remain = 0 end
	return remain
end

-- Успеет ли команда добить сферу
-- teamDPS — суммарный DPS, bossHP — текущий HP сферы
function LocusLogic.canFinishBeforeExplosion(teamDPS, bossHP, timeLeft)
	if teamDPS <= 0 then return false end
	local timeNeeded = bossHP / teamDPS
	return timeNeeded <= timeLeft
end

-- Разбить команду по ролям для фазы «Разрыв»
-- weapons: {playerId = "Rasetsu", ...}
function LocusLogic.assignRoles(weapons, weaponConfig)
	local roles = {}
	for playerId, weaponId in pairs(weapons) do
		local config = weaponConfig.get(weaponId)
		if config then
			roles[playerId] = config.type
		end
	end
	return roles
end

-- Проверить, хватает ли ролей для рейда
function LocusLogic.isTeamValid(roles)
	local hasMelee = false
	local hasRanged = false
	local hasSupport = false
	for _, role in pairs(roles) do
		if role == "Melee" then hasMelee = true end
		if role == "Ranged" then hasRanged = true end
		if role == "Support" then hasSupport = true end
	end
	return hasMelee and hasRanged and hasSupport
end

return LocusLogic
