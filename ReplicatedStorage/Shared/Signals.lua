--!strict
-- Simple Signal (typed-friendly)
local Signal = {}
Signal.__index = Signal

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean,
}
export type SignalT = {
	Connect: (self: any, fn: (...any) -> ()) -> Connection,
	Once: (self: any, fn: (...any) -> ()) -> Connection,
	Wait: (self: any) -> ...any,
	Fire: (self: any, ...any) -> (),
	Destroy: (self: any) -> (),
}

function Signal.new(): SignalT
	local self: any = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	self._connections = {} :: {RBXScriptConnection}
	return self
end

function Signal:Connect(fn: (...any) -> ()): Connection
	local rbxc = self._bindable.Event:Connect(fn)
	local conn: any = {}
	conn.Connected = true
	function conn:Disconnect()
		if conn.Connected then
			conn.Connected = false
			rbxc:Disconnect()
		end
	end
	table.insert(self._connections, rbxc)
	return conn
end

function Signal:Once(fn: (...any) -> ())
	local c: Connection
	c = self:Connect(function(...)
		if c then c:Disconnect() end
		fn(...)
	end)
	return c
end

function Signal:Wait(): ...any
	return self._bindable.Event:Wait()
end

function Signal:Fire(...: any)
	self._bindable:Fire(...)
end

function Signal:Destroy()
	for _, c in ipairs(self._connections) do
		c:Disconnect()
	end
	self._connections = {}
	self._bindable:Destroy()
end

return Signal
