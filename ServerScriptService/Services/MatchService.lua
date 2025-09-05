--!strict
-- Teams, rounds, Civic Night
local TeamsService = game:GetService("Teams")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Telemetry = require(script.Parent.TelemetryService)
local MiniGameService = require(script.Parent.MiniGameService)
local InfluenceService = require(script.Parent.InfluenceService)

local Match = {}
Match._phase = "Lobby" :: "Lobby" | "MiniGame" | "CivicNight" | "Results"

local teamObjects: {[string]: Team} = {}

local function ensureTeams()
	for _, name in ipairs(Config.Teams) do
		local t = TeamsService:FindFirstChild(name) :: Team?
		if not t then
			t = Instance.new("Team")
			t.Name = name
			t.TeamColor = BrickColor.new(Color3.new(1,1,1))
			t.AutoAssignable = false
			t.Parent = TeamsService
		end
		teamObjects[name] = t
	end
end

local function autoBalance()
	local players = Players:GetPlayers()
	table.sort(players, function(a,b) return a.UserId < b.UserId end)
	for i, p in ipairs(players) do
		local teamName = Config.Teams[((i - 1) % #Config.Teams) + 1]
		p.Team = teamObjects[teamName]
	end
end

local function broadcastState(phase: string, seconds: number)
	Remotes.RE_MatchStateChanged():FireAllClients({phase=phase, seconds=seconds})
end

local function collectTeamScoresFromPayload(payload: {[number]: {UserId: number, Team: string, Points: number}}): {[string]: number}
	local scores: {[string]: number} = {}
	for _, rec in pairs(payload) do
		local t = rec.Team
		scores[t] = (scores[t] or 0) + (rec.Points or 0)
	end
	return scores
end

function Match:Init()
	ensureTeams()
end

function Match:Start()
	task.spawn(function()
		while true do
			-- Lobby
			self._phase = "Lobby"
			autoBalance()
			broadcastState(self._phase, Config.LobbySeconds)
			task.wait(Config.LobbySeconds)

			-- Mini-Game block
			self._phase = "MiniGame"
			local mgList = {"DebateDash", "FieldOps", "MediaMixer", "TownHall"}
			local mgName = mgList[math.random(1, #mgList)]
			Telemetry:Event("MiniGameStart", {name=mgName})
			broadcastState(self._phase, Config.MiniGameSeconds)

			local context = {
				Remotes = Remotes,
				Config = Config,
				Signals = require(ReplicatedStorage.Shared.Signals),
				Services = {InfluenceService = InfluenceService, Telemetry = Telemetry},
				MatchRoundSeconds = Config.MiniGameSeconds,
			}
			local endedSignal = require(ReplicatedStorage.Shared.Signals).new()
			local endedPayload: any = nil
			-- proxy: watch for RE.MiniGame.End to capture final payload
			local conn = Remotes.RE_MiniGame_End().OnServerEvent:Connect(function(_, payload)
				endedPayload = payload
				endedSignal:Fire(payload)
			end)

			MiniGameService:StartMiniGame(mgName, context)

			local t0 = os.clock()
			while os.clock() - t0 < Config.MiniGameSeconds do
				task.wait(0.25)
				if endedPayload then break end
			end

			MiniGameService:StopMiniGame()
			conn:Disconnect()
			Telemetry:Event("MiniGameEnd", {name=mgName})

			-- Influence map apply
			if typeof(endedPayload) == "table" and endedPayload.RoundResults then
				local teamScores = collectTeamScoresFromPayload(endedPayload.RoundResults)
				InfluenceService:ApplyMiniGameResult(teamScores :: any)
			end

			-- Check threshold
			local thresholdHit: boolean = false
			local winnerTeam: string? = nil
			local connThreshold = InfluenceService.ThresholdReached:Once(function(team: string)
				thresholdHit = true
				winnerTeam = team
			end)

			if not thresholdHit then
				-- small pause before loop again
				task.wait(2)
			end
			connThreshold:Disconnect()

			if thresholdHit and winnerTeam then
				-- Civic Night
				self._phase = "CivicNight"
				broadcastState(self._phase, Config.CivicNightSeconds)
				Telemetry:Event("MatchResult", {winner=winnerTeam})
				task.wait(Config.CivicNightSeconds)

				-- Results
				self._phase = "Results"
				broadcastState(self._phase, Config.ResultsSeconds)
				task.wait(Config.ResultsSeconds)

				-- Reset national meters (simple seasonless reset)
				-- (Restart InfluenceService by re-init)
				require(script.Parent.InfluenceService):Init()
			end
		end
	end)
end

return Match
