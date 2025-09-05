--!strict
-- Bridges MiniGameService events to client controllers
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local activeName: string? = nil
local activeMod: any = nil

local function clientModule(name: string): ModuleScript
	return ReplicatedStorage:WaitForChild("MiniGames"):WaitForChild(name):WaitForChild("Client.controller") :: ModuleScript
end

Remotes.RE_MiniGame_Start().OnClientEvent:Connect(function(name: string, payload: {[string]: any})
	if activeMod then
		activeMod.Unbind()
		activeMod = nil
	end
	activeName = name
	activeMod = require(clientModule(name))
	if activeMod and activeMod.Bind then
		activeMod.Bind(payload)
	end
end)

Remotes.RE_MiniGame_End().OnClientEvent:Connect(function(payload: {[string]: any})
	if activeMod and activeMod.Unbind then
		activeMod.Unbind()
		activeMod = nil
	end
	activeName = nil
end)
