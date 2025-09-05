--!strict
-- Simple shop GUI with buttons
return function(): ScreenGui
	local Players = game:GetService("Players")
	local gui = Instance.new("ScreenGui")
	gui.Name = "Shop"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 10

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(0.28, 0.42)
	root.Position = UDim2.fromScale(0.03, 0.55)
	root.BackgroundTransparency = 0.2
	root.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,6)
	layout.Parent = root

	local function mkBtn(name: string, txt: string): TextButton
		local b = Instance.new("TextButton")
		b.Name = name
		b.Size = UDim2.fromScale(1, 0.16)
		b.BackgroundTransparency = 0.2
		b.TextScaled = true
		b.Text = txt
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root
		return b
	end

	mkBtn("BtnMediaBurst", "Buy: Media Burst (Dev Product)")
	mkBtn("BtnFieldTeam",  "Buy: Field Team Pack (Dev Product)")
	mkBtn("BtnFlashPoll",  "Buy: Flash Poll (Dev Product)")
	mkBtn("BtnStrategist", "Gamepass: Strategist Pro")
	mkBtn("BtnHQBuilder",  "Gamepass: HQ Builder")
	mkBtn("BtnReplay",     "Gamepass: Replay Studio")

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return gui
end
