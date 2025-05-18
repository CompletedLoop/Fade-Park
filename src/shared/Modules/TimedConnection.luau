local TimedConnection = {}
TimedConnection.__index = TimedConnection

function TimedConnection.new(Connection: RBXScriptSignal, Callback: (...any) -> (), Sleep: number)
	local self = setmetatable({}, TimedConnection)
	self.LastFire = 0

	self.connection = Connection:Connect(function(...)
		local now = os.time()
		if (now - self.LastFire) > Sleep then
			task.spawn(Callback, ...)
			self.LastFire = now
		end
	end)

	return self
end

function TimedConnection:destroy()
	self.connection:Disconnect()
	self = {}
end

return TimedConnection