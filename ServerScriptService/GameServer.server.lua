--!strict
-- Boots services, remotes, receipt handler, match loop
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

local ServicesFolder = script:WaitForChild("Services")
local Telemetry = require(ServicesFolder:WaitForChild("TelemetryService"))
local AntiExploit = require(ServicesFolder:WaitForChild("AntiExploitService"))
local DataService  = require(ServicesFolder:WaitForChild("DataService"))
local EconomyService = require(ServicesFolder:WaitForChild("EconomyService"))
local InfluenceService = require(ServicesFolder:WaitForChild("InfluenceService"))
local MiniGameService = require(ServicesFolder:WaitForChild("MiniGameService"))
local MatchService = require(ServicesFolder:WaitForChild("MatchService"))

local Services = {Telemetry, AntiExploit, DataService, EconomyService, InfluenceService, MiniGameService, MatchService}

-- Init
for _, S in ipairs(Services) do if S.Init then S:Init() end end

-- Remotes binding (server-authority)
Remotes.RF_GetProfile().OnServerInvoke = function(player: Player)
	local prof = DataService:Load(player)
	EconomyService:RefreshEntitlements(player)
	return DataService:GetPublicProfile(player.UserId)
end

Remotes.RF_PurchaseProduct().OnServerInvoke = function(player: Player, productId: number)
	local scope = "purchasePreflight"
	if not AntiExploit:Allow(player, scope, Config.RateLimits.PurchasePreflightPerMin, 60) then
		return false
	end
	if typeof(productId) ~= "number" then return false end
	return EconomyService:PreflightProduct(player, productId)
end

-- Receipt routing
MarketplaceService.ProcessReceipt = function(receiptInfo)
	return EconomyService:ProcessReceipt(receiptInfo)
end

-- Player lifecycle
Players.PlayerAdded:Connect(function(p: Player)
	DataService:Load(p)
	EconomyService:RefreshEntitlements(p)
end)

Players.PlayerRemoving:Connect(function(p: Player)
	DataService:Release(p)
end)

-- Start
for _, S in ipairs(Services) do if S.Start then S:Start() end end
