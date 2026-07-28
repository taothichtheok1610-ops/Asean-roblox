-- DELTA X: FULL ESP + AIMBOT + LOCK AIM + FLY + NOCLIP (FIXED ALL ERRORS)
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
			if obj.BoxLines then
				for _, line in pairs(obj.BoxLines) do if line.Remove then line:Remove() end end
			end
			if obj.TopLine then obj.TopLine:Remove() end
			if obj.Skeleton then
				for _, line in pairs(obj.Skeleton) do if line.Remove then line:Remove() end end
			end
		end
	end
	DrawObjects = {}
end

-- ⭐ CÀI ĐẶT MẶC ĐỊNH
local Settings = {
	ESP = false,
	Health = false,
	Lines = false,
	Skeleton = false,
	Aimbot = false,
	LockAim = false,
	PredictAim = false,
	AimSilent = false,
	WallCheck = false,
	TeamCheck = true,
	Fly = false,
	Noclip = false,
	FOVSize = 120,
	FlyHeight = 5,
	Smoothness = 0.25,
}

local CurrentFlyTarget = nil

----------------------------------------------------
-- 1. HÀM CHECK TEAM (ĐẶT LÊN ĐẦU ĐỂ TRÁNH LỖI NIL)
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

	if player.Character and LocalPlayer.Character then
		local pTeam = player.Character:FindFirstChild("Team") or player:FindFirstChild("Team")
		local myTeam = LocalPlayer.Character:FindFirstChild("Team") or LocalPlayer:FindFirstChild("Team")
		if pTeam and myTeam and pTeam.Value == myTeam.Value then
			return true
		end
	end

	return false
end

----------------------------------------------------
-- 2. CLEANUP UI CŨ & TẠO MENU SCROLLING
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

-- Menu Toggle Button
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
menuFrame.Size = UDim2.new(0, 230, 0, 350)
menuFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner") menuCorner.CornerRadius = UDim.new(0, 10) menuCorner.Parent = menuFrame

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
title.Text = "⭐ DELTA ESP & COMBAT"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = menuFrame

-- ⭐ KHUNG CUỘN SCROLLINGFRAME (ĐÃ CẤU HÌNH FIX LỖI MẤT CHỨC NĂNG)
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Name = "ScrollContainer"
scrollContainer.Size = UDim2.new(1, -10, 1, -35)
scrollContainer.Position = UDim2.new(0, 5, 0, 30)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 6
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollContainer

local function updateHealthUIState()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local gui = hrp:FindFirstChild("ESP_HealthUI")
				if gui then
					gui.Enabled = Settings.Health and not isSameTeam(plr)
				end
			end
		end
	end
end

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
		if name == "Health" or name == "TeamCheck" then
			updateHealthUIState()
		end
	end
	update()

	table.insert(ScriptConnections, btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end))
end

-- Controls
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

local flyInfoLabel = Instance.new("TextLabel")
flyInfoLabel.Size = UDim2.new(0.92, 0, 0, 18)
flyInfoLabel.BackgroundTransparency = 1
flyInfoLabel.Text = "Độ Cao Bay: 5"
flyInfoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
flyInfoLabel.Font = Enum.Font.SourceSansBold
flyInfoLabel.TextSize = 11
flyInfoLabel.Parent = scrollContainer

local flyHeightControl = Instance.new("Frame")
flyHeightControl.Size = UDim2.new(0.92, 0, 0, 28)
flyHeightControl.BackgroundTransparency = 1
flyHeightControl.Parent = scrollContainer

local btnFlyDown = Instance.new("TextButton")
btnFlyDown.Size = UDim2.new(0.48, 0, 1, 0)
btnFlyDown.Text = "- Cao"
btnFlyDown.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
btnFlyDown.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFlyDown.Font = Enum.Font.SourceSansBold
btnFlyDown.Parent = flyHeightControl
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 5) c3.Parent = btnFlyDown

local btnFlyUp = Instance.new("TextButton")
btnFlyUp.Size = UDim2.new(0.48, 0, 1, 0)
btnFlyUp.Position = UDim2.new(0.52, 0, 0, 0)
btnFlyUp.Text = "+ Cao"
btnFlyUp.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
btnFlyUp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFlyUp.Font = Enum.Font.SourceSansBold
btnFlyUp.Parent = flyHeightControl
local c4 = Instance.new("UICorner") c4.CornerRadius = UDim.new(0, 5) c4.Parent = btnFlyUp

