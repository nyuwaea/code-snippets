--[[
			This module sets up all the cutscene info
			Cutscenes can be played via the client as follows:
			
				local Cutscenes = require(*PATH*.CutscenesHandler).Setup(plr, cam)

				Cutscenes:Play("Example", false, true)
]]

------------► ► ►	SERVICES	◄ ◄ ◄------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

------------► ► ►	VARIABLES	◄ ◄ ◄------------

local Splines = require(ReplicatedStorage.Modules.Splines)
local CutsceneCoordinates = workspace.CutsceneCoordinates

------------► ► ►	 MODULE		◄ ◄ ◄------------

local Cutscenes = {}
Cutscenes.__index = Cutscenes

function Cutscenes.Init(plr: Player, cam: Camera): {}
	local self = setmetatable({}, Cutscenes)

	-- Setup basic variables
	self._plr = plr
	self._cam = cam
	self._cutscenes = {}
	self._playing = nil
	self._connection = nil

	-- Create cutscenes (name, duration)
	self:Add("Example", 20)
	self:Add("Example2", 30)

	-- Setup VFX UI stuff
	self._VFXUI = Instance.new("ScreenGui", plr.PlayerGui)
	self._VFXUI.Name = "CutsceneUI"
	self._VFXUI.ResetOnSpawn = false
	self._VFXUI.IgnoreGuiInset = true
	self._VFXBars = {}

	for i = 0, 1 do
		self._VFXBars[i + 1] = Instance.new("Frame", self._VFXUI)
		self._VFXBars[i + 1].AnchorPoint = Vector2.new(.5, i)
		self._VFXBars[i + 1].BackgroundColor3 = Color3.new(0, 0, 0)
		self._VFXBars[i + 1].BorderSizePixel = 0
		self._VFXBars[i + 1].Position = UDim2.fromScale(.5, 1 - i)
		self._VFXBars[i + 1].Size = UDim2.fromScale(1, 1)
	end

	return self
end

function Cutscenes:Add(name: string, duration: number, splineAlpha: number?): ()
	self._cutscenes[name] = {
		spline = self:GetSpline(CutsceneCoordinates[name], splineAlpha),
		duration = duration
	}
end

function Cutscenes:Play(cutsceneName: string, setCamTypeBack: boolean?, disableCoreGui: boolean?): ()
	local thisCutscene = self._cutscenes[cutsceneName]

	if thisCutscene then
		return coroutine.wrap(function()
			local originalCamType = self._cam.CameraType
			disableCoreGui = disableCoreGui or false

			if self._playing and self._playing ~= cutsceneName then
				self._connection:Disconnect()
			end

			self._playing = cutsceneName
			self._cam.CameraType = Enum.CameraType.Scriptable

			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not disableCoreGui)

			local index = 1
			local lastUpdate = 0
			local timeBetweenUpdates = thisCutscene.duration / (#thisCutscene.spline.positions)
			local timeSinceLastUpdate = 0
			local thisVFX = {
				FoV = 70;
				Blur = 0;
				Exposure = 3;
				CinematicBarsYOffset = 0;
			}
			local thisPos = Vector3.new()
			local thisAngle = Vector3.new()

			self._connection = RunService.RenderStepped:Connect(function(delta)
				local now = os.clock()
				local alpha = timeSinceLastUpdate / timeBetweenUpdates

				if index <= #thisCutscene.spline.positions then
					thisPos = thisCutscene.spline.positions[index]
					thisAngle = thisCutscene.spline.angles[index]
					thisVFX.FoV = thisCutscene.spline.vfxData.FoV[index]
					thisVFX.Blur = thisCutscene.spline.vfxData.Blur[index]
					thisVFX.Exposure = thisCutscene.spline.vfxData.Exposure[index]
					thisVFX.CinematicBarsYOffset = thisCutscene.spline.vfxData.CinematicBarsYOffset[index]

					if now - lastUpdate >= timeBetweenUpdates then
						index += 1
						timeSinceLastUpdate = 0
						lastUpdate = now - lastUpdate - timeBetweenUpdates > 1 and os.clock() or os.clock() - (now - lastUpdate - timeBetweenUpdates)
					end
				end

				timeSinceLastUpdate += delta

				local targetVFX = {
					FoV = Cutscenes.Lerp(thisCutscene.spline.vfxData.FoV[index - 1], thisVFX.FoV, alpha);
					Blur = Cutscenes.Lerp(thisCutscene.spline.vfxData.Blur[index - 1], thisVFX.Blur, alpha);
					Exposure = Cutscenes.Lerp(thisCutscene.spline.vfxData.Exposure[index - 1], thisVFX.Exposure, alpha);
					CinematicBarsYOffset = Cutscenes.Lerp(thisCutscene.spline.vfxData.CinematicBarsYOffset[index - 1], thisVFX.CinematicBarsYOffset, alpha) - 1;
				}
				local targetPos = thisCutscene.spline.positions[index - 1]:Lerp(thisPos, alpha)
				local targetAngle = thisCutscene.spline.angles[index - 1]:Lerp(thisAngle, alpha)
				local translatedAngle = CFrame.fromOrientation(math.rad(targetAngle.X), math.rad(targetAngle.Y), math.rad(targetAngle.Z))

				self._cam.FieldOfView = targetVFX.FoV
				game.Lighting.ExposureCompensation = targetVFX.Exposure
				game.Lighting.Blur.Size = targetVFX.Blur

				for i = 0, 1 do
					self._VFXBars[i + 1].Position = UDim2.new(.5, 0, 1 - i, i == 0 and -targetVFX.CinematicBarsYOffset or targetVFX.CinematicBarsYOffset)
				end

				self._cam.CFrame = CFrame.new(targetPos) * translatedAngle
			end)

			repeat task.wait() until index / #thisCutscene.spline.positions > 1

			if self._playing == cutsceneName then
				self._playing = nil
				self._connection:Disconnect()

				if setCamTypeBack then
					self._cam.CameraType = originalCamType
				end

				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
			end
		end)()
	end
end

function Cutscenes:GetSpline(cutsceneFolder: Folder, splineAlpha: number?): {}
	local points = {
		positions = {},
		angles = {},
		vfxData = {
			FoV = {},
			Blur = {},
			Exposure = {},
			CinematicBarsYOffset = {}
		}
	}
	local parts = cutsceneFolder:GetChildren()

	for i = 1, #parts do
		local part = cutsceneFolder[tostring(i)]
		local orientationVector = part.Orientation

		if orientationVector.Y < 0 then
			orientationVector = Vector3.new(orientationVector.X, 360 - math.abs(orientationVector.Y), orientationVector.Z)
		end

		for attribute, value in pairs(part:GetAttributes()) do
			points.vfxData[attribute][i] = value
		end

		points.positions[i] = part.Position
		points.angles[i] = orientationVector

		Cutscenes.ClearPartDebug(part)
	end

	return {
		positions = Splines.Catmull_RomSpline3(points.positions, splineAlpha),
		angles = Splines.Catmull_RomSpline3(points.angles, splineAlpha),
		vfxData = {
			FoV = Splines.AkimaSpline(points.vfxData.FoV),
			Blur = Splines.AkimaSpline(points.vfxData.Blur),
			Exposure = Splines.AkimaSpline(points.vfxData.Exposure),
			CinematicBarsYOffset = Splines.AkimaSpline(points.vfxData.CinematicBarsYOffset)
		}
	}
end

function Cutscenes.ClearPartDebug(part: Part): ()
	part.Transparency = 1
	part.Decal.Transparency = 1
end

function Cutscenes.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

return Cutscenes
