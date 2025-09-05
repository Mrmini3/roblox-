--!strict
-- Minimal input binder
local UserInputService = game:GetService("UserInputService")

local Input = {}
local actions: {[string]: (input: InputObject) -> ()} = {}

function Input:Register(name: string, fn: (input: InputObject) -> ()): ()
	actions[name] = fn
end

function Input:Unregister(name: string)
	actions[name] = nil
end

UserInputService.InputBegan:Connect(function(io, gpe)
	if gpe then return end
	for _, fn in pairs(actions) do
		fn(io)
	end
end)

return Input
