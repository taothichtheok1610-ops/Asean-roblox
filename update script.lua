-- DELTA X: DRAWING ESP (REAL SKELETON + ACCURATE TOP LINE + AIMBOT)

if _G.Delta_Cleanup then pcall(_G.Delta_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptConnections = {}
local DrawObjects = {}

_G.Delta_Cleanup = function()
	for _, conn in ipairs(ScriptConnections) do
		if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
	end
	ScriptConnections = {}

	for _, obj in pairs(DrawObjects) do
		if type(obj) == "table" then
			for _, line in pairs(obj) do if line.Remove then line:Remove() end end
		elseif obj and obj.Remove then
			obj:Remove()
		end
	end
	DrawObjects = {}
end

local Settings = {
	ESP = true,
	Health = true,
	Lines = true,
	Skeleton = true,
	Aimbot = true,
	WallCheck = true,
	FOVSize = 120,
	Smoothness = 0.25,
}

----------------------------------------------------
-- 1. CLEANUP UI CŨ & TẠO MENU GUI
----------------------------------------------------
local function wipeOldUI(folder)
	if not folder then return end
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:find("Delta_UI") then child:Destroy() end
	end
end

wipeOldUI(LocalPlayer:FindFirstChild("PlayerGui"))
wipeOldUI(CoreGui)
if gethui then wipeOldUI(gethui()) end

local parentContainer = LocalPlayer:WaitForChild("PlayerGui")
if gethui then parentContainer = gethui() elseif CoreGui:FindFirstChild("RobloxGui") then parentContainer = CoreGui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Delta_UI_" .. math.random(1000, 9999)
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentContainer

-- FOV Circle
local fovFrame = Instance.new("Frame")
fovFrame.Name = "FOVCircle"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = Settings.Aimbot
fovFrame.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovFrame

-- Menu GUI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "MENU"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 220, 0, 350)
menuFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Dragging Menu
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
title.Text = "DELTA ESP SKELETON FIX"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = menuFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 30)
container.BackgroundTransparency = 1
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

local function createToggle(name, text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 26)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn

	local function update()
		if Settings[name] then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			btn.Text = text .. ": ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
			btn.Text = text .. ": OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	update()

	table.insert(ScriptConnections, btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end))
end

-- Tăng/Giảm FOV
local fovControl = Instance.new("Frame")
fovControl.Size = UDim2.new(1, 0, 0, 26)
fovControl.BackgroundTransparency = 1
fovControl.Parent = container

local btnMinus = Instance.new("TextButton")
btnMinus.Size = UDim2.new(0.48, 0, 1, 0)
btnMinus.Text = "- FOV"
btnMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinus.Font = Enum.Font.SourceSansBold
btnMinus.Parent = fovControl

local btnPlus = Instance.new("TextButton")
btnPlus.Size = UDim2.new(0.48, 0, 1, 0)
btnPlus.Position = UDim2.new(0.52, 0, 0, 0)
btnPlus.Text = "+ FOV"
btnPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPlus.Font = Enum.Font.SourceSansBold
btnPlus.Parent = fovControl

btnMinus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.max(40, Settings.FOVSize - 20)
	fovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
end)

btnPlus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.min(400, Settings.FOVSize + 20)
	fovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
end)

-- Smoothness Aim
local smoothBtn = Instance.new("TextButton")
smoothBtn.Size = UDim2.new(1, 0, 0, 26)
smoothBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
smoothBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothBtn.Font = Enum.Font.SourceSansBold
smoothBtn.TextSize = 11
smoothBtn.Text = "Độ mượt Aim: VỪA"
smoothBtn.Parent = container

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 5)
smoothCorner.Parent = smoothBtn

smoothBtn.MouseButton1Click:Connect(function()
	if Settings.Smoothness == 0.25 then
		Settings.Smoothness = 0.08
		smoothBtn.Text = "Độ mượt Aim: RẤT MƯỢT"
	elseif Settings.Smoothness == 0.08 then
		Settings.Smoothness = 1.0
		smoothBtn.Text = "Độ mượt Aim: KHÓA CHẶT"
	else
		Settings.Smoothness = 0.25
		smoothBtn.Text = "Độ mượt Aim: VỪA"
	end
end)

createToggle("ESP", "Nhìn Xuyên Tường (Box)")
createToggle("Health", "Hiện Tên & % Máu")
createToggle("Lines", "Line Đỉnh Nối Đầu")
createToggle("Skeleton", "Hiện Xương Thật (Skeleton)")
createToggle("Aimbot", "Bật Aimbot FOV")
createToggle("WallCheck", "Wall Check (Chống tường)")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 2. AIMBOT LOGIC
----------------------------------------------------
local function isVisible(targetPart)
	if not Settings.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local destination = targetPart.Position
	local direction = (destination - origin)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

local function getClosestPlayerInFOV()
	local closestPlayer = nil
	local shortestDistance = Settings.FOVSize
	local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local head = player.Character:FindFirstChild("Head")
			local humanoid = player.Character:FindFirstChild("Humanoid")

			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
					if distance < shortestDistance and isVisible(head) then
						shortestDistance = distance
						closestPlayer = head
					end
				end
			end
		end
	end
	return closestPlayer
