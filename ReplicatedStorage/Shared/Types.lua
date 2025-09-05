--!strict
-- Types.lua
export type TeamName = "Northstar" | "Meridian" | "Harbor"

export type Entitlements = {
	StrategistPro: boolean,
	HQBuilder: boolean,
	ReplayStudio: boolean,
}

export type Equipped = {
	Emblem: string?,
	Trail: string?,
	Emote1: string?,
}

export type Stats = {
	Matches: number,
	Wins: number,
	StateFlips: number,
	Streak: number,
}

export type Profile = {
	UserId: number,
	Coins: number,
	XP: number,
	SeasonXP: number,
	OwnedCosmetics: {[string]: boolean},
	Equipped: Equipped,
	Entitlements: Entitlements,
	Stats: Stats,
}

export type MatchPhase = "Lobby" | "MiniGame" | "CivicNight" | "Results"

export type MiniGameServerStartResult = {
	EndedBindable: any, -- Shared.Signal
}

export type MiniGameContext = {
	Remotes: any,
	Config: any,
	Signals: any,
	Services: {[string]: any},
	MatchRoundSeconds: number,
}

export type TeamScores = {[TeamName]: number}

return {}
