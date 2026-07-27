-- DELTA X ULTIMATE ESP + AIMBOT FOV (WALL CHECK)

-- 1. NGẮT LUỒNG SCRIPT CŨ TRÁNH LẶP MENU
if _G.Delta_Cleanup then
	pcall(_G.Delta_Cleanup)
end

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
		if conn and conn.Disconnect then
			pcall(function() conn:Disconnect() end)
		end
	end
	ScriptConnections = {}
	if _G.FOVCircle then
		pcall(function() _G.FOVCircle:Remove() end)
	end
end

-- Cấu hình mặc định
local Settings = {
	ESP = true,
	Health = true,
	Aimbot = true,
	WallCheck = true,
	FOVSize = 120, -- Bán kính vòng FOV
}

----------------------------------------------------
-- 2. DỌN SẠCH UI CŨ
----------------------------------------------------
local function wipeOldUI(folder)
	if not folder then return end
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:find("Delta_UI") then
			child:Destroy()
		end
	end
end

wipeOldUI(LocalPlayer:FindFirstChild("PlayerGui"))
wipeOldUI(CoreGui)
if gethui then wipeOldUI(gethui()) end

local parentContainer = LocalPlayer:WaitForChild("PlayerGui")
if gethui then
	parentContainer = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
	parentContainer = CoreGui
end

----------------------------------------------------
-- 3. TẠO VÒNG FOV CIRCLE (DRAWING LIB)
----------------------------------------------------
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 60
fovCircle.Radius = Settings.FOVSize
fovCircle.Filled = false
fovCircle.Visible = Settings.Aimbot
fovCircle.Color = Color3.fromRGB(0, 255, 255)
fovCircle.Transparency = 1
_G.FOVCircle = fovCircle

----------------------------------------------------
-- 4. TẠO MENU GIAO DIỆN
----------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Delta_UI_" .. math.random(1000, 9999)
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = parentContainer

-- Nút Bật/Tắt Menu tròn
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

-- Khung Menu
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 210, 0, 280)
menuFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Drag Menu Mobile
local dragging, dragInput, dragStart, startPos
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
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "DELTA ESP & AIMBOT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = menuFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

local function createToggle(name, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
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

-- Slider tăng giảm kích thước vòng FOV
local fovControl = Instance.new("Frame")
fovControl.Size = UDim2.new(1, 0, 0, 40)
fovControl.BackgroundTransparency = 1
fovControl.Parent = container

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 15)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "Kích thước FOV: " .. Settings.FOVSize
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.Font = Enum.Font.SourceSansBold
fovLabel.TextSize = 12
fovLabel.Parent = fovControl

local btnMinus = Instance.new("TextButton")
btnMinus.Size = UDim2.new(0.45, 0, 0, 22)
btnMinus.Position = UDim2.new(0, 0, 0, 18)
btnMinus.Text = "- FOV"
btnMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinus.Font = Enum.Font.SourceSansBold
btnMinus.Parent = fovControl

local btnPlus = Instance.new("TextButton")
btnPlus.Size = UDim2.new(0.45, 0, 0, 22)
btnPlus.Position = UDim2.new(0.55, 0, 0, 18)
btnPlus.Text = "+ FOV"
btnPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPlus.Font = Enum.Font.SourceSansBold
btnPlus.Parent = fovControl

btnMinus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.max(30, Settings.FOVSize - 20)
	fovCircle.Radius = Settings.FOVSize
	fovLabel.Text = "Kích thước FOV: " .. Settings.FOVSize
end)

btnPlus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.min(500, Settings.FOVSize + 20)
	fovCircle.Radius = Settings.FOVSize
	fovLabel.Text = "Kích thước FOV: " .. Settings.FOVSize
end)

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 5. LOGIC WALLCHECK & AIMBOT
----------------------------------------------------
local function isVisible(targetPart)
	if not Settings.WallCheck then return true end
	
	local origin = Camera.CFrame.Position
	local destination = targetPart.Position
	local direction = (destination - origin)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	-- Bỏ qua bản thân và kẻ địch đang nhắm tới
	local ignoreList = {LocalPlayer.Character, targetPart.Parent}
	raycastParams.FilterDescendantsInstances = ignoreList

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result == nil -- Nếu không va chạm tường thì là thấy kẻ địch
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

					if distance < shortestDistance then
						if isVisible(head) then
							shortestDistance = distance
							closestPlayer = head
						end
					end
				end
			end
		end
	end
	return closestPlayer
end

----------------------------------------------------
-- 6. RUNSERVICE LOOP (AIMBOT & ESP & FOV UPDATE)
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	-- Cập nhật vị trí vòng FOV ở chính giữa màn hình
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	fovCircle.Visible = Settings.Aimbot

	-- Aimbot Lock Tâm
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
		end
	end
end))

----------------------------------------------------
-- 7. KHỞI TẠO NÚT BẤM MENU & ESP
----------------------------------------------------
createToggle("ESP", "Nhìn Xuyên Tường", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local box = p.Character.HumanoidRootPart:FindFirstChild("ESP_Box3D")
			if box then box.Visible = state end
		end
	end
end)

createToggle("Health", "Hiện Tên & Máu", function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local ui = p.Character.HumanoidRootPart:FindFirstChild("ESP_HealthUI")
			if ui then ui.Enabled = state end
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