btnFlyDown.MouseButton1Click:Connect(function() Settings.FlyHeight = math.max(1, Settings.FlyHeight - 1) end)
btnFlyUp.MouseButton1Click:Connect(function() Settings.FlyHeight = math.min(30, Settings.FlyHeight + 1) end)

-- Danh sách nút gạt
createToggle("ESP", "📦 Khung Hộp 2D")
createToggle("Health", "❤️ Hiện Tên & HP")
createToggle("Lines", "📍 Line Nối Đầu")
createToggle("Skeleton", "🦴 Skeleton Xương")
createToggle("Aimbot", "🎯 Aimbot Mượt")
createToggle("LockAim", "🔒 Lock Aim Chặt")
createToggle("PredictAim", "🎯 Dự Đoán Di Chuyển")
createToggle("AimSilent", "🔫 Aim Silent")
createToggle("TeamCheck", "👥 Kiểm Tra Team")
createToggle("Fly", "✈️ Fly Theo Player")
createToggle("Noclip", "👻 Noclip Xuyên Tường")
createToggle("WallCheck", "🚫 Wall Check")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 3. LOGIC XỬ LÝ FLY & NOCLIP
----------------------------------------------------
local function getClosestEnemy()
	local closestEnemy = nil
	local closestDistance = math.huge
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if isSameTeam(player) then continue end
			
			local head = player.Character:FindFirstChild("Head")
			local humanoid = player.Character:FindFirstChild("Humanoid")
			
			if head and humanoid and humanoid.Health > 0 then
				local distance = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestEnemy = player
				end
			end
		end
	end
	
	return closestEnemy
end

