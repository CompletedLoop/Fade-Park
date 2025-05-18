local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packets = require(ReplicatedStorage.Shared.Packets)

return function(): number
	local now = os.clock()

	Packets.SamplePing:Fire()

	local difference = os.clock() - now
	local ping = math.round(difference * 1000)

	return ping
end