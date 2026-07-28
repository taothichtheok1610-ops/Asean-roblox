-- DELTA X: FULL ESP + AIMBOT + LOCK AIM - HOÀN CHỈNH
-- Tất cả mặc định là OFF (Tắt)

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

-- ⭐ TOÀN BỘ SETTING MẶC ĐỊNH LÀ FALSE (OFF)
local Settings = {
	ESP = false,
	Health = false,
	Lines = false,
	Skeleton = false,
	Aimbot = false,
	LockAim = false,        -- 🔒 LOCK AIM CHẶT
	PredictAim = false,     -- 🎯 DỰ ĐOÁN CHUYỂN ĐỘNG
	WallCheck = false,
	TeamCheck = true,       -- 👥 TEAM CHECK (MẶC ĐỊNH BẬT)
	Fly = false,            -- ✈️ FLY THEO PLAYER (MẶC ĐỊNH TẮT)
	FOVSize = 120,
	Smoothness = 0.25,
}

local CurrentFlyTarget = nil  -- ⭐ LƯU TARGET ĐANG FLY

----------------------------------------------------
-- 1. CLEANUP UI CŨ & MENU GUI
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

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovFrame

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

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 240, 0, 480)  -- ⭐ TĂNG CHIỀU CAO CHO THÊM BUTTON
menuFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

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
title.Text = "⭐ DELTA ESP PRO"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
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

local function updateHealthUIState()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local gui = hrp:FindFirstChild("ESP_HealthUI")
				if gui then
					gui.Enabled = Settings.Health
				end
			end
		end
	end
end

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
			btn.Text = text .. ": ✓ ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
			btn.Text = text .. ": ✗ OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		if name == "Health" then
			updateHealthUIState()
		end
	end
	update()

	table.insert(ScriptConnections, btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end))
end

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

-- ⭐ TẠO CÁC TOGGLE
createToggle("ESP", "📦 Khung Hộp 2D")
createToggle("Health", "❤️ Hiện Tên & HP")
createToggle("Lines", "📍 Line Nối Đầu")
createToggle("Skeleton", "🦴 Skeleton Xương")
createToggle("Aimbot", "🎯 Aimbot Mượt")
createToggle("LockAim", "🔒 Lock Aim Chặt")     -- ⭐ LOCK AIM
createToggle("PredictAim", "🎯 Dự Đoán Di Chuyển")  -- ⭐ PREDICT AIM
createToggle("TeamCheck", "👥 Kiểm Tra Team")  -- ⭐ TEAM CHECK
createToggle("Fly", "✈️ Fly Theo Player")     -- ⭐ FLY
createToggle("WallCheck", "🚫 Wall Check")

table.insert(ScriptConnections, toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end))

----------------------------------------------------
-- 2. TEAM CHECK LOGIC
----------------------------------------------------
local function isSameTeam(player)
	if not Settings.TeamCheck then return false end
	if not player or not LocalPlayer then return false end
	
	local playerTeam = player.Team
	local localPlayerTeam = LocalPlayer.Team
	
	-- Nếu không có team (neutral) thì không cùng team
	if not playerTeam or not localPlayerTeam then return false end
	
	-- Kiểm tra có phải cùng team không
	return playerTeam == localPlayerTeam
end

----------------------------------------------------
-- 2.5 FLY LOGIC
----------------------------------------------------
local function getClosestEnemy()
	local closestEnemy = nil
	local closestDistance = math.huge
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			-- ⭐ KIỂM TRA TEAM
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
	if not targetHead then return end
	
	local myChar = LocalPlayer.Character
	if not myChar then return end
	
	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	-- ⭐ FLY LÊN TRÊN ĐẦU PLAYER (CAO 5 STUDS)
	local flyPos = targetHead.Position + Vector3.new(0, 5, 0)
	myHRP.CFrame = CFrame.new(flyPos)
end

