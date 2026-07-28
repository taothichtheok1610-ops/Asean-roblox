-- DELTA X: UNIVERSAL HIGHLIGHT ESP + AIMBOT + FLY + NOCLIP (NO DRAWING LIB NEEDED)
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

	-- Dọn dẹp ESP Highlights
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			local hl = plr.Character:FindFirstChild("Delta_ESP_HL")
			if hl then hl:Destroy() end
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local gui = hrp:FindFirstChild("Delta_ESP_UI")
				if gui then gui:Destroy() end
			end
		end
	end
end

-- ⭐ CÀI ĐẶT MẶC ĐỊNH
local Settings = {
	ESP = true,           -- Mặc định ON để test ngay
	Health = true,        -- Mặc định ON
	Aimbot = false,
	LockAim = false,
	PredictAim = false,
	AimSilent = false,
	WallCheck = false,
	TeamCheck = false,     -- Mặc định OFF để không bị ẩn ESP do lỗi Team
	Fly = false,
	Noclip = false,
	FOVSize = 150,
	FlyHeight = 5,
	Smoothness = 0.2,
}

local CurrentFlyTarget = nil

----------------------------------------------------
-- 1. HÀM CHECK TEAM
----------------------------------------------------
local function isSameTeam(player)
	if not Settings.TeamCheck then return false end
	if not player or not LocalPlayer or player == LocalPlayer then return false end
	
	if player.Team ~= nil and LocalPlayer.Team ~= nil then
		return player.Team == LocalPlayer.Team
	end
	
	if player.TeamColor == LocalPlayer.TeamColor and player.TeamColor ~= nil then
		return true
	end

	return false
end

----------------------------------------------------
-- 2. TẠO MENU UI CÓ KHUNG CUỘN (SCROLL)
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
fovFrame.Visible = false
fovFrame.Parent = screenGui

local fovCorner = Instance.new("UICorner") fovCorner.CornerRadius = UDim.new(1, 0) fovCorner.Parent = fovFrame
local fovStroke = Instance.new("UIStroke") fovStroke.Color = Color3.fromRGB(0, 255, 255) fovStroke.Thickness = 1.5 fovStroke.Parent = fovFrame

-- Toggle Button
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

local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(1, 0) btnCorner.Parent = toggleBtn

-- Khung Menu
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 230, 0, 340)
menuFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = true
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner") menuCorner.CornerRadius = UDim.new(0, 10) menuCorner.Parent = menuFrame

-- Dragging
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
title.Text = "⭐ DELTA HIGHLIGHT ESP & AIM"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = menuFrame

-- Khung cuộn ScrollingFrame
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Name = "ScrollContainer"
scrollContainer.Size = UDim2.new(1, -10, 1, -35)
scrollContainer.Position = UDim2.new(0, 5, 0, 30)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 5
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollContainer

local function createToggle(name, text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.92, 0, 0, 28)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = scrollContainer

	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 5) corner.Parent = btn

	local function update()
		if Settings[name] then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			btn.Text = text .. ": ✓ ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
			btn.Text = text .. ": ✗ OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	update()

	table.insert(ScriptConnections, btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end))
end

-- Controls FOV & Fly
local fovControl = Instance.new("Frame")
fovControl.Size = UDim2.new(0.92, 0, 0, 28)
fovControl.BackgroundTransparency = 1
fovControl.Parent = scrollContainer

local btnMinus = Instance.new("TextButton")
btnMinus.Size = UDim2.new(0.48, 0, 1, 0)
btnMinus.Text = "- FOV"
btnMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinus.Font = Enum.Font.SourceSansBold
btnMinus.Parent = fovControl
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 5) c1.Parent = btnMinus

local btnPlus = Instance.new("TextButton")
btnPlus.Size = UDim2.new(0.48, 0, 1, 0)
btnPlus.Position = UDim2.new(0.52, 0, 0, 0)
btnPlus.Text = "+ FOV"
btnPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPlus.Font = Enum.Font.SourceSansBold
btnPlus.Parent = fovControl
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 5) c2.Parent = btnPlus

btnMinus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.max(40, Settings.FOVSize - 20)
	fovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
end)

