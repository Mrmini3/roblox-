--!strict
-- Purchases, entitlements, receipt processing
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Telemetry = require(script.Parent:WaitForChild("TelemetryService"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local Economy = {}

function Economy:Init() end
function Economy:Start()
	-- nothing else; ProcessReceipt is bound in GameServer boot
end

local function grantDevProduct(player: Player, productId: number): boolean
	local profile = DataService:Get(player.UserId)
	if not profile then return false end

	if productId == Config.DP_MEDIA_BURST then
		profile.SeasonXP += 50
	elseif productId == Config.DP_FIELD_TEAM then
		profile.OwnedCosmetics["Trail:Ribbon"] = true
	elseif productId == Config.DP_FLASH_POLL then
		profile.OwnedCosmetics["Emote:Pose"] = true
	else
		return false
	end
	return true
end

function Economy:ProcessReceipt(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision
	local userId = receiptInfo.PlayerId
	local player = Players:GetPlayerByUserId(userId)
	local ok = false
	if player then
		ok = grantDevProduct(player, receiptInfo.ProductId)
	end
	Telemetry:Event("Purchase", {UserId=userId, ProductId=receiptInfo.ProductId, ok=ok})
	if ok then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet -- retry
	end
end

-- Server-side entitlement refresh (gamepasses)
function Economy:RefreshEntitlements(player: Player)
	local profile = DataService:Get(player.UserId)
	if not profile then return end

	local function owns(id: number): boolean
		local s, res = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
		end)
		return s and res == true
	end

	if owns(Config.GAMEPASS_ID_STRATEGIST) then profile.Entitlements.StrategistPro = true end
	if owns(Config.GAMEPASS_ID_HQBUILDER) then profile.Entitlements.HQBuilder = true end
	if owns(Config.GAMEPASS_ID_REPLAY) then profile.Entitlements.ReplayStudio = true end
end

-- Preflight check (rate-limited, *does not* prompt)
function Economy:PreflightProduct(player: Player, productId: number): boolean
	-- Validate a known product ID
	if productId ~= Config.DP_MEDIA_BURST and productId ~= Config.DP_FIELD_TEAM and productId ~= Config.DP_FLASH_POLL then
		return false
	end
	return true
end

return Economy
