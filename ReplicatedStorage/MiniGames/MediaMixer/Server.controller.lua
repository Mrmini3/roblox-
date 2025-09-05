--!strict
-- MediaMixer (stub): pattern puzzle
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signals = require(ReplicatedStorage.Shared.Signals)

local Module = {}
local active = false
local ended = Signals.new()

function Module.Start(context: {[string]: any})
	if active then return {EndedBindable = ended} end
	active = true
	Remotes.RE_MiniGame_Start():FireAllClients("MediaMixer", {stub=true})
	task.delay(math.min(context.MatchRoundSeconds, 10), function()
		Remotes.RE_MiniGame_End():FireAllClients({name="MediaMixer", RoundResults={}})
		active = false
		ended:Fire({name="MediaMixer", RoundResults={}})
	end)
	return {EndedBindable = ended}
end

function Module.Stop() active = false end

return Module