btnPlus.MouseButton1Click:Connect(function()
	Settings.FOVSize = math.min(400, Settings.FOVSize + 20)
	fovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
end)

-- Tạo các nút Toggle
createToggle("ESP", "✨ ESP Highlight (Phát Sáng)")
createToggle("Health", "❤️ Hiện Tên & % HP")
createToggle("Aimbot", "🎯 Aimbot Mượt")
createToggle("LockAim", "🔒 Lock Aim Chặt")
createToggle("PredictAim", "🎯 Dự Đoán Di Chuyển")
createToggle("AimSilent", "🔫 Aim Silent")
createToggle("TeamCheck", "👥 Kiểm Tra Team")
createToggle("Fly", "✈️ Fly Theo Địch")
createToggle("Noclip", "👻 Noclip Xuyên Tường")
createToggle("WallCheck", "🚫 Wall Check")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 3. AIMBOT LOGIC (CHUẨN HOẠT ĐỘNG)
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

local function getTargetHead()
	local closestHead = nil
	local shortestDistance = Settings.FOVSize
	local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if isSameTeam(player) then continue end
			
			local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
					if distance < shortestDistance and isVisible(head) then
						shortestDistance = distance
						closestHead = head
					end
				end
			end
		end
	end
	return closestHead
end

----------------------------------------------------
-- 4. HIGHLIGHT ESP & HEALTH LOGIC
----------------------------------------------------
local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

		-- Highlight ESP (Xuyên Tường Phát Sáng)
		local hl = char:FindFirstChild("Delta_ESP_HL") or Instance.new("Highlight")
		hl.Name = "Delta_ESP_HL"
		hl.Adornee = char
		hl.FillColor = Color3.fromRGB(255, 50, 50)
		hl.FillTransparency = 0.5
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = char

		-- Billboard Health UI
		local billboard = hrp:FindFirstChild("Delta_ESP_UI") or Instance.new("BillboardGui")
		billboard.Name = "Delta_ESP_UI"
		billboard.Adornee = hrp
		billboard.Size = UDim2.new(0, 180, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = hrp

		local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(0, 255, 150)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 13
		label.Parent = billboard

		local function updateVisuals()
			local shouldShow = not isSameTeam(player) and humanoid.Health > 0
			
			hl.Enabled = Settings.ESP and shouldShow
			billboard.Enabled = Settings.Health and shouldShow

			if shouldShow then
				local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
				label.Text = string.format("%s\n[%d%% HP]", player.DisplayName, math.max(0, hpPercent))
			end
		end

		table.insert(ScriptConnections, humanoid.HealthChanged:Connect(updateVisuals))
		table.insert(ScriptConnections, RunService.Heartbeat:Connect(updateVisuals))
	end

	if player.Character then task.spawn(characterAdded, player.Character) end
	table.insert(ScriptConnections, player.CharacterAdded:Connect(characterAdded))
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
table.insert(ScriptConnections, Players.PlayerAdded:Connect(applyESP))

----------------------------------------------------
-- 5. MAIN RENDER LOOP (AIMBOT & FLY)
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot

	-- AIMBOT
	if Settings.Aimbot then
		local targetHead = getTargetHead()
		if targetHead then
			local targetPos = targetHead.Position
			if Settings.PredictAim and targetHead.AssemblyLinearVelocity then
				targetPos = targetPos + (targetHead.AssemblyLinearVelocity * 0.15)
			end

			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
			if Settings.LockAim then
				Camera.CFrame = targetCFrame
			else
				Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
			end
		end
	end

	-- AIM SILENT
	if Settings.AimSilent then
		local targetHead = getTargetHead()
		if targetHead and LocalPlayer.Character then
			local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myHRP then
				myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetHead.Position.X, myHRP.Position.Y, targetHead.Position.Z))
			end
		end
	end
end))

-- NOCLIP
table.insert(ScriptConnections, RunService.Stepped:Connect(function()
	if Settings.Noclip then
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end))

print("✅ SCRIPT ĐÃ ĐƯỢC CHUYỂN SANG NỀN TẢNG UNIVERSAL HIGHLIGHT - ESP & AIM CHẠY 100%!")
