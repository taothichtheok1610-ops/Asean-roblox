-- BLUE LOCK: AUTO BALL TRACKER & AUTO GOAL (UPDATED MECHANICS)
if _G.BlueLock_Cleanup then pcall(_G.BlueLock_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptConnections = {}

_G.BlueLock_Cleanup = function()
	for _, conn in ipairs(ScriptConnections) do
		if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
	end
	ScriptConnections = {}
end

-- ⭐ CÀI ĐẶT MẶC ĐỊNH
local Settings = {
	AutoFlyBall = false, -- Tự bay tới chỗ quả bóng
	AutoGoal = false,    -- Tự khóa hướng vào gôn & tự click sút
	HitDistance = 4,     -- Khoảng cách áp sát bóng (studs)
}

----------------------------------------------------
-- 1. HÀM TÌM QUẢ BÓNG CHÍNH XÁC
----------------------------------------------------
local function getBall()
	-- Quét toàn bộ workspace tìm bóng dựa vào ClassName và Name
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			local name = obj.Name:lower()
			if name:find("ball") or name:find("football") or name:find("soccer") or name:find("pelota") then
				if obj:IsA("Model") then
					return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				else
					return obj
				end
			end
		end
	end
	
	-- Quét sâu hơn nếu bóng nằm trong folder đặc biệt (Folder / Match)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "SoccerBall" or obj.Name == "Football") then
			return obj
		end
	end
	return nil
end

----------------------------------------------------
-- 2. HÀM TÌM GÔN ĐỐI PHƯƠNG
----------------------------------------------------
local function getEnemyGoal()
	local goals = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name:lower():find("goal") or obj.Name:lower():find("net")) then
			table.insert(goals, obj)
		end
	end

	if #goals == 0 then return nil end

	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return goals[1] end

	-- Chọn gôn ở xa vị trí của bạn nhất (thường là gôn đối phương)
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
screenGui.Name = "BlueLock_FixUI_" .. math.random(1000, 9999)
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
menuFrame.Size = UDim2.new(0, 230, 0, 200)
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
title.Text = "nguyenk12[BLUE LOCK FIX]"
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
	btn.TextSize = 11
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

createToggle("AutoFlyBall", "⚽ Auto Bay Theo Bóng")
createToggle("AutoGoal", "🎯 Auto Aim Goal & Sút")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 4. LUỒNG XỬ LÝ BAY & SÚT BÓNG (RENDERSTEPPED)
----------------------------------------------------
local lastShot = 0

table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local ball = getBall()
	if not ball then return end

	-- 1. BAY ÁP SÁT BÓNG
	if Settings.AutoFlyBall then
		pcall(function()
			-- Dịch chuyển vị trí người chơi đến sát phía sau quả bóng
			local targetPos = ball.Position - (ball.Velocity.Unit * Settings.HitDistance)
			if ball.Velocity.Magnitude < 1 then
				targetPos = ball.Position + Vector3.new(0, 0.5, -2)
			end
			hrp.CFrame = CFrame.new(targetPos, ball.Position)
		end)
	end

	-- 2. KHÓA HƯỚNG VÀO GÔN ĐỐI PHƯƠNG & TỰ CLICK SÚT
	if Settings.AutoGoal then
		pcall(function()
			local goal = getEnemyGoal()
			if goal then
				-- Xoay nhân vật và camera về phía gôn
				local lookAtGoal = CFrame.new(hrp.Position, Vector3.new(goal.Position.X, hrp.Position.Y, goal.Position.Z))
				hrp.CFrame = lookAtGoal
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, goal.Position)

				-- Nếu khoảng cách từ người tới bóng dưới 10 studs -> Tự bấm Click/Chân sút
				local distToBall = (hrp.Position - ball.Position).Magnitude
				if distToBall < 10 and (tick() - lastShot > 0.15) then
					lastShot = tick()
					-- Giả lập bấm chuột trái / Tool Sút
					local tool = char:FindFirstChildOfClass("Tool")
					if tool then
						tool:Activate()
					else
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
						task.wait(0.02)
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
					end
				end
			end
		end)
	end
end))

print("✅ SCRIPT BLUE LOCK FIX THÀNH CÔNG!")
