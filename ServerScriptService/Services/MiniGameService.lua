--!strict
-- Registry and lifecycle: Start/Stop interface
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ReplicatedStorage.Shared.Signals)

local MiniGameService = {}
MiniGameService._active = nil :: {[string]: any}?
MiniGameService._endedConn = nil :: any

function MiniGameService:Init() end
function MiniGameService:Start() end

local function serverModule(name: string): ModuleScript
	local mod = ReplicatedStorage:WaitForChild("MiniGames"):WaitForChild(name):WaitForChild("Server.controller") :: ModuleScript
	return mod
end

function MiniGameService:StartMiniGame(name: string, context: {[string]: any})
	if self._active then
		warn("[MiniGameService] Already running a mini-game")
		return
	end
	local mod = require(serverModule(name))
	local result = mod.Start(context) :: {EndedBindable: any}
	self._active = {Name = name, Module = mod, Result = result}
	self._endedConn = result.EndedBindable:Once(function(payload)
		self:StopMiniGame()
	end)
end

function MiniGameService:StopMiniGame()
	if not self._active then return end
	local m = self._active
	self._active = nil
	if self._endedConn then
		self._endedConn:Disconnect()
		self._endedConn = nil
	end
	if m and m.Module and m.Module.Stop then
		m.Module.Stop()
	end
end

return MiniGameService
