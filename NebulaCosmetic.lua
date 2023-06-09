--[[
			Handles all the effects on the Nebula ladder
]]

------------► ► ►	SERVICES	◄ ◄ ◄------------

local RunService = game:GetService("RunService")

------------► ► ►	VARIABLES	◄ ◄ ◄------------

local Ladder = script.Parent.Parent
local Particles = Ladder.Cosmetics.Particles

Particles.Parent = Ladder

------------► ► ►	FUNCTIONS	◄ ◄ ◄------------

RunService.RenderStepped:Connect(function(): ()
	local alpha = (math.sin(tick() * 2) + 1) / 2
	local mainCF = Ladder.PrimaryPart.CFrame
	
	Ladder.Cosmetics.Highlight.OutlineColor = Color3.fromHex("ff64b1"):Lerp(Color3.fromHex("a564ff"), alpha)

	for i, particle in ipairs(Particles:GetChildren()) do
		local distance = i == 1 and 5 or -5
		local targetCF = CFrame.new(mainCF.Position + mainCF.RightVector * distance * math.sin(tick()) + mainCF.LookVector * distance * math.cos(tick()) + mainCF.UpVector * distance * .8 * math.sin(tick() / 4))

		particle.CFrame = particle.CFrame:Lerp(targetCF, .025)
	end
end)
