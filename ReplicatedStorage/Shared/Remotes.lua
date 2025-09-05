--!strict
-- Remote factory with namespacing and light wrappers
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
RemotesFolder.Name = "Remotes"
RemotesFolder.Parent = ReplicatedStorage

local RF = RemotesFolder:FindFirstChild("RF") or Instance.new("Folder")
RF.Name = "RF"
RF.Parent = RemotesFolder

local RE = RemotesFolder:FindFirstChild("RE") or Instance.new("Folder")
RE.Name = "RE"
RE.Parent = RemotesFolder

local function ensurePath(root: Instance, path: {string}): Instance
	local current = root
	for _, name in ipairs(path) do
		local nxt = current:FindFirstChild(name)
		if not nxt then
			nxt = Instance.new("Folder")
			nxt.Name = name
			nxt.Parent = current
		end
		current = nxt
	end
	return current
end

local Remotes = {}

function Remotes.GetFunction(name: string): RemoteFunction
	local rf = RF:FindFirstChild(name) :: RemoteFunction?
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = RF
	end
	return rf
end

function Remotes.GetEventPath(path: {string}): RemoteEvent
	local parent = ensurePath(RE, {unpack(path, 1, #path-1)})
	local last = path[#path]
	local ev = parent:FindFirstChild(last) :: RemoteEvent?
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = last
		ev.Parent = parent
	end
	return ev
end

-- Named shortcuts per spec
function Remotes.RF_GetProfile(): RemoteFunction
	return Remotes.GetFunction("GetProfile")
end

function Remotes.RF_PurchaseProduct(): RemoteFunction
	return Remotes.GetFunction("PurchaseProduct")
end

function Remotes.RE_MatchStateChanged(): RemoteEvent
	return Remotes.GetEventPath({"MatchStateChanged"})
end

function Remotes.RE_InfluenceChanged(): RemoteEvent
	return Remotes.GetEventPath({"InfluenceChanged"})
end

function Remotes.RE_MiniGame_Start(): RemoteEvent
	return Remotes.GetEventPath({"MiniGame","Start"})
end

function Remotes.RE_MiniGame_End(): RemoteEvent
	return Remotes.GetEventPath({"MiniGame","End"})
end

-- Extra namespaced events for mini-games (allowed, server-auth)
function Remotes.MG_Event(name: string, sub: string): RemoteEvent
	return Remotes.GetEventPath({"MiniGame", name, sub})
end

return Remotes