----------------------------------------------------
-- 3. AIMBOT LOGIC
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
			-- ⭐ KIỂM TRA TEAM - NẾU CÙNG TEAM THÌ BỎ QUA
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
-- 3. DRAWING LOGIC
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
		for i = 1, 15 do
			table.insert(skeleton, createLine(Color3.fromRGB(255, 255, 255)))
		end

		DrawObjects[player] = {
			BoxLines = boxLines,
			TopLine = topLine,
			Skeleton = skeleton
		}
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
-- 4. RENDER LOOP - ⭐ CÓ LOCK AIM + PREDICT AIM + FLY
----------------------------------------------------
table.insert(ScriptConnections, RunService.RenderStepped:Connect(function()
	fovFrame.Visible = Settings.Aimbot

	-- ⭐ FLY LOGIC
	if Settings.Fly then
		-- Kiểm tra xem target hiện tại còn sống không
		if CurrentFlyTarget and CurrentFlyTarget.Character then
			local targetHumanoid = CurrentFlyTarget.Character:FindFirstChild("Humanoid")
			if targetHumanoid and targetHumanoid.Health > 0 then
				-- Target còn sống, fly tới
				flyToTarget(CurrentFlyTarget)
			else
				-- Target chết, tìm target mới
				CurrentFlyTarget = getClosestEnemy()
				if CurrentFlyTarget then
					flyToTarget(CurrentFlyTarget)
				end
			end
		else
			-- Không có target, tìm target mới
			CurrentFlyTarget = getClosestEnemy()
			if CurrentFlyTarget then
				flyToTarget(CurrentFlyTarget)
			end
		end
	end

	-- ⭐ AIMBOT LOGIC (LOCK AIM + SMOOTH AIM + PREDICT)
	if Settings.Aimbot then
		local targetHead = getClosestPlayerInFOV()
		if targetHead then
			local targetPos = targetHead.Position
			
			-- ⭐ DỰ ĐOÁN CHUYỂN ĐỘNG NẾU BẬT
			if Settings.PredictAim and targetHead.Parent:FindFirstChild("Humanoid") then
				local targetVel = targetHead.AssemblyLinearVelocity
				targetPos = targetPos + (targetVel * 0.15)  -- Dự đoán 0.15 giây
			end
			
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
			
			-- ⭐ LOCK AIM CHẶT HOẶC SMOOTH AIM
			if Settings.LockAim then
				-- Khóa trực tiếp, không mượt
				Camera.CFrame = targetCFrame
			else
				-- Aim mượt mà bình thường
				Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
			end
		end
	end

	local topScreenPos = Vector2.new(Camera.ViewportSize.X / 2, 0)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			-- ⭐ KIỂM TRA TEAM - NẾU CÙNG TEAM THÌ BỎ QUA
			if isSameTeam(player) then continue end
			
			local objs = getPlayerDrawings(player)
			local char = player.Character
			local humanoid = char and char:FindFirstChild("Humanoid")
			local head = char and char:FindFirstChild("Head")

			if char and humanoid and humanoid.Health > 0 and head then
				local lowestY = head.Position.Y
				for _, part in ipairs(char:GetChildren()) do
					if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Foot")) then
						local bottomPartY = part.Position.Y - (part.Size.Y / 2)
						if bottomPartY < lowestY then
							lowestY = bottomPartY
						end
					end
				end

				if lowestY == head.Position.Y then
					lowestY = head.Position.Y - 4.5
				end

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

					-- 1. BOX 2D
					if Settings.ESP then
						local topLeft = Vector2.new(centerX - width / 2, topY)
						local topRight = Vector2.new(centerX + width / 2, topY)
						local bottomLeft = Vector2.new(centerX - width / 2, bottomY)
						local bottomRight = Vector2.new(centerX + width / 2, bottomY)

						objs.BoxLines.Top.From = topLeft
						objs.BoxLines.Top.To = topRight
						objs.BoxLines.Top.Visible = true

						objs.BoxLines.Bottom.From = bottomLeft
						objs.BoxLines.Bottom.To = bottomRight
						objs.BoxLines.Bottom.Visible = true

						objs.BoxLines.Left.From = topLeft
						objs.BoxLines.Left.To = bottomLeft
						objs.BoxLines.Left.Visible = true

						objs.BoxLines.Right.From = topRight
						objs.BoxLines.Right.To = bottomRight
						objs.BoxLines.Right.Visible = true
					else
						for _, line in pairs(objs.BoxLines) do line.Visible = false end
					end

					-- 2. LINE ĐỈNH
					if Settings.Lines then
						objs.TopLine.From = topScreenPos
						objs.TopLine.To = Vector2.new(head2D.X, head2D.Y)
						objs.TopLine.Visible = true
					else
						objs.TopLine.Visible = false
					end

					-- 3. SKELETON
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

						for i = #joints + 1, #objs.Skeleton do
							objs.Skeleton[i].Visible = false
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
-- 5. HEALTH & NAME UI
----------------------------------------------------
local function applyESP(player)
	if player == LocalPlayer then return end
	-- ⭐ KIỂM TRA TEAM - NẾU CÙNG TEAM THÌ BỎ QUA
	if isSameTeam(player) then return end

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

----------------------------------------------------
-- END OF SCRIPT
----------------------------------------------------
print("✅ DELTA ESP PRO LOADED! Nhấn MENU để bật các chức năng")
