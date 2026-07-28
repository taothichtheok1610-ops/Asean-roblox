-- DELTA X: BLUE LOCK CONTROLL BALL & AUTO PICK BALL
-- Version: Instant Touch & Auto Collect

if _G.BlueLock_Cleanup then pcall(_G.BlueLock_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Connections = {}
local ControllingBall = false
local CurrentBall = nil

_G.BlueLock_Cleanup = function()
	for _, conn in ipairs(Connections) do
		if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
	end
	Connections = {}
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end

-- CẤU HÌNH TÍNH NĂNG
local Config = {
	ControlBall = false,
	AutoPickBall = false, -- Tự động hút/nhặt bóng
	BallSpeed = 100,
}

----------------------------------------------------
-- 1. HÀM TÌM QUẢ BÓNG (BALL FINDER)
----------------------------------------------------
local function GetBall()
	if CurrentBall and CurrentBall.Parent and CurrentBall:IsA("BasePart") then
		return CurrentBall
	end
	
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "Football" or obj.Name == "SoccerBall" or obj.Name:find("Ball")) then
			if not obj:IsDescendantOf(LocalPlayer.Character) then
				CurrentBall = obj
				return obj
			end
		end
	end
	return nil
end

----------------------------------------------------
-- 2. DỊCH CHUYỂN & AUTO NHẶT BÓNG (INSTANT PICK)
----------------------------------------------------
local function TeleportToBall()
	local ball = GetBall()
	local char = LocalPlayer.Character
	if ball and char and char:FindFirstChild("HumanoidRootPart") then
		-- Dịch chuyển đè thẳng vào tọa độ quả bóng để nhặt ngay lập tức
		char.HumanoidRootPart.CFrame = ball.CFrame
	end
end

----------------------------------------------------
-- 3. LOOP XỬ LÝ CONTROL BALL & AUTO PICK
----------------------------------------------------
local function StopBallControl()
	ControllingBall = false
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
	local ball = GetBall()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	-- Logic Auto Pick Ball: Liên tục hút lấy bóng nếu ở xa
	if Config.AutoPickBall and ball and hrp then
		local dist = (hrp.Position - ball.Position).Magnitude
		if dist > 3 then
			hrp.CFrame = ball.CFrame
		end
	end

	-- Logic Control Ball
	if Config.ControlBall and ball then
		if hrp then
			local dist = (hrp.Position - ball.Position).Magnitude
			if dist < 12 or ball.AssemblyLinearVelocity.Magnitude > 5 then
				ControllingBall = true
			end
		end

		if ControllingBall then
			Camera.CameraSubject = ball
			local lookDirection = Camera.CFrame.LookVector
			ball.AssemblyLinearVelocity = lookDirection * Config.BallSpeed

			if ball.AssemblyLinearVelocity.Magnitude < 2 and (hrp and (hrp.Position - ball.Position).Magnitude > 20) then
				StopBallControl()
			end
		end
	else
		if ControllingBall then StopBallControl() end
	end
end))

----------------------------------------------------
-- 4. GIAO DIỆN MENU (GUI)
----------------------------------------------------
local function wipeOldUI(folder)
	if not folder then return end
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:find("BlueLock_UI") then child:Destroy() end
	end
end

wipeOldUI(LocalPlayer:FindFirstChild("PlayerGui"))
wipeOldUI(CoreGui)
if gethui then wipeOldUI(gethui()) end

local parentContainer = LocalPlayer:WaitForChild("PlayerGui")
if gethui then parentContainer = gethui() elseif CoreGui:FindFirstChild("RobloxGui") then parentContainer = CoreGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlueLock_UI_" .. math.random(1000, 9999)
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentContainer

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 230, 0, 300)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(59, 130, 246)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "BLUE LOCK: BALL SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 38)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

