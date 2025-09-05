--!strict
-- Lightweight analytics fan-out (print + pcall datastore if needed)
local Telemetry = {}

function Telemetry:Init() end
function Telemetry:Start() end

local function safe(t: {[string]: any}): string
	local ok, j = pcall(function() return game:GetService("HttpService"):JSONEncode(t) end)
	return ok and j or "<payload>"
end

function Telemetry:Event(name: string, payload: {[string]: any}?)
	print(("[Telemetry] %s %s"):format(name, payload and safe(payload) or ""))
end

return Telemetry
