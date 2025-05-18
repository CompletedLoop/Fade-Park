local RunService = game:GetService("RunService")

local BaseInterface = {
	OnStart = function(method: () -> ())
		task.spawn(method)
	end;

	OnTick = function(method: (delta: number) -> ())
		RunService.Heartbeat:Connect(method)
	end;
}

local ServiceInterface = {
}

local ControllerInterface = {
	RenderStepped = function(method: (delta: number) -> ())
		RunService.RenderStepped:Connect(method)
	end;
}

return function (Path: Folder)
	for _, Module: ModuleScript in Path:GetDescendants() do
		if not Module:IsA("ModuleScript") then continue end
		local ModuleType = if RunService:IsServer() then "Service" else "Controller"
		if not Module.Name:match(ModuleType) then continue end

		local LoadedModule = require(Module)

		local ModuleInterface = if ModuleType == "Service" then ServiceInterface else ControllerInterface
		for KeyMethod, Action in pairs(BaseInterface) do
			local method = LoadedModule[KeyMethod]
			if method then
				Action(method)
			end
		end
		for KeyMethod, Action in pairs(ModuleInterface) do
			local method = LoadedModule[KeyMethod]
			if method then
				Action(method)
			end
		end
		
		print(`Loaded {ModuleType}: {Module.Parent.Name}.{Module.Name}`)
	end
end