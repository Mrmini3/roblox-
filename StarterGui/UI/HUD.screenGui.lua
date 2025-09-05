--!strict
-- Minimal HUD (phase + timer)
return function(): ScreenGui
	local Players = game:GetService("Players")
	local gui = Instance.new("ScreenGui")
	gui.Name = "HUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 2

	local phase = Instance.new("TextLabel")
	phase.Name = "Phase"
	phase.Size = UDim2.fromScale(0.25, 0.08)
	phase.Position = UDim2.fromScale(0.02, 0.02)
	phase.BackgroundTransparency = 0.3
	phase.TextScaled = true
	phase.Font = Enum.Font.GothamBold
	phase.TextColor3 = Color3.new(1,1,1)
	phase.Text = "Lobby"
	phase.Parent = gui

	local timer = Instance.new("TextLabel")
	timer.Name = "Timer"
	timer.Size = UDim2.fromScale(0.12, 0.08)
	timer.Position = UDim2.fromScale(0.8, 0.02)
	timer.BackgroundTransparency = 0.3
	timer.TextScaled = true
	timer.Font = Enum.Font.GothamBold
	timer.TextColor3 = Color3.new(1,1,1)
	timer.Text = "--"
	timer.Parent = gui

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return gui
end
