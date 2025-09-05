--!strict
-- DebateDash client: draws prompt + captures quick reaction
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local Module = {}
local gui: ScreenGui? = nil
local label: TextLabel? = nil
local reacting = false
local currentRound = 0

local function ensureGui(): ()
	if gui then return end
	gui = Instance.new("ScreenGui")
	gui.Name = "DebateDashHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	local tl = Instance.new("TextLabel")
	tl.Name = "Prompt"
	tl.Size = UDim2.fromScale(0.6, 0.2)
	tl.Position = UDim2.fromScale(0.2, 0.1)
	tl.BackgroundTransparency = 0.3
	tl.TextScaled = true
	tl.Font = Enum.Font.GothamBlack
	tl.Text = "Get Ready..."
	tl.TextColor3 = Color3.new(1,1,1)
	tl.Parent = gui
	label = tl
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local inputConn: RBXScriptConnection?

local function bindInput()
	if inputConn then inputConn:Disconnect() end
	inputConn = UserInputService.InputBegan:Connect(function(io, gpe)
		if gpe then return end
		if not reacting then return end
		if io.UserInputType == Enum.UserInputType.Keyboard then
			reacting = false
			Remotes.MG_Event("DebateDash","React"):FireServer({round=currentRound})
		elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
			reacting = false
			Remotes.MG_Event("DebateDash","React"):FireServer({round=currentRound})
		end
	end)
end

function Module.Bind()
	ensureGui()
	bindInput()

	Remotes.MG_Event("DebateDash","Prompt").OnClientEvent:Connect(function(payload)
		currentRound = payload.round :: number
		if label then
			label.Text = ("ROUND %d — React! (Click or any key)"):format(currentRound)
		end
		reacting = true
	end)

	Remotes.MG_Event("DebateDash","RoundResult").OnClientEvent:Connect(function(payload)
		if label then
			label.Text = ("Round %d done."):format(payload.round :: number)
		end
	end)
end

function Module.Unbind()
	reacting = false
	if inputConn then inputConn:Disconnect() end
	if gui then gui:Destroy() gui = nil label = nil end
end

return Module
