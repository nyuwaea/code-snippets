--[[
			Handles all the effects on the Equaladder (equalizer ladder)
]]

------------► ► ►	SERVICES	◄ ◄ ◄------------

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

------------► ► ►	VARIABLES	◄ ◄ ◄------------

local Ladder = script.Parent.Parent
local Parts = {
	normal = Ladder.Cosmetics.Parts.Normal:GetChildren(),
	charged = Ladder.Cosmetics.Parts.Charged:GetChildren()
}
local Mute = true
local SoundBank = {
	Chirp = {
		id = "rbxassetid://12571664247",
		volume = .3,
		loudnessDivisor = 30,
		BPM = 100,
		offset = 5.000
	},
	Rudeness = {
		id = "rbxassetid://12580546538",
		volume = 1.7,
		loudnessDivisor = 5
	},
	Marble_Dove = {
		id = "rbxassetid://9495783481",
		volume = .15,
		loudnessDivisor = 70,
		BPM = 107.5,
		offset = 1.920
	},
	Asimov = {
		id = "rbxassetid://4500030527",
		volume = .4,
		loudnessDivisor = 20,
		BPM = 64,
		offset = 3.920
	},
	Carousel_of_Memories = {
		id = "rbxassetid://12582077837",
		volume = .4,
		loudnessDivisor = 30,
		BPM = 32.125,
		offset = 0.100
	}
}
local Pitch = 1
local LastPulse = 0
local Song = SoundBank.Carousel_of_Memories

local ExampleSound = Instance.new("Sound", game:GetService("SoundService"))
ExampleSound.SoundId = Song.id
ExampleSound.Volume = Mute and 0 or Song.volume
ExampleSound.Looped = true
ExampleSound.Pitch = Pitch
ExampleSound:Play()

local Start = os.clock()
local MinLoudness = {
	[1] = 0,
	[2] = 4,
	[3] = 7,
	[4] = 9
}
local LoudnessDelays = {
	[0] = 0,
	[1] = 0,			-- placeholder vars
	[2] = 0
}

------------► ► ►	FUNCTIONS	◄ ◄ ◄------------

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function getEQparts(): {}
	local parts = {}

	for _, d in ipairs(Ladder.Cosmetics.Equalizers:GetDescendants()) do
		if d:IsA("Part") then
			parts[#parts + 1] = {
				obj = d,
				offset = d.Position - Ladder.PrimaryPart.Position
			}
		end
	end

	return parts
end

local function pulsate(): ()
	for _, nPart in ipairs(Parts.normal) do
		coroutine.wrap(function()
			task.wait((tonumber(nPart.Name) - 1) / 100)

			TweenService:Create(nPart, TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = .8}):Play()

			task.wait(.05)

			TweenService:Create(nPart, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 0}):Play()
		end)()
	end
end

local EQparts = getEQparts()

RunService.RenderStepped:Connect(function(delta: number): ()
	local now = os.clock()

	if Song.BPM and now - Start >= Song.offset / Pitch then
		local minTime = 1 / (delta * 3600) + .002

		if math.floor((now - Start - Song.offset / Pitch) % (60 / Song.BPM / Pitch) * 1000) / 1000 <= minTime and now - LastPulse >= minTime then
			pulsate()
			LastPulse = os.clock()
		end
	end

	coroutine.wrap(function(): ()
		local loudness = ExampleSound.PlaybackLoudness / Song.loudnessDivisor

		for i = 0, 2 do
			task.wait(i / 10)

			LoudnessDelays[i] = lerp(LoudnessDelays[i], loudness, .1)
		end
	end)()

	for _, cPart in ipairs(Parts.charged) do
		cPart.Color = Color3.new(.5, 1, .5):Lerp(Color3.new(1, .5, .5), math.clamp((LoudnessDelays[0] - 1) / 10, 0, 1))
	end

	for _, part in ipairs(EQparts) do
		local partHeight = tonumber(part.obj.Name)
		local loudness = math.floor((LoudnessDelays[(tonumber(part.obj.Parent.Name:sub(3, 3)) - 1)]) * 100 + .5) / 100

		if MinLoudness[partHeight] <= loudness then
			local maxSize = 4 - (partHeight - 1)

			part.obj.Size = Vector3.new(part.obj.Size.X, math.min(maxSize, loudness - (MinLoudness[partHeight] or 0)), part.obj.Size.Z)
			part.obj.CFrame = CFrame.new(Ladder.PrimaryPart.Position + Vector3.new(0, part.obj.Size.Y / 2, 0) + part.offset) * CFrame.Angles(Ladder.PrimaryPart.CFrame:ToEulerAngles())
			part.obj.Transparency = 0
		else
			part.obj.Size = Vector3.new(part.obj.Size.X, 0, part.obj.Size.Z)
			part.obj.Transparency = 1
		end
	end
end)
