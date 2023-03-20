--[[
			**Really** not proud of this one
			Learning Roact & Rodux is the next thing I'd like to do
]]

local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local defaultTweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Quad)

local GUI = workspace["3D_GUI"]
local MainMenu = GUI.MainMenu.HolderPart.SurfaceGui.Holder

local currentMenu = MainMenu
local currentButtons
local currentButtonIndex
local selecting = false

local controls = {
	Return = {};
	Up = {};
	Down = {};
}

function GetMenuButtons(menu : Folder)
	local btns = {}

	for _, c in ipairs(menu:GetChildren()) do
		if c:IsA("Frame") then
			btns[c.SelectionOrder] = c
		end
	end

	return btns
end

function SelectMenu(mode : string)
	local btn = currentButtons[currentButtonIndex]
	local isPressed = mode == "press"
	
	selecting = isPressed
	
	if btn then
		if mode == "release" then
			print(btn.Name)
			if btn.Name == "Quit" then
				plr:Kick("cya")
			end
		end

		btn.UIGradient.Transparency = NumberSequence.new(isPressed and 1 or .4)
		btn.UIStroke.Color = Color3.new(1, 1, 1)
		btn.TextLabel.TextColor3 = isPressed and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
		btn.TextButton.UIGradient.Transparency = NumberSequence.new(isPressed and 0 or 1)
		btn.TextButton.UIGradient.Color = ColorSequence.new(isPressed and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
	end
end

function SelectButton(mode : string, index : number)
	if mode == "increment" then
		currentButtonIndex = currentButtonIndex or #currentButtons
		currentButtonIndex += index

		if currentButtonIndex > #currentButtons then
			currentButtonIndex = 1
		elseif currentButtonIndex < 1 then
			currentButtonIndex = #currentButtons
		end
	elseif mode == "direct" then
		currentButtonIndex = index
	end
	
	for i, btn in ipairs(currentButtons) do
		local isSelected = currentButtonIndex == i
		
		btn.UIGradient.Transparency = NumberSequence.new(isSelected and .4 or 1)
		btn.UIStroke.Color = isSelected and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
		btn.TextLabel.TextColor3 = Color3.new(1, 1, 1)
		btn.TextButton.UIGradient.Transparency = NumberSequence.new(isSelected and 1 or .4)
		btn.TextButton.UIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0))
		
		if selecting then
			SelectMenu("press")
		end
	end
end

function SetupButton(btn : Frame, animate : boolean, func)
	local textBtn = btn:FindFirstChildWhichIsA("TextButton", true)

	if animate then
		coroutine.wrap(function()
			while task.wait() do
				local alpha = ((tick() % 2 / 2) - .5) * 2

				btn.UIGradient.Offset = Vector2.new(alpha, 0)
			end
		end)()
	end

	textBtn.MouseEnter:Connect(function()
		SelectButton("direct", btn.SelectionOrder)
	end)
	textBtn.MouseLeave:Connect(function()
		SelectButton("direct", 0)
	end)
	textBtn.MouseButton1Click:Connect(func)
	textBtn.MouseButton1Down:Connect(function()
		SelectMenu("press")
	end)
end

function Init()
	repeat task.wait() cam.CameraType = Enum.CameraType.Scriptable until cam.CameraType == Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(Vector3.new(0, 15, 0), Vector3.new(0, 15, 1))
	
	currentButtons = GetMenuButtons(currentMenu)
	controls.Return.Press = function()
		SelectMenu("press")
	end
	controls.Return.Release = function()
		SelectMenu("release")
	end
	controls.Up.Press = function()
		SelectButton("increment", -1)
	end
	controls.Down.Press = function()
		SelectButton("increment", 1)
	end
	
	for _, btn in ipairs(MainMenu:GetChildren()) do
		if btn:IsA("Frame") then
			SetupButton(btn, true, function()
				SelectMenu("release")
			end)
		end
	end
	
	UserInputService.InputBegan:Connect(function(input)
		if controls[input.KeyCode.Name] and controls[input.KeyCode.Name].Press then
			controls[input.KeyCode.Name].Press()
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if controls[input.KeyCode.Name] and controls[input.KeyCode.Name].Release then
			controls[input.KeyCode.Name].Release()
		end
	end)
end

Init()
