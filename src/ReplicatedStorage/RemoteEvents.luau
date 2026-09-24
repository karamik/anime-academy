local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

local EVENTS = {
	"DealDamage",
	"UseAbility",
	"GiveQuest",
	"CompleteQuest",
	"RollGacha",
	"UpdateHUD",
	"WeaponDialogue",
}

local folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RemoteEvents"
	folder.Parent = ReplicatedStorage
end

for _, name in ipairs(EVENTS) do
	local existing = folder:FindFirstChild(name)
	if not existing then
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	RemoteEvents[name] = folder[name]
end

return RemoteEvents
