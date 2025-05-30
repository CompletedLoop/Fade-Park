local Packet = require(script.Packet)

local Packets = {
	SamplePing = Packet("SamplePing"):Response(Packet.String);
	
	Ragdoll = Packet("Ragdoll");
}

return Packets
