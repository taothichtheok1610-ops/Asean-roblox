-- [[ DELTA X: ESP + AIMBOT (CHỈ DÀNH CHO SAN DIEGO) ]]
-- [[ BỎ: FLY, WALKSPEED, AUTO CLICK, WALL CHECK, AIM SILENT ]]
if _G.SD_Cleanup then pcall(_G.SD_Cleanup) end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptConnections = {}
local DrawObjects = {}

_G.SD_Cleanup = function()
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

local Settings = {
	ESP = true,
	Health = true,
	Lines = true,
	Skeleton = true,
	Aimbot = true,
	TeamCheck = true,
	FOVSize = 200,
	Smoothness = 0.2,
	VisibleCheck = false,  -- Tắt để tránh lỗi San Diego
	AimPart = "Head"       -- San Diego dùng Head
}

-- [[ TẠO UI ]]
local function wipeOldUI(folder)
	if not folder then return end
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:find("SD_UI") then child:Destroy() end
	end
end

wipeOldUI(LocalPlayer:FindFirstChild("PlayerGui"))
wipeOldUI(CoreGui)
if gethui then wipeOldUI(gethui()) end

local parentContainer = LocalPlayer:WaitForChild("PlayerGui")
if gethui then parentContainer = gethui() 
elseif CoreGui:FindFirstChild("RobloxGui") then parentContainer = CoreGui:FindFirstChild("RobloxGui") end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SD_UI_" .. math.random(1000, 9999)
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
fovFrame.Visible = true
fovFrame.Parent = screenGui
local fovCorner = Instance.new("UICorner") fovCorner.CornerRadius = UDim.new(1, 0) fovCorner.Parent = fovFrame
local fovStroke = Instance.new("UIStroke") fovStroke.Color = Color3.fromRGB(0, 255, 255) fovStroke.Thickness = 1.5 fovStroke.Parent = fovFrame

-- Menu Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "MENU"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Active = true
toggleBtn.Parent = screenGui
local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(1, 0) btnCorner.Parent = toggleBtn

-- Menu Frame
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 220, 0, 300)
menuFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui
local menuCorner = Instance.new("UICorner") menuCorner.CornerRadius = UDim.new(0, 10) menuCorner.Parent = menuFrame

-- Drag
local dragging, dragStart, startPos
menuFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = menuFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "SAN DIEGO ESP + AIMBOT"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = menuFrame

local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Name = "ScrollContainer"
scrollContainer.Size = UDim2.new(1, -10, 1, -35)
scrollContainer.Position = UDim2.new(0, 5, 0, 30)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 4
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.Parent = menuFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollContainer

-- Tạo toggle
local function createToggle(name, text, default)
	Settings[name] = (default ~= nil and default) or false
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 26)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = scrollContainer
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 5) corner.Parent = btn
	
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
	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
	end)
end

createToggle("ESP", "ESP Box", true)
createToggle("Health", "ESP Health", true)
createToggle("Lines", "ESP Lines", true)
createToggle("Skeleton", "ESP Skeleton", true)
createToggle("Aimbot", "Aimbot", true)
createToggle("TeamCheck", "Team Check", true)

-- FOV Control
local fovControl = Instance.new("Frame")
fovControl.Size = UDim2.new(0.95, 0, 0, 26)
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

toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

-- [[ HÀM CHÍNH SAN DIEGO ]]
local function isSameTeam(player)
	if not Settings.TeamCheck then return false end
	if not player or not LocalPlayer or player == LocalPlayer then return false end
	if player.Team ~= nil and LocalPlayer.Team ~= nil then
		return player.Team == LocalPlayer.Team
	end
	return false
end

-- Aimbot cho San Diego (chỉ xoay camera)
local function getClosestInFOV()
	local closest = nil
	local minDist = Settings.FOVSize
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if isSameTeam(p) then continue end
			local head = p.Character:FindFirstChild("Head")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					if dist < minDist then
						minDist = dist
						closest = head
					end
				end
			end
		end
	end
	return closest
end

-- [[ ESP DRAWING ]]
local function createLine(color)
	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = color or Color3.fromRGB(0, 255, 0)
	line.Transparency = 1
	line.Visible = false
	return line
end

local function getDrawings(player)
	if not DrawObjects[player] then
		local boxLines = {
			Top = createLine(Color3.fromRGB(0, 255, 0)),
			Bottom = createLine(Color3.fromRGB(0, 255, 0)),
			Left = createLine(Color3.fromRGB(0, 255, 0)),
			Right = createLine(Color3.fromRGB(0, 255, 0))
		}
		local topLine = createLine(Color3.fromRGB(255, 255, 0))
		local skeleton = {}
		for i = 1, 15 do skeleton[i] = createLine(Color3.fromRGB(255, 255, 255)) end
		DrawObjects[player] = { BoxLines = boxLines, TopLine = topLine, Skeleton = skeleton }
	end
	return DrawObjects[player]
end

