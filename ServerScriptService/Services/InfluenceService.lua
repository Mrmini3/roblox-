--!strict
-- Server-authoritative influence per zone
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signals = require(ReplicatedStorage.Shared.Signals)
local Telemetry = require(script.Parent.TelemetryService)

type TeamName = Types.TeamName

local Influence = {}
Influence._zones = {} :: {[string]: {[TeamName]: number}}
Influence._national = {Northstar=0, Meridian=0, Harbor=0} :: {[TeamName]: number}
Influence.ThresholdReached = Signals.new()

local zonesList: {string} = {}

local function allZones(): {string}
	if #zonesList > 0 then return zonesList end
	for i=1, Config.ZoneCount do
		zonesList[i] = string.format("%s%02d", Config.ZoneIdPrefix, i)
	end
	return zonesList
end

function Influence:Init()
	for _, z in ipairs(allZones()) do
		self._zones[z] = {Northstar=0, Meridian=0, Harbor=0}
	end
end

function Influence:Start() end

local function broadcast(zoneId: string, team: TeamName, amount: number)
	Remotes.RE_InfluenceChanged():FireAllClients(zoneId, team, amount)
end

function Influence:AddInfluence(team: TeamName, zoneId: string, amount: number)
	amount = math.clamp(amount, 0, Config.InfluenceMaxPerMiniGame)
	local zrec = self._zones[zoneId]
	if not zrec then return end
	zrec[team] += amount
	self._national[team] += amount
	broadcast(zoneId, team, amount)
	for t, total in pairs(self._national) do
		if total >= Config.NationalInfluenceThreshold then
			self.ThresholdReached:Fire(t)
			break
		end
	end
end

function Influence:ApplyMiniGameResult(teamScores: {[TeamName]: number})
	-- Pick a random zone to contest this round
	local z = allZones()[math.random(1, #allZones())]
	-- Rank teams by score
	local order: {TeamName} = {"Northstar","Meridian","Harbor"}
	table.sort(order, function(a,b) return (teamScores[a] or 0) > (teamScores[b] or 0) end)
	local add = {Config.InfluencePerWin, Config.InfluenceSecond, Config.InfluenceThird}
	for i, t in ipairs(order) do
		self:AddInfluence(t, z, add[i] or 0)
	end
end

function Influence:GetNational(): {[TeamName]: number}
	return table.clone(self._national)
end

return Influence
