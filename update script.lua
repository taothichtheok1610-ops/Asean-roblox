-- DELTA X ULTIMATE: ESP (BOX, HEALTH, LINE, SKELETON) + AIMBOT FOV

if _G.Delta_Cleanup then pcall(_G.Delta_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptConnections = {}
_G.Delta_Cleanup = function()
	for _, conn in ipairs(ScriptConnections) do
		if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
	end
	ScriptConnections = {}
end

local Settings = {
	ESP = true,
	Health = true,
	Lines = true,
	Skeleton = true,
	Aimbot = true,
	WallCheck = true,
	FOVSize = 120,
}

----------------------------------------------------
-- 1. DỌN SẠCH UI CŨ
----------------------------------------------------
local function wipeOldUI(folder)
	if not folder then return end
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:find("Delta_UI") or child.Name:find("Delta_ESP") then
			child:Destroy()
		end
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

----------------------------------------------------
-- 2. FOV CIRCLE & ESP LINES CONTAINER
----------------------------------------------------
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

local linesFolder = Instance.new("Folder")
linesFolder.Name = "ESPLines"
linesFolder.Parent = screenGui

----------------------------------------------------
-- 3. GIAO DIỆN MENU BẢN MỚI
----------------------------------------------------
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
menuFrame.Size = UDim2.new(0, 220, 0, 320)
menuFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Drag Menu
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
title.Text = "DELTA ESP & AIMBOT FULL"
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

local function createToggle(name, text, callback)
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
		callback(Settings[name])
	end))
end

-- Tăng/Giảm FOV
local fovControl = Instance.new("Frame")
fovControl.Size = UDim2.new(1, 0, 0, 28)
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

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 4. LOGIC DRAWING LINES (BẰNG FRAME DÀY 2PX)
----------------------------------------------------
local function updateLine(lineFrame, p1, p2)
	local distance = (p2 - p1).Magnitude
	local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
	
	lineFrame.Size = UDim2.new(0, distance, 0, 2)
	lineFrame.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
	lineFrame.Rotation = angle
	lineFrame.Visible = true
end

----------------------------------------------------
-- 5. LOGIC AIMBOT & WALL CHECK
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
-- 6. RENDER LOOP (LINE + SKELETON + AIMBOT)
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot

	-- Aimbot Lock
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
		end
	end

	-- Ẩn tất cả Line cũ để vẽ lại
	for _, l in ipairs(linesFolder:GetChildren()) do
		l.Visible = false
	end

	local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChild("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

				-- 1. ESP Line
				if Settings.Lines and onScreen then
					local line = linesFolder:FindFirstChild("Line_" .. player.Name) or Instance.new("Frame")
					line.Name = "Line_" .. player.Name
					line.AnchorPoint = Vector2.new(0.5, 0.5)
					line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
					line.BorderSizePixel = 0
					line.Parent = linesFolder

					updateLine(line, screenBottom, Vector2.new(hrpPos.X, hrpPos.Y))
				end

				-- 2. ESP Skeleton (Vẽ bộ xương)
				if Settings.Skeleton and onScreen then
					local joints = {
						{"Head", "UpperTorso"},
						{"UpperTorso", "LowerTorso"},
						{"UpperTorso", "LeftUpperArm"},
						{"LeftUpperArm", "LeftLowerArm"},
						{"UpperTorso", "RightUpperArm"},
						{"RightUpperArm", "RightLowerArm"},
						{"LowerTorso", "LeftUpperLeg"},
						{"LeftUpperLeg", "LeftLowerLeg"},
						{"LowerTorso", "RightUpperLeg"},
						{"RightUpperLeg", "RightLowerLeg"},
						-- Dự phòng cho R6
						{"Head", "Torso"},
						{"Torso", "Left Arm"},
						{"Torso", "Right Arm"},
						{"Torso", "Left Leg"},
						{"Torso", "Right Leg"},
					}

					for idx, joint in ipairs(joints) do
						local p1 = char:FindFirstChild(joint[1])
						local p2 = char:FindFirstChild(joint[2])

						if p1 and p2 then
							local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
							local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)

							if vis1 and vis2 then
								local skelLine = linesFolder:FindFirstChild("Skel_" .. player.Name .. "_" .. idx) or Instance.new("Frame")
								skelLine.Name = "Skel_" .. player.Name .. "_" .. idx
								skelLine.AnchorPoint = Vector2.new(0.5, 0.5)
								skelLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
								skelLine.BorderSizePixel = 0
								skelLine.Parent = linesFolder

								updateLine(skelLine, Vector2.new(pos1.X, pos1.Y), Vector2.new(pos2.X, pos2.Y))
							end
						end
					end
				end

			end
		end
	end
end))

----------------------------------------------------
-- 7. KHỞI TẠO NÚT BẤM & BOX/HEALTH ESP
----------------------------------------------------
createToggle("ESP", "Hiện Khung (Box 3D)", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local box = p.Character.HumanoidRootPart:FindFirstChild("ESP_Box3D")
			if box then box.Visible = state end
		end
	end
end)

createToggle("Health", "Hiện Tên & % Máu", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local ui = p.Character.HumanoidRootPart:FindFirstChild("ESP_HealthUI")
			if ui then ui.Enabled = state end
		end
	end
end)

createToggle("Lines", "Hiện Đường Kẻ (Line)", function(state) end)
createToggle("Skeleton", "Hiện Bộ Xương (Skeleton)", function(state) end)
createToggle("Aimbot", "Bật Aimbot FOV", function(state) end)
createToggle("WallCheck", "Wall Check (Chống tường)", function(state) end)

local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

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