local R6Joints = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
	{"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}
local R15Joints = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

-- [[ VÒNG LẶP CHÍNH ]]
local topScreenPos = Vector2.new(Camera.ViewportSize.X / 2, 0)

RunService.RenderStepped:Connect(function()
	-- Aimbot
	if Settings.Aimbot then
		local target = getClosestInFOV()
		if target then
			local targetPos = target.Position
			local newCF = CFrame.new(Camera.CFrame.Position, targetPos)
			Camera.CFrame = Camera.CFrame:Lerp(newCF, Settings.Smoothness)
		end
	end
	
	-- ESP
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local objs = getDrawings(player)
		
		if isSameTeam(player) then
			for _, line in pairs(objs.BoxLines) do line.Visible = false end
			objs.TopLine.Visible = false
			for _, line in ipairs(objs.Skeleton) do line.Visible = false end
			continue
		end
		
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local head = char and char:FindFirstChild("Head")
		
		if char and hum and hum.Health > 0 and head then
			-- Tính bounding box
			local lowestY = head.Position.Y
			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") and (part.Name:find("Leg") or part.Name:find("Foot")) then
					local bottomY = part.Position.Y - (part.Size.Y / 2)
					if bottomY < lowestY then lowestY = bottomY end
				end
			end
			if lowestY == head.Position.Y then lowestY = head.Position.Y - 4.5 end
			
			local headTop = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.3, 0)
			local feetBottom = Vector3.new(head.Position.X, lowestY, head.Position.Z)
			
			local h2D, hVis = Camera:WorldToViewportPoint(headTop)
			local f2D, fVis = Camera:WorldToViewportPoint(feetBottom)
			
			if hVis or fVis then
				local height = math.abs(h2D.Y - f2D.Y)
				local width = height * 0.6
				local topY = math.min(h2D.Y, f2D.Y)
				local bottomY = math.max(h2D.Y, f2D.Y)
				local centerX = h2D.X
				
				local tl = Vector2.new(centerX - width/2, topY)
				local tr = Vector2.new(centerX + width/2, topY)
				local bl = Vector2.new(centerX - width/2, bottomY)
				local br = Vector2.new(centerX + width/2, bottomY)
				
				if Settings.ESP then
					objs.BoxLines.Top.From = tl; objs.BoxLines.Top.To = tr; objs.BoxLines.Top.Visible = true
					objs.BoxLines.Bottom.From = bl; objs.BoxLines.Bottom.To = br; objs.BoxLines.Bottom.Visible = true
					objs.BoxLines.Left.From = tl; objs.BoxLines.Left.To = bl; objs.BoxLines.Left.Visible = true
					objs.BoxLines.Right.From = tr; objs.BoxLines.Right.To = br; objs.BoxLines.Right.Visible = true
				else
					for _, line in pairs(objs.BoxLines) do line.Visible = false end
				end
				
				if Settings.Lines then
					objs.TopLine.From = topScreenPos
					objs.TopLine.To = Vector2.new(h2D.X, h2D.Y)
					objs.TopLine.Visible = true
				else
					objs.TopLine.Visible = false
				end
				
				if Settings.Skeleton then
					local isR15 = char:FindFirstChild("UpperTorso") ~= nil
					local joints = isR15 and R15Joints or R6Joints
					for i, joint in ipairs(joints) do
						local a = char:FindFirstChild(joint[1])
						local b = char:FindFirstChild(joint[2])
						local line = objs.Skeleton[i]
						if a and b and line then
							local pa, va = Camera:WorldToViewportPoint(a.Position)
							local pb, vb = Camera:WorldToViewportPoint(b.Position)
							if va and vb then
								line.From = Vector2.new(pa.X, pa.Y)
								line.To = Vector2.new(pb.X, pb.Y)
								line.Visible = true
							else line.Visible = false end
						elseif line then line.Visible = false end
					end
					for i = #joints + 1, #objs.Skeleton do objs.Skeleton[i].Visible = false end
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
end)

-- [[ Health Billboard cho San Diego ]]
local function applyHealth(player)
	if player == LocalPlayer then return end
	local function added(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		local hum = char:WaitForChild("Humanoid", 5)
		if not hrp or not hum then return end
		
		local bill = hrp:FindFirstChild("SD_HealthUI") or Instance.new("BillboardGui")
		bill.Name = "SD_HealthUI"
		bill.Adornee = hrp
		bill.Size = UDim2.new(0, 200, 0, 50)
		bill.StudsOffset = Vector3.new(0, 3.5, 0)
		bill.AlwaysOnTop = true
		bill.Enabled = Settings.Health and not isSameTeam(player)
		
		local label = bill:FindFirstChild("TextLabel") or Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(0, 255, 0)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 14
		label.Parent = bill
		bill.Parent = hrp
		
		local function update()
			local show = Settings.Health and not isSameTeam(player)
			bill.Enabled = show
			if show and hum and hum.Health > 0 then
				local hp = math.floor((hum.Health / hum.MaxHealth) * 100)
				label.Text = player.DisplayName .. "\n[" .. math.max(0, hp) .. "%]"
			else
				label.Text = player.DisplayName .. "\n[DEAD]"
			end
		end
		hum.HealthChanged:Connect(update)
		RunService.Heartbeat:Connect(update)
		update()
	end
	if player.Character then task.spawn(added, player.Character) end
	player.CharacterAdded:Connect(added)
end

for _, p in pairs(Players:GetPlayers()) do applyHealth(p) end
Players.PlayerAdded:Connect(applyHealth)

print("[[ SAN DIEGO ESP + AIMBOT ĐÃ TẢI ]]>")
print("[[ Bấm MENU để mở cài đặt ]]")