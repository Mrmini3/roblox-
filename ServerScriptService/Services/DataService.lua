--!strict
-- Profile load/save with pcall guards
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Schema = require(ServerStorage:WaitForChild("DataSchemas"))
local Telemetry = require(script.Parent:WaitForChild("TelemetryService"))

local Profiles = {}
local Store = nil :: GlobalDataStore?

local function ds(): GlobalDataStore
	if Store then return Store end
	local ok, dsObj = pcall(function()
		return DataStoreService:GetDataStore("CivicClash_Profiles_v1")
	end)
	if ok then
		Store = dsObj
	else
		warn("[DataService] DataStore unavailable")
	end
	return Store :: GlobalDataStore
end

function Profiles:Init() end
function Profiles:Start()
	Players.PlayerRemoving:Connect(function(p) self:Release(p) end)
end

local Active: {[number]: {[string]: any}} = {}

function Profiles:Load(p: Player): {[string]: any}
	local userId = p.UserId
	if Active[userId] then return Active[userId] end
	local profile: {[string]: any} = Schema.New(userId)
	local ok, data = pcall(function()
		return ds():GetAsync(("p:%d"):format(userId))
	end)
	if ok and typeof(data) == "table" then
		profile = Schema.Migrate(data)
	end
	Active[userId] = profile
	Telemetry:Event("SessionStart", {UserId=userId})
	return profile
end

function Profiles:Save(userId: number)
	local data = Active[userId]
	if not data then return end
	local tries = 0
	while tries < 3 do
		tries += 1
		local ok = pcall(function()
			ds():SetAsync(("p:%d"):format(userId), data)
		end)
		if ok then break end
		task.wait(0.4 * tries)
	end
end

function Profiles:Get(userId: number): {[string]: any}
	return Active[userId]
end

function Profiles:GetPublicProfile(userId: number): {[string]: any}
	local src = Active[userId]
	if not src then return Schema.New(userId) end
	-- shallow copy, server is authority anyway
	local copy: {[string]: any} = {}
	for k, v in pairs(src) do
		copy[k] = typeof(v) == "table" and table.clone(v) or v
	end
	return copy
end

function Profiles:Release(p: Player)
	local userId = p.UserId
	self:Save(userId)
	Active[userId] = nil
end

return Profiles
