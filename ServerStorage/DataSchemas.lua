--!strict
-- Default profile schema + migration hook
local DefaultProfile = {
	UserId = 0,
	Coins = 0,
	XP = 0,
	SeasonXP = 0,
	OwnedCosmetics = {},
	Equipped = {Emblem = nil, Trail = nil, Emote1 = nil},
	Entitlements = {StrategistPro=false, HQBuilder=false, ReplayStudio=false},
	Stats = {Matches=0, Wins=0, StateFlips=0, Streak=0},
}

local Schema = {}

function Schema.New(userId: number)
	local p = table.clone(DefaultProfile)
	p.UserId = userId
	return p
end

function Schema.Migrate(profile: {[string]: any}): {[string]: any}
	-- In-place safe migration
	for k, v in pairs(DefaultProfile) do
		if profile[k] == nil then
			profile[k] = typeof(v) == "table" and table.clone(v) or v
		end
	end
	return profile
end

return Schema