local function flyToTarget(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHead = targetPlayer.Character:FindFirstChild("Head")
	local myChar = LocalPlayer.Character
	if not targetHead or not myChar then return end
	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	local flyPos = targetHead.Position + Vector3.new(0, Settings.FlyHeight, 0)
	myHRP.CFrame = CFrame.new(flyPos, targetHead.Position)
end

table.insert(ScriptConnections, RunService.Stepped:Connect(function()
	if Settings.Noclip or Settings.Fly then
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end))

----------------------------------------------------
-- 4. AIMBOT & AIM SILENT
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
			if isSameTeam(player) then continue end
			
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
-- 5. DRAWING ESP LOGIC
----------------------------------------------------
local R15Joints = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local R6Joints = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
	{"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function createLine(color)
	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = color or Color3.fromRGB(0, 255, 0)
	line.Transparency = 1
	line.Visible = false
	return line
end

local function getPlayerDrawings(player)
	if not DrawObjects[player] then
		local boxLines = {
			Top = createLine(Color3.fromRGB(0, 255, 0)),
			Bottom = createLine(Color3.fromRGB(0, 255, 0)),
			Left = createLine(Color3.fromRGB(0, 255, 0)),
			Right = createLine(Color3.fromRGB(0, 255, 0))
		}
		local topLine = createLine(Color3.fromRGB(255, 255, 0))
		local skeleton = {}
		for i = 1, 15 do table.insert(skeleton, createLine(Color3.fromRGB(255, 255, 255))) end

		DrawObjects[player] = { BoxLines = boxLines, TopLine = topLine, Skeleton = skeleton }
	end
	return DrawObjects[player]
end

local function removePlayerDrawings(player)
	if DrawObjects[player] then
		if DrawObjects[player].BoxLines then
			for _, line in pairs(DrawObjects[player].BoxLines) do line:Remove() end
		end
		if DrawObjects[player].TopLine then DrawObjects[player].TopLine:Remove() end
		for _, line in ipairs(DrawObjects[player].Skeleton) do line:Remove() end
		DrawObjects[player] = nil
	end
end

Players.PlayerRemoving:Connect(removePlayerDrawings)

----------------------------------------------------
-- 6. RENDER STEPPED MAIN LOOP
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot
	flyInfoLabel.Text = string.format("Độ Cao Bay: %d", Settings.FlyHeight)

	-- FLY LOGIC
	if Settings.Fly then
		if CurrentFlyTarget and CurrentFlyTarget.Character then
			local targetHumanoid = CurrentFlyTarget.Character:FindFirstChild("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 and not isSameTeam(CurrentFlyTarget) then
				flyToTarget(CurrentFlyTarget)
			else
				CurrentFlyTarget = getClosestEnemy()
				if CurrentFlyTarget then flyToTarget(CurrentFlyTarget) end
			end
		else
			CurrentFlyTarget = getClosestEnemy()
			if CurrentFlyTarget then flyToTarget(CurrentFlyTarget) end
		end
	end

	-- AIMBOT LOGIC
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			local targetPos = targetHead.Position
			if Settings.PredictAim and targetHead.Parent:FindFirstChild("Humanoid") then
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
		local targetHead = getClosestPlayerInFOV()
		if targetHead and LocalPlayer.Character then
			local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myHRP then
				myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(targetHead.Position.X, myHRP.Position.Y, targetHead.Position.Z))
			end
		end
	end

	-- ESP RENDER
	local topScreenPos = Vector2.new(Camera.ViewportSize.X / 2, 0)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local objs = DrawObjects[player]
			
			-- Ẩn khi cùng team
			if isSameTeam(player) then
				if objs then
					for _, line in pairs(objs.BoxLines) do line.Visible = false end
					objs.TopLine.Visible = false
					for _, line in ipairs(objs.Skeleton) do line.Visible = false end
				end
				continue
			end
			
			objs = getPlayerDrawings(player)
			local char = player.Character
			local humanoid = char and char:FindFirstChild("Humanoid")
			local head = char and char:FindFirstChild("Head")

			if char and humanoid and humanoid.Health > 0 and head then
				local lowestY = head.Position.Y
				for _, part in ipairs(char:GetChildren()) do
					if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Foot")) then
						local bottomPartY = part.Position.Y - (part.Size.Y / 2)
						if bottomPartY < lowestY then lowestY = bottomPartY end
					end
				end

				if lowestY == head.Position.Y then lowestY = head.Position.Y - 4.5 end

				local headTopWorld = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.3, 0)
				local feetBottomWorld = Vector3.new(head.Position.X, lowestY, head.Position.Z)

				local head2D, headVis = Camera:WorldToViewportPoint(headTopWorld)
				local feet2D, feetVis = Camera:WorldToViewportPoint(feetBottomWorld)

				if headVis or feetVis then
					local height = math.abs(head2D.Y - feet2D.Y)
					local width = height * 0.6
					local topY = math.min(head2D.Y, feet2D.Y)
					local bottomY = math.max(head2D.Y, feet2D.Y)
					local centerX = head2D.X

					if Settings.ESP then
						objs.BoxLines.Top.From = Vector2.new(centerX - width / 2, topY)
						objs.BoxLines.Top.To = Vector2.new(centerX + width / 2, topY)
						objs.BoxLines.Top.Visible = true

						objs.BoxLines.Bottom.From = Vector2.new(centerX - width / 2, bottomY)
						objs.BoxLines.Bottom.To = Vector2.new(centerX + width / 2, bottomY)
						objs.BoxLines.Bottom.Visible = true

						objs.BoxLines.Left.From = Vector2.new(centerX - width / 2, topY)
						objs.BoxLines.Left.To = Vector2.new(centerX - width / 2, bottomY)
						objs.BoxLines.Left.Visible = true

						objs.BoxLines.Right.From = Vector2.new(centerX + width / 2, topY)
						objs.BoxLines.Right.To = Vector2.new(centerX + width / 2, bottomY)
						objs.BoxLines.Right.Visible = true
					else
						for _, line in pairs(objs.BoxLines) do line.Visible = false end
					end

					if Settings.Lines then
						objs.TopLine.From = topScreenPos
						objs.TopLine.To = Vector2.new(head2D.X, head2D.Y)
						objs.TopLine.Visible = true
					else
						objs.TopLine.Visible = false
					end

					if Settings.Skeleton then
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
					else
						for _, line in ipairs(objs.Skeleton) do line.Visible = false end
					end
				else
					for _, line in pairs(objs.BoxLines) do line.Visible = false end
					objs.TopLine.Visible = false
					for _, line in ipairs(objs.Skeleton) do line.Visible = false end
				end
			else
				for _, line in pairs(objs.BoxLines) do line.Visible = false end
				objs.TopLine.Visible = false
				for _, line in ipairs(objs.Skeleton) do line.Visible = false end
			end
		end
	end
end))

----------------------------------------------------
-- 7. HEALTH UI
----------------------------------------------------
local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

		local billboard = hrp:FindFirstChild("ESP_HealthUI") or Instance.new("BillboardGui")
		billboard.Name = "ESP_HealthUI"
		billboard.Adornee = hrp
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled = Settings.Health and not isSameTeam(player)

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
			if isSameTeam(player) then
				billboard.Enabled = false
				return
			end
			billboard.Enabled = Settings.Health
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

print("✅ ĐÃ FIX TẤT CẢ LỖI! MENU SCROLL VẪN CHẠY VÀ ESP/AIM MẠNH MẼ!")
