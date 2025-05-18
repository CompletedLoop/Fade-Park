local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService.Server.ServerModules
local ProfileService = require(ServerModules.ProfileService)

------------------------------------------------------------------------------------------------------------
PlayerDataService = {
	
	LoadPlayerProfile = function()
		
	end;

	ReleasePlayerProfile = function()
		
	end;

}

------------------------------------------------------------------------------------------------------------
return PlayerDataService