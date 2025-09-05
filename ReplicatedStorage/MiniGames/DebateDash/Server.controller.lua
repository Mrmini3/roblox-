--!strict
-- DebateDash: Reaction mini-game (server)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ReplicatedStorage.Shared.Signals)

type TeamScores = {[string]: number}

local Module = {}
local active = false
local endedBindable = Signals.new()

local currentRound = 0
local promptStart = 0.0
local reactedThisRound: {[number]: boolean} = {}
local roundScores: {[number]: number} = {} -- per-user points
local leaderboard: {{UserId: number, Team: string, Points: number}} = {}
local connReact: RBXScriptConnection?

local function serverNow(): number
	return os.clock()
end

local function getTeam(player: Player): string
	return player.Team and player.Team.Name or "Northstar"
end

local function startPromptRound()
	currentRound += 1
	reactedThisRound = {}
	promptStart = serverNow()
	local promptEvent = Remotes.MG_Event("DebateDash", "Prompt")
	promptEvent:FireAllClients({round=currentRound, serverTime=promptStart})
end

local function endRoundCompute()
	-- rank by arrival delta; we saved points directly on reception by order
	-- nothing needed here; we broadcast round standings
	local roundEvent = Remotes.MG_Event("DebateDash", "RoundResult")
	-- build a shallow snapshot
	local snap: {{UserId: number, Team: string, Points: number}} = {}
	for userId, pts in pairs(roundScores) do
		local p = Players:GetPlayerByUserId(userId)
		if p then
			table.insert(snap, {UserId=userId, Team=getTeam(p), Points=pts})
		end
	end
	roundEvent:FireAllClients({round=currentRound, snapshot=snap})
end

function Module.Start(context: {[string]: any})
	if active then return {EndedBindable = endedBindable} end
	active = true
	leaderboard = {}
	roundScores = {}
	currentRound = 0

	-- listen for client reacts (server authority)
	local reactEvent = Remotes.MG_Event("DebateDash", "React")
	if connReact then connReact:Disconnect() end
	connReact = reactEvent.OnServerEvent:Connect(function(player: Player, payload: {[string]: any})
		if not active then return end
		if typeof(payload) ~= "table" then return end
		if payload.round ~= currentRound then return end
		-- rate-limit generic per player
		local Anti = require(game.ServerScriptService.Services.AntiExploitService)
		if not Anti:Allow(player, "mg_debate_react", Config.RateLimits.MiniGameClientActionPerSec, 1) then
			return
		end
		-- accept only first reaction per round
		if reactedThisRound[player.UserId] then return end
		reactedThisRound[player.UserId] = true

		-- order-of-arrival scoring (latency tolerant but fair enough)
		local arrivals = 0
		for _, b in pairs(reactedThisRound) do if b then arrivals += 1 end end
		local rank = arrivals
		local award = Config.DebateDashPointsByRank[rank] or 0
		if award > 0 then
			roundScores[player.UserId] = (roundScores[player.UserId] or 0) + award
		end
	end)

	-- announce start
	Remotes.RE_MiniGame_Start():FireAllClients("DebateDash", {rounds=Config.DebateDashRounds, window=Config.DebateDashPromptWindow})

	task.spawn(function()
		for i = 1, Config.DebateDashRounds do
			startPromptRound()
			task.wait(Config.DebateDashPromptWindow)
			endRoundCompute()
			task.wait(0.6)
		end

		-- Finalize payload
		local results: {{UserId: number, Team: string, Points: number}} = {}
		for _, p in ipairs(Players:GetPlayers()) do
			local pts = roundScores[p.UserId] or 0
			table.insert(results, {UserId=p.UserId, Team=getTeam(p), Points=pts})
		end
		table.sort(results, function(a,b) return a.Points > b.Points end)
		leaderboard = results

		-- Send end to clients
		Remotes.RE_MiniGame_End():FireAllClients({name="DebateDash", RoundResults=leaderboard})
		active = false
		endedBindable:Fire({name="DebateDash", RoundResults=leaderboard})
	end)

	return {EndedBindable = endedBindable}
end

function Module.Stop()
	active = false
	if connReact then connReact:Disconnect() end
end

return Module
