--!strict
-- HUD + Map overlay + Match timers
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local MapOverlayBuilder = require(game:GetService("StarterGui").UI["MapOverlay.screenGui"])
local HUDBuilder = require(game:GetService("StarterGui").UI["HUD.screenGui"])

local mapGui: ScreenGui? = nil
local hudGui: ScreenGui? = nil

local zoneFrames: {[string]: Frame} = {}

local function colorForTeam(team: string): Color3
	return (Config.TeamColors :: any)[team] or Color3.fromRGB(200,200,200)
end

local function ensureGUIs()
	if not mapGui then
		mapGui, zoneFrames = MapOverlayBuilder()
	end
	if not hudGui then
		hudGui = HUDBuilder()
	end
end

ensureGUIs()

Remotes.RE_InfluenceChanged().OnClientEvent:Connect(function(zoneId: string, team: string, _amount: number)
	if not zoneFrames[zoneId] then return end
	zoneFrames[zoneId].BackgroundColor3 = colorForTeam(team)
end)

Remotes.RE_MatchStateChanged().OnClientEvent:Connect(function(payload: {[string]: any})
	if not hudGui then return end
	local phase = payload.phase :: string
	local seconds = payload.seconds :: number
	local timerLabel = hudGui:FindFirstChild("Timer") :: TextLabel?
	local phaseLabel = hudGui:FindFirstChild("Phase") :: TextLabel?
	if timerLabel then timerLabel.Text = tostring(seconds).."s" end
	if phaseLabel then phaseLabel.Text = phase end
end)
