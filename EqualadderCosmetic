--[[
			Handles all the effects on the Equaladder (equalizer ladder)
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ladder = script.Parent.Parent
local parts = {
	normal = ladder.Cosmetics.Parts.Normal:GetChildren();
	charged = ladder.Cosmetics.Parts.Charged:GetChildren();
}

local mute = true

task.wait(3)

local soundBank = {
	Chirp = {
		id = "rbxassetid://12571664247";
		volume = .3;
		loudnessDivisor = 30;
		BPM = 100;
		offset = 5.000;
	};
	Rudeness = {
		id = "rbxassetid://12580546538";
		volume = 1.7;
		loudnessDivisor = 5;
	};
	Marble_Dove = {
		id = "rbxassetid://9495783481";
		volume = .15;
		loudnessDivisor = 70;
		BPM = 107.5;
		offset = 1.920;
	};
	Asimov = {
		id = "rbxassetid://4500030527";
		volume = .4;
		loudnessDivisor = 20;
		BPM = 64;
		offset = 3.920;
	};
	Carousel_of_Memories = {
		id = "rbxassetid://12582077837";
		volume = .4;
		loudnessDivisor = 30;
		BPM = 32.125;
		offset = 0.100;
	};
}
local pitch = 1
local lastPulse = 0
local song = soundBank.Carousel_of_Memories

local exampleSound = Instance.new("Sound", game:GetService("SoundService"))
exampleSound.SoundId = song.id
exampleSound.Volume = mute and 0 or song.volume
exampleSound.Looped = true
exampleSound.Pitch = pitch
exampleSound:Play()

local start = os.clock()

local minLoudness = {
	[1] = 0;
	[2] = 4;
	[3] = 7;
	[4] = 9;
}
local loudnessDelays = {
	[0] = 0;
	[1] = 0;			-- placeholder vars
	[2] = 0;
}

function Lerp(a, b, t)
	return a + (b - a) * t
end

function GetEQparts()
	local parts = {}
	
	for _, d in ipairs(ladder.Cosmetics.Equalizers:GetDescendants()) do
		if d:IsA("Part") then
			parts[#parts + 1] = {
				obj = d;
				offset = d.Position - ladder.PrimaryPart.Position;
			}
		end
	end
	
	return parts
end

function Pulsate()
	for _, nPart in ipairs(parts.normal) do
		coroutine.wrap(function()
			task.wait((tonumber(nPart.Name) - 1) / 100)

			TweenService:Create(nPart, TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = .8}):Play()

			task.wait(.05)

			TweenService:Create(nPart, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 0}):Play()
		end)()
	end
end

local EQparts = GetEQparts()

RunService.RenderStepped:Connect(function(delta)
	local now = os.clock()
	
	if song.BPM and now - start >= song.offset / pitch then
		local minTime = 1 / (delta * 3600) + .002
		
		if math.floor((now - start - song.offset / pitch) % (60 / song.BPM / pitch) * 1000) / 1000 <= minTime and now - lastPulse >= minTime then
			Pulsate()
			lastPulse = os.clock()
		end
	end
	
	coroutine.wrap(function()
		local loudness = exampleSound.PlaybackLoudness / song.loudnessDivisor
		
		for i = 0, 2 do
			task.wait(i / 10)
			
			loudnessDelays[i] = Lerp(loudnessDelays[i], loudness, .1)
		end
	end)()
	
	for _, cPart in ipairs(parts.charged) do
		cPart.Color = Color3.new(.5, 1, .5):Lerp(Color3.new(1, .5, .5), math.clamp((loudnessDelays[0] - 1) / 10, 0, 1))
	end
	
	for _, part in ipairs(EQparts) do
		local partHeight = tonumber(part.obj.Name)
		local loudness = math.floor((loudnessDelays[(tonumber(part.obj.Parent.Name:sub(3, 3)) - 1)]) * 100 + .5) / 100

		if minLoudness[partHeight] <= loudness then
			local maxSize = 4 - (partHeight - 1)
			
			part.obj.Size = Vector3.new(part.obj.Size.X, math.min(maxSize, loudness - (minLoudness[partHeight] or 0)), part.obj.Size.Z)
			part.obj.CFrame = CFrame.new(ladder.PrimaryPart.Position + Vector3.new(0, part.obj.Size.Y / 2, 0) + part.offset) * CFrame.Angles(ladder.PrimaryPart.CFrame:ToEulerAngles())
			part.obj.Transparency = 0
		else
			part.obj.Size = Vector3.new(part.obj.Size.X, 0, part.obj.Size.Z)
			part.obj.Transparency = 1
		end
	end
end)
