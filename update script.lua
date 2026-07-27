-- DELTA X FIX: SMOOTH AIMBOT + LINE 3D + SKELETON

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
	Smoothness = 0.25, -- Mức độ mượt (Thấp = Mượt, Cao = Chặt)
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
-- 2. FOV CIRCLE (GUI GỐC)
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

----------------------------------------------------
-- 3. GIAO DIỆN MENU
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
menuFrame.Size = UDim2.new(0, 220, 0, 360)
menuFrame.Position = UDim2.new(0.25, 0, 0.1, 0)
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
title.Text = "DELTA ESP & AIMBOT FIX"
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

-- Chỉnh Độ Mượt Aim (Smoothness)
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

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 4. LOGIC AIMBOT (CÓ LERP TẠO ĐỘ MƯỢT) & WALL CHECK
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

table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot

	-- Aimbot Smooth
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
		end
	end
end))

----------------------------------------------------
-- 5. TAO ESP 3D (BOX, HEALTH, LINE 3D, SKELETON)
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

createToggle("Lines", "Hiện Line Laser 3D", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local beam = p.Character.HumanoidRootPart:FindFirstChild("ESP_Beam")
			if beam then beam.Enabled = state end
		end
	end
end)

createToggle("Skeleton", "Hiện Bộ Xương (Highlight)", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local hl = p.Character:FindFirstChild("ESP_Skeleton")
			if hl then hl.Enabled = state end
		end
	end
end)

createToggle("Aimbot", "Bật Aimbot FOV", function(state) end)
createToggle("WallCheck", "Wall Check (Chống tường)", function(state) end)

local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

		-- 1. Box 3D
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

		-- 2. Tên & Máu UI
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

		-- 3. Line Laser 3D (Đảm bảo hiện 100% không bị lỗi vẽ màn hình)
		local att1 = hrp:FindFirstChild("ESP_Att") or Instance.new("Attachment", hrp)
		att1.Name = "ESP_Att"

		local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local myHrp = myChar:WaitForChild("HumanoidRootPart", 5)
		if myHrp then
			local att0 = myHrp:FindFirstChild("ESP_AttSelf") or Instance.new("Attachment", myHrp)
			att0.Name = "ESP_AttSelf"

			local beam = hrp:FindFirstChild("ESP_Beam") or Instance.new("Beam")
			beam.Name = "ESP_Beam"
			beam.Attachment0 = att0
			beam.Attachment1 = att1
			beam.Width0 = 0.1
			beam.Width1 = 0.1
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			beam.FaceCamera = true
			beam.Enabled = Settings.Lines
			beam.Parent = hrp
		end

		-- 4. Skeleton (Highlight khớp xương)
		local highlight = char:FindFirstChild("ESP_Skeleton") or Instance.new("Highlight")
		highlight.Name = "ESP_Skeleton"
		highlight.Adornee = char
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.2
		highlight.Enabled = Settings.Skeleton
		highlight.Parent = char
	end

	if player.Character then task.spawn(characterAdded, player.Character) end
	table.insert(ScriptConnections, player.CharacterAdded:Connect(characterAdded))
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
table.insert(ScriptConnections, Players.PlayerAdded:Connect(applyESP))