end

----------------------------------------------------
-- 3. DRAWING ESP LOGIC (SKELETON & LINES)
----------------------------------------------------
local R15Joints = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"}
}

local R6Joints = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"}
}

local function createLine()
	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = Color3.fromRGB(255, 255, 255)
	line.Transparency = 1
	line.Visible = false
	return line
end

local function getPlayerDrawings(player)
	if not DrawObjects[player] then
		DrawObjects[player] = {
			TopLine = Drawing.new("Line"),
			Skeleton = {}
		}
		DrawObjects[player].TopLine.Thickness = 1.5
		DrawObjects[player].TopLine.Color = Color3.fromRGB(255, 255, 0)
		DrawObjects[player].TopLine.Transparency = 1

		for i = 1, 15 do
			table.insert(DrawObjects[player].Skeleton, createLine())
		end
	end
	return DrawObjects[player]
end

local function removePlayerDrawings(player)
	if DrawObjects[player] then
		if DrawObjects[player].TopLine then DrawObjects[player].TopLine:Remove() end
		for _, line in ipairs(DrawObjects[player].Skeleton) do
			if line then line:Remove() end
		end
		DrawObjects[player] = nil
	end
end

Players.PlayerRemoving:Connect(removePlayerDrawings)

----------------------------------------------------
-- 4. RENDER LOOP
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot

	-- Aimbot
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
		end
	end

	-- Drawing Render (Lines & Skeleton)
	local topScreenPos = Vector2.new(Camera.ViewportSize.X / 2, 0)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local objs = getPlayerDrawings(player)
			local char = player.Character
			local humanoid = char and char:FindFirstChild("Humanoid")
			local head = char and char:FindFirstChild("Head")

			if char and humanoid and humanoid.Health > 0 and head then
				local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)

				-- 1. Line từ đỉnh màn hình nối thẳng ĐẦU
				if Settings.Lines and onScreen then
					objs.TopLine.From = topScreenPos
					objs.TopLine.To = Vector2.new(headPos.X, headPos.Y)
					objs.TopLine.Visible = true
				else
					objs.TopLine.Visible = false
				end

				-- 2. Skeleton Xương Thật
				if Settings.Skeleton and onScreen then
					local isR15 = char:FindFirstChild("UpperTorso") ~= nil
					local joints = isR15 and R15Joints or R6Joints

					for i, joint in ipairs(joints) do
						local partA = char:FindFirstChild(joint[1])
						local partB = char:FindFirstChild(joint[2])
						local line = objs.Skeleton[i]

						if partA and partB and line then
							local posA, visA = Camera:WorldToViewportPoint(partA.Position)
							local posB, visB = Camera:WorldToViewportPoint(partB.Position)

							if visA and visB then
								line.From = Vector2.new(posA.X, posA.Y)
								line.To = Vector2.new(posB.X, posB.Y)
								line.Visible = true
							else
								line.Visible = false
							end
						elseif line then
							line.Visible = false
						end
					end

					-- An cac duong line du
					for i = #joints + 1, #objs.Skeleton do
						objs.Skeleton[i].Visible = false
					end
				else
					for _, line in ipairs(objs.Skeleton) do line.Visible = false end
				end
			else
				objs.TopLine.Visible = false
				for _, line in ipairs(objs.Skeleton) do line.Visible = false end
			end
		end
	end
end))

----------------------------------------------------
-- 5. BOX & HEALTH ESP (3D Handle)
----------------------------------------------------
local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

		-- Box ESP
		local box = hrp:FindFirstChild("ESP_Box3D") or Instance.new("BoxHandleAdornment")
		box.Name = "ESP_Box3D"
		box.Adornee = hrp
		box.Size = Vector3.new(4, 6, 4)
		box.Color3 = Color3.fromRGB(255, 0, 0)
		box.Transparency = 0.5
		box.AlwaysOnTop = true
		box.ZIndex = 10
		box.Visible = Settings.ESP
		box.Parent = hrp

		-- Health UI
		local billboard = hrp:FindFirstChild("ESP_HealthUI") or Instance.new("BillboardGui")
		billboard.Name = "ESP_HealthUI"
		billboard.Adornee = hrp
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled = Settings.Health

		local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(0, 255, 0)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 14
		label.Parent = billboard
		billboard.Parent = hrp

		local function updateHP()
			if humanoid and humanoid.Health > 0 then
				local hp = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
				label.Text = string.format("%s\n[%d%% HP]", player.DisplayName, math.max(0, hp))
			else
				label.Text = player.DisplayName .. "\n[DEAD]"
			end
		end

		table.insert(ScriptConnections, humanoid.HealthChanged:Connect(updateHP))
		updateHP()
	end

	if player.Character then task.spawn(characterAdded, player.Character) end
	table.insert(ScriptConnections, player.CharacterAdded:Connect(characterAdded))
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
table.insert(ScriptConnections, Players.PlayerAdded:Connect(applyESP))
