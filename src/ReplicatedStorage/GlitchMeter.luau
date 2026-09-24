-- Glitch infection meter logic.
-- Grows during raids, reduced by support (Mugen Cube).
-- Pure logic — testable without Roblox.

local GlitchMeter = {}

GlitchMeter.MAX = 100
GlitchMeter.MIN = 0

-- Base growth per second
GlitchMeter.BASE_GROWTH = 1.5

-- Support reduction per use
GlitchMeter.SUPPORT_REDUCTION = 25

-- Effect thresholds
GlitchMeter.THRESHOLDS = {
	whisper = 30,    -- whispers, light noise
	distortion = 60, -- screen distortion, monsters see better
	critical = 90,   -- critical glitches, risk of losing control
}

-- Create a new value (0)
function GlitchMeter.new()
	return 0
end

-- Increase by amount (default: one second worth)
function GlitchMeter.grow(current, amount)
	amount = amount or GlitchMeter.BASE_GROWTH
	local new = current + amount
	if new > GlitchMeter.MAX then
		new = GlitchMeter.MAX
	end
	return new
end

-- Reduce via support
function GlitchMeter.reduce(current, amount)
	amount = amount or GlitchMeter.SUPPORT_REDUCTION
	local new = current - amount
	if new < GlitchMeter.MIN then
		new = GlitchMeter.MIN
	end
	return new
end

-- Current effect stage
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

-- Monster damage multiplier based on infection
function GlitchMeter.damageMultiplier(current)
	local ratio = current / GlitchMeter.MAX
	return 1 + ratio * 0.5 -- from 1.0 to 1.5
end

-- Seconds until max at given growth rate
function GlitchMeter.secondsToMax(current, growthRate)
	growthRate = growthRate or GlitchMeter.BASE_GROWTH
	if growthRate <= 0 then return math.huge end
	local remaining = GlitchMeter.MAX - current
	return remaining / growthRate
end

return GlitchMeter
