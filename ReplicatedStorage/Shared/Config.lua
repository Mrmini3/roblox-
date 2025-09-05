--!strict
-- Game-wide constants and knobs
local Config = {}

-- Teams (3 squads)
Config.Teams = {"Northstar", "Meridian", "Harbor"} :: {string}

-- Colors for simple UI (no real-world logos)
Config.TeamColors = {
	Northstar = Color3.fromRGB(70, 170, 255),
	Meridian  = Color3.fromRGB(255, 160, 60),
	Harbor    = Color3.fromRGB(100, 220, 150),
}

-- Match pacing
Config.LobbySeconds = 20
Config.MiniGameSeconds = 100 -- 90–120
Config.CivicNightSeconds = 12
Config.ResultsSeconds = 8

-- Influence system
Config.ZoneCount = 50
Config.ZoneIdPrefix = "Zone"
Config.NationalInfluenceThreshold = 500 -- first team to reach this wins
Config.InfluencePerWin = 10
Config.InfluenceSecond = 6
Config.InfluenceThird = 3
Config.InfluenceMaxPerMiniGame = 15

-- DebateDash minigame
Config.DebateDashRounds = 6
Config.DebateDashPromptWindow = 2.0 -- seconds to react
Config.DebateDashPointsByRank = {10,7,5,3,2,1}

-- Economy (PLACEHOLDERS)
Config.GAMEPASS_ID_STRATEGIST = 1001001
Config.GAMEPASS_ID_HQBUILDER  = 1001002
Config.GAMEPASS_ID_REPLAY     = 1001003

Config.DP_MEDIA_BURST  = 2002001
Config.DP_FIELD_TEAM   = 2002002
Config.DP_FLASH_POLL   = 2002003

-- Rate limits
Config.RateLimits = {
	PurchasePreflightPerMin = 8,
	MiniGameClientActionPerSec = 5,
}

return Config
