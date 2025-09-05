--!strict
-- Simple cosmetics-only shop
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local ShopBuilder = require(game:GetService("StarterGui").UI["Shop.screenGui"])

local gui = ShopBuilder()

local function preflight(productId: number): boolean
	local ok = false
	local rf = Remotes.RF_PurchaseProduct()
	local s, res = pcall(function()
		return rf:InvokeServer(productId)
	end)
	ok = s and res == true
	return ok
end

-- Dev Products buttons
local function hookButton(name: string, productId: number)
	local btn = gui:FindFirstChild(name)
	if not btn or not btn:IsA("TextButton") then return end
	btn.MouseButton1Click:Connect(function()
		if preflight(productId) then
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
		end
	end)
end

hookButton("BtnMediaBurst", Config.DP_MEDIA_BURST)
hookButton("BtnFieldTeam", Config.DP_FIELD_TEAM)
hookButton("BtnFlashPoll", Config.DP_FLASH_POLL)

-- Gamepasses
local function hookPass(name: string, passId: number)
	local btn = gui:FindFirstChild(name)
	if not btn or not btn:IsA("TextButton") then return end
	btn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, passId)
	end)
end

hookPass("BtnStrategist", Config.GAMEPASS_ID_STRATEGIST)
hookPass("BtnHQBuilder",  Config.GAMEPASS_ID_HQBUILDER)
hookPass("BtnReplay",     Config.GAMEPASS_ID_REPLAY)
