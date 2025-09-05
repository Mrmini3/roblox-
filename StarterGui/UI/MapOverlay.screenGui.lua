--!strict
-- Creates a simple 50-zone map as frames; returns (gui, zoneFrames)
return function(): (ScreenGui, {[string]: Frame})
	local Players = game:GetService("Players")
	local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

	local gui = Instance.new("ScreenGui")
	gui.Name = "MapOverlay"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1

	local frame = Instance.new("Frame")
	frame.Name = "MapRoot"
	frame.Size = UDim2.fromScale(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.45, 0.45)
	frame.AnchorPoint = Vector2.new(0.5,0.5)
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromScale(0.09, 0.18) -- 5x10 grid approx
	grid.FillDirectionMaxCells = 10
	grid.CellPadding = UDim2.fromOffset(2,2)
	grid.Parent = frame

	local zones: {[string]: Frame} = {}
	for i=1, Config.ZoneCount do
		local id = string.format("%s%02d", Config.ZoneIdPrefix, i)
		local f = Instance.new("Frame")
		f.Name = id
		f.BackgroundColor3 = Color3.fromRGB(80,80,80)
		f.BorderSizePixel = 0
		f.Parent = frame
		zones[id] = f
	end

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return gui, zones
end
