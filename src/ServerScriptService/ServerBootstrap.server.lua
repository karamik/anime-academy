local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")

local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local GlitchService = require(Services:WaitForChild("GlitchService"))

PlayerDataService:Init()
GlitchService:Start()

print("[AnimeAcademy] Server started")
