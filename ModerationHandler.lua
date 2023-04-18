--[[
		Focuses on moderation, but can also run any sort of command from any user.
		Commands can be easily set up via the Module:AddRank(...) function and the commands submodule.
]]

------------► ► ►	SERVICES	◄ ◄ ◄------------

local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local MessagingService = game:GetService("MessagingService")
local DataStoreService = game:GetService("DataStoreService")

------------► ► ►	VARIABLES	◄ ◄ ◄------------

local ModerationStore = DataStoreService:GetDataStore("ModerationStore")

local Repository = "https://raw.githubusercontent.com/nyuwaea/moderation/main/"
local ListName = "test1.json"
local RefreshTime = 150

local FirstLoaded = false
local Ranks = {}
local Commands = {}
local Prefix = "!"
local CommandFunctions

local CommandResponseEvent = Instance.new("RemoteEvent")
CommandResponseEvent.Name = "CommandResponseEvent"
CommandResponseEvent.Parent = ReplicatedStorage:WaitForChild("Remotes")

------------► ► ►	 MODULE		◄ ◄ ◄------------

local Moderation = {}
Moderation.__index = Moderation

function Moderation.Init(): {}
	local self = setmetatable({}, Moderation)
	
	CommandFunctions = require(script.Commands)
	
	script.CommandResponse.Parent = game.StarterPlayer.StarterPlayerScripts
	
	Moderation:AddRank(255, "Owner", {game.CreatorId, -1})
	Moderation:AddRank(50, "Admin")
	Moderation:AddRank(40, "Mod")
	Moderation:AddRank(0, "Guest")
	
	Moderation:AddCommand(0, "debug")
	Moderation:AddCommand(40, "ban")
	Moderation:AddCommand(40, "unban")
	Moderation:AddCommand(40, "kick")
	
	coroutine.wrap(function()
		while true do
			Moderation:Refresh()
			task.wait(RefreshTime)
		end
	end)()
	
	PlayerService.PlayerAdded:Connect(function(player)
		local success, result = pcall(function()
			return ModerationStore:GetAsync(tostring(player.UserId))
		end)
		
		if success then
			if result[3] > os.time() then
				player:Kick("You were banned for: " .. result[2] .. " ----- Time left: " .. tostring(math.floor(result[3] - os.time() + .5)) .. " seconds")
			end
		else
			warn("Couldn't load ban data for " .. player.UserId .. "\nReason: " .. tostring(result))
			player:Kick("Couldn't load ban data")
		end
	end)
	
	MessagingService:SubscribeAsync("Bans", function(message: {[string]: string | number})
		local banData = message.Data:split("||") 
		
		if PlayerService:FindFirstChild(banData[1]) then
			PlayerService[banData[1]]:Kick("You were banned for: " .. banData[2] .. " ----- Time left: " .. tostring(math.floor(tonumber(banData[3]) - os.time() + .5)) .. " seconds")
		end
	end)
	
	print("[" .. script.Name .. "]: Successfully initialized")
		
	return self
end

function Moderation:Refresh(): ()
	self._loading = true

	local success, result = pcall(function()
		return HttpService:GetAsync(Repository .. ListName, true)
	end)

	if success then
		local list = HttpService:JSONDecode(result)
		
		for rank, userList in pairs(list) do
			if Ranks[rank] then
				Ranks[rank].users = userList
			else
				warn("Rank not found: " .. rank)
			end
		end
	else
		warn("Failed to load moderation list: " .. Repository .. ListName .. "\nReason: " .. result)
	end
	
	FirstLoaded = true
	self._loading = false
end

function Moderation:AddCommand(power: number, alias: string): ()
	Commands[alias] = power
	
	coroutine.wrap(function()
		local commandInstance = Instance.new("TextChatCommand")
		
		commandInstance.Name = alias
		commandInstance.PrimaryAlias = Prefix .. alias
		commandInstance.Parent = TextChatService:WaitForChild("TextChatCommands", 30)
		commandInstance.Triggered:Connect(function(textSource: TextSource, text: string)
			local player = PlayerService:FindFirstChild(textSource.Name)
			local power = Moderation.GetRank(textSource.UserId)
			local split = text:split(" ")
			local command = split[1]:sub(2, split[1]:len()):lower()
			local args = {}

			for i = 2, #split do
				args[#args + 1] = split[i]
			end
			
			CommandResponseEvent:FireClient(player, "MESSAGE", text)
			
			if player and Commands[command] and power >= Commands[command] then
				if CommandFunctions[command] then
					local success, systemMessage = CommandFunctions[command]({userID = textSource.UserId, power = power}, args)
					
					CommandResponseEvent:FireClient(player, "COMMAND", "<b>" .. command:upper() .. ":</b> " .. tostring(systemMessage), success)
				else
					local errorString = "Could not find command function for command: " .. command:upper()
					
					warn(errorString)
					CommandResponseEvent:FireClient(player, "COMMAND", "<b>" .. errorString .. "</b>", false)
				end
			end
		end)
	end)()
end

function Moderation:AddRank(power: number, name: string, users: {[number]: number}?): ()
	Ranks[name] = {
		power = power,
		users = users or {}
	}
end

function Moderation.GetRank(ID: number): (number, string)
	for rank, rankInfo in pairs(Ranks) do
		for _, user in pairs(rankInfo.users) do
			if user == ID then
				return rankInfo.power, rank
			end
		end
	end
	
	return 0, "Guest"
end

function Moderation.GetRankOnModerationFirstLoaded(...): string
	while not FirstLoaded and task.wait() do end
	return Moderation.GetRank(...)
end

return Moderation