-- Toggle Control Ball
local btnControl = Instance.new("TextButton")
btnControl.Size = UDim2.new(1, 0, 0, 32)
btnControl.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
btnControl.Text = "Control Ball: OFF"
btnControl.TextColor3 = Color3.fromRGB(255, 255, 255)
btnControl.Font = Enum.Font.SourceSansBold
btnControl.TextSize = 12
btnControl.Parent = container

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 6)
corner1.Parent = btnControl

table.insert(Connections, btnControl.MouseButton1Click:Connect(function()
	Config.ControlBall = not Config.ControlBall
	if Config.ControlBall then
		btnControl.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		btnControl.Text = "Control Ball: ON"
	else
		btnControl.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
		btnControl.Text = "Control Ball: OFF"
		StopBallControl()
	end
end))

-- Toggle Auto Pick Ball
local btnAutoPick = Instance.new("TextButton")
btnAutoPick.Size = UDim2.new(1, 0, 0, 32)
btnAutoPick.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
btnAutoPick.Text = "Auto Pick Ball: OFF"
btnAutoPick.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoPick.Font = Enum.Font.SourceSansBold
btnAutoPick.TextSize = 12
btnAutoPick.Parent = container

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 6)
corner2.Parent = btnAutoPick

table.insert(Connections, btnAutoPick.MouseButton1Click:Connect(function()
	Config.AutoPickBall = not Config.AutoPickBall
	if Config.AutoPickBall then
		btnAutoPick.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		btnAutoPick.Text = "Auto Pick Ball: ON"
	else
		btnAutoPick.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
		btnAutoPick.Text = "Auto Pick Ball: OFF"
	end
end))

-- Teleport Ball Button (Nút ấn thủ công)
local btnTeleport = Instance.new("TextButton")
btnTeleport.Size = UDim2.new(1, 0, 0, 32)
btnTeleport.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
btnTeleport.Text = "Teleport To Ball (1-Click)"
btnTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTeleport.Font = Enum.Font.SourceSansBold
btnTeleport.TextSize = 12
btnTeleport.Parent = container

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 6)
corner3.Parent = btnTeleport

table.insert(Connections, btnTeleport.MouseButton1Click:Connect(function()
	TeleportToBall()
end))

-- Chỉnh Tốc độ Bóng (Speed Adjuster)
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 50)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = container

local lblSpeed = Instance.new("TextLabel")
lblSpeed.Size = UDim2.new(1, 0, 0, 20)
lblSpeed.BackgroundTransparency = 1
lblSpeed.Text = "Ball Speed: " .. Config.BallSpeed
lblSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
lblSpeed.Font = Enum.Font.SourceSansBold
lblSpeed.TextSize = 12
lblSpeed.Parent = speedFrame

local btnMinusSpeed = Instance.new("TextButton")
btnMinusSpeed.Size = UDim2.new(0.48, 0, 0, 25)
btnMinusSpeed.Position = UDim2.new(0, 0, 0, 22)
btnMinusSpeed.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
btnMinusSpeed.Text = "-20 Speed"
btnMinusSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinusSpeed.Font = Enum.Font.SourceSansBold
btnMinusSpeed.Parent = speedFrame

local btnPlusSpeed = Instance.new("TextButton")
btnPlusSpeed.Size = UDim2.new(0.48, 0, 0, 25)
btnPlusSpeed.Position = UDim2.new(0.52, 0, 0, 22)
btnPlusSpeed.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
btnPlusSpeed.Text = "+20 Speed"
btnPlusSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPlusSpeed.Font = Enum.Font.SourceSansBold
btnPlusSpeed.Parent = speedFrame

btnMinusSpeed.MouseButton1Click:Connect(function()
	Config.BallSpeed = math.max(20, Config.BallSpeed - 20)
	lblSpeed.Text = "Ball Speed: " .. Config.BallSpeed
end)

btnPlusSpeed.MouseButton1Click:Connect(function()
	Config.BallSpeed = math.min(300, Config.BallSpeed + 20)
	lblSpeed.Text = "Ball Speed: " .. Config.BallSpeed
end)

-- Drag Menu System
local dragging, dragStart, startPos
table.insert(Connections, mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end))

table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))
