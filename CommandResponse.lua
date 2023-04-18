--[[
		Another simple script, client-sided this time. This responds to the user when a command is ran, in the new TextChatService
]]

------------► ► ►	SERVICES	◄ ◄ ◄------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

------------► ► ►	VARIABLES	◄ ◄ ◄------------

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommandResponseEvent = Remotes:WaitForChild("CommandResponseEvent")
local RBXSystemChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")

local Colours: {[boolean]: Color3} = {
	[true] = Color3.fromRGB(192, 255, 192),
	[false] = Color3.fromRGB(255, 192, 192)
}

------------► ► ►	FUNCTIONS	◄ ◄ ◄------------

local function onCommandResponse(responseType: string, text: string, success: boolean): ()
	if responseType == "MESSAGE" then
		RBXSystemChannel:DisplaySystemMessage('<font color="#888888">' .. text .. '</font>')
	elseif responseType == "COMMAND" then
		RBXSystemChannel:DisplaySystemMessage('<font color="#' .. tostring(Colours[success]:ToHex()) .. '">' .. text .. '</font>')
	end
end

CommandResponseEvent.OnClientEvent:Connect(onCommandResponse)
