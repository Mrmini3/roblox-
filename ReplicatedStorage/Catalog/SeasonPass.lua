--!strict
-- Simple season pass tiers (cosmetics + XP only)
local SeasonPass = {
	Tiers = {
		{ XP = 100, Reward = {Kind="Emblem", Id="Starcrest"} },
		{ XP = 250, Reward = {Kind="Trail", Id="Ion"} },
		{ XP = 450, Reward = {Kind="Emote", Id="Clap"} },
		{ XP = 700, Reward = {Kind="Emblem", Id="CyanWave"} },
	},
}

return SeasonPass
