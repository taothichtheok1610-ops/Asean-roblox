-- BLUE LOCK: AUTO GOAL & TP BALL MENU (BLACK THEME)
if _G.BlueLock_Cleanup then pcall(_G.BlueLock_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScriptConnections = {}

_G.BlueLock_Cleanup = function()
	for _, conn in ipairs(ScriptConnections) do
		if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
	end
	ScriptConnections = {}
end

-- ⭐ CÀI ĐẶT MẶC ĐỊNH
local Settings = {
	TPBall = false,
	AutoGoal = false,
	TPDistance = 3, -- Khoảng cách bóng hút về người (studs)
}

----------------------------------------------------
-- 1. HÀM TÌM QUẢ BÓNG TRONG WORKSPACE
----------------------------------------------------
local function getBall()
	-- Tìm các tên phổ biến của bóng trong game Blue Lock
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "Football" or obj.Name:find("Soccer")) then
			return obj
		end
	end
	return nil
end

----------------------------------------------------
-- 2. HÀM TÌM KHUNG THÀNH ĐỐI PHƯƠNG
----------------------------------------------------
local function getEnemyGoal()
	-- Tìm goal/net thuộc về team địch hoặc xa người chơi nhất
	local goals = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name:find("Goal") or obj.Name:find("Net") or obj.Name:find("GoalPart")) then
			table.insert(goals, obj)
		end
	end

	if #goals == 0 then return nil end

	-- Tìm khung thành xa vị trí hiện tại của player nhất (thường là khung thành đối phương)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return goals[1] end

	local farthestGoal = goals[1]
	local maxDist = 0

	for _, goal in ipairs(goals) do
		local dist = (goal.Position - char.HumanoidRootPart.Position).Magnitude
		if dist > maxDist then
			maxDist = dist
			farthestGoal = goal
		end
	end

	return farthestGoal
end

----------------------------------------------------
-- 3. GIAO DIỆN MENU MÀU ĐEN (BLACK THEME)
----------------------------------------------------
local parentContainer = LocalPlayer:WaitForChild("PlayerGui")
if gethui then 
	parentContainer = gethui() 
elseif CoreGui:FindFirstChild("RobloxGui") then 
	parentContainer = CoreGui:FindFirstChild("RobloxGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlueLock_UI_" .. math.random(1000, 9999)
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentContainer

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
toggleBtn.Text = "MENU"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.Active = true
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(1, 0) btnCorner.Parent = toggleBtn
local toggleStroke = Instance.new("UIStroke") toggleStroke.Color = Color3.fromRGB(50, 50, 50) toggleStroke.Thickness = 1.5 toggleStroke.Parent = toggleBtn

-- Khung Menu Chính
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 220, 0, 210)
menuFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
menuFrame.BackgroundTransparency = 0.05
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner") menuCorner.CornerRadius = UDim.new(0, 10) menuCorner.Parent = menuFrame
local menuStroke = Instance.new("UIStroke") menuStroke.Color = Color3.fromRGB(40, 40, 40) menuStroke.Thickness = 1.5 menuStroke.Parent = menuFrame

-- Dragging logic
local dragging, dragStart, startPos
table.insert(ScriptConnections, menuFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = menuFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end))

table.insert(ScriptConnections, UserInputService.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "nguyenk12[BLUE LOCK]"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = menuFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -35)
container.Position = UDim2.new(0, 5, 0, 30)
container.BackgroundTransparency = 1
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

local function createToggle(name, text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 32)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = container

	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 5) corner.Parent = btn
	local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(45, 45, 45) stroke.Thickness = 1 stroke.Parent = btn

	local function update()
		if Settings[name] then
			btn.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
			btn.Text = text .. ": ✓ ON"
			stroke.Color = Color3.fromRGB(0, 180, 80)
		else
			btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			btn.Text = text .. ": ✗ OFF"
			stroke.Color = Color3.fromRGB(45, 45, 45)
		end
		btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	end
	update()

	table.insert(ScriptConnections, btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end))
end

createToggle("TPBall", "⚽ TP Ball To Me")
createToggle("AutoGoal", "🎯 Auto Goal (Sút Vào)")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 4. VÒNG LẶP XỬ LÝ (RENDERSTEPPED)
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local ball = getBall()
	if not ball then return end

	-- ⚽ FEATURE 1: TELEPORT BALL TO PLAYER
	if Settings.TPBall then
		pcall(function()
			-- Giữ bóng ở phía trước chân người chơi
			ball.CFrame = hrp.CFrame * CFrame.new(0, -1, -Settings.TPDistance)
			ball.Velocity = Vector3.new(0, 0, 0)
			ball.RotVelocity = Vector3.new(0, 0, 0)
		end)
	end

	-- 🎯 FEATURE 2: AUTO GOAL (ĐƯA BÓNG VÀO KHUNG THÀNH ĐỊCH)
	if Settings.AutoGoal then
		pcall(function()
			local goal = getEnemyGoal()
			if goal then
				-- Đưa thẳng bóng vào trong khung thành đối phương
				ball.CFrame = goal.CFrame
				ball.Velocity = goal.CFrame.LookVector * -50 -- Đẩy mạnh bóng vào lưới
			end
		end)
	end
end))

print("✅ ĐÃ TẢI THÀNH CÔNG SCRIPT BLUE LOCK (AUTO GOAL & TP BALL)!")
