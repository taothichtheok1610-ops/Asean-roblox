-- MOBILE ESP MENU - REWRITTEN & FIXED FOR DELTA / MOBILE EXECUTORS
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình mặc định
local Settings = {
	ESP = true,
	Skeleton = true,
	Health = true,
}

local CONFIG = {
	HighlightColor = Color3.fromRGB(255, 0, 0),
	SkeletonColor = Color3.fromRGB(0, 255, 255),
	SkeletonThickness = 0.1,
}

local R15_BONES = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local R6_BONES = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
	{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local ESP_Folder = workspace:FindFirstChild("ESP_Storage") or Instance.new("Folder", workspace)
ESP_Folder.Name = "ESP_Storage"

----------------------------------------------------
-- 1. TẠO GIAO DIỆN MOBILE MENU (TỐI ƯU HIỂN THỊ)
----------------------------------------------------
local parentGui = LocalPlayer:FindFirstChild("PlayerGui")
if gethui then
	parentGui = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
	parentGui = CoreGui
end

-- Xóa UI cũ nếu đã tồn tại
if parentGui:FindFirstChild("ESP_MobileMenu") then
	parentGui.ESP_MobileMenu:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_MobileMenu"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = parentGui

-- Nút tròn Đóng/Mở Menu
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleMenuBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- Khung Menu Chính
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 210)
menuFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.ZIndex = 10
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Tiêu đề Menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOBILE ESP MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.ZIndex = 11
titleLabel.Parent = menuFrame

-- Container chứa các nút bấm (Sử dụng UIListLayout)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.ZIndex = 11
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

-- Hàm khởi tạo nút bấm tính năng
local function createOptionButton(name, text, order, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.ZIndex = 12
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local function updateUI(state)
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Bật (Xanh)
			btn.Text = text .. ": ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Tắt (Đỏ)
			btn.Text = text .. ": OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	updateUI(defaultState)

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		updateUI(Settings[name])
		callback(Settings[name])
	end)
end

-- Bật/Ẩn Menu khi chạm nút ESP
toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

----------------------------------------------------
-- 2. TẠO NÚT BẤM VÀ ĐIỀU KHIỂN TÍNH NĂNG
----------------------------------------------------
createOptionButton("ESP", "Highlight ESP", 1, Settings.ESP, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("ESPHighlight") then
			plr.Character.ESPHighlight.Enabled = state
		end
	end
end)

createOptionButton("Skeleton", "Khung Xương", 2, Settings.Skeleton, function(state)
	for _, folder in ipairs(ESP_Folder:GetChildren()) do
		for _, beam in ipairs(folder:GetChildren()) do
			if beam:IsA("Beam") then
				beam.Enabled = state
			end
		end
	end
end)

createOptionButton("Health", "Hiện % Máu", 3, Settings.Health, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Head") then
			local ui = plr.Character.Head:FindFirstChild("HealthUI")
			if ui then
				ui.Enabled = state
			end
		end
	end
end)

----------------------------------------------------
-- 3. XỬ LÝ HIỂN THỊ ESP TRONG GAME
----------------------------------------------------
local function createHealthUI(character)
	local head = character:WaitForChild("Head", 5)
	if not head or head:FindFirstChild("HealthUI") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthUI"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = Settings.Health

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = 14
	textLabel.Text = "HP: 100%"
	textLabel.Parent = billboard

	billboard.Parent = head
	return textLabel
end

local function createSkeleton(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	local boneStructure = (humanoid.RigType == Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
	local folder = Instance.new("Folder")
	folder.Name = "Skeleton_" .. character.Name
	folder.Parent = ESP_Folder

	for _, pair in ipairs(boneStructure) do
		local partA = character:FindFirstChild(pair[1])
		local partB = character:FindFirstChild(pair[2])

		if partA and partB then
			local attA = Instance.new("Attachment", partA)
			local attB = Instance.new("Attachment", partB)

			local beam = Instance.new("Beam")
			beam.Attachment0 = attA
			beam.Attachment1 = attB
			beam.Color = ColorSequence.new(CONFIG.SkeletonColor)
			beam.Width0 = CONFIG.SkeletonThickness
			beam.Width1 = CONFIG.SkeletonThickness
			beam.AlwaysOnTop = true
			beam.FaceCamera = true
			beam.Enabled = Settings.Skeleton
			beam.Parent = folder
		end
	end
end

local function createHighlight(character)
	if character:FindFirstChild("ESPHighlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = character
	highlight.FillColor = CONFIG.HighlightColor
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = Settings.ESP
	highlight.Parent = character
end

local function setupPlayerESP(player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(character)
		task.wait(0.5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not humanoid then return end

		createHighlight(character)
		createSkeleton(character)
		local healthText = createHealthUI(character)

		if healthText then
			local function updateHealth()
				local percent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
				healthText.Text = string.format("%s | %d%%", player.DisplayName, math.max(0, percent))
				
				if percent > 50 then
					healthText.TextColor3 = Color3.fromRGB(0, 255, 0)
				elseif percent > 20 then
					healthText.TextColor3 = Color3.fromRGB(255, 165, 0)
				else
					healthText.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
			end

			humanoid.HealthChanged:Connect(updateHealth)
			updateHealth()
		end
	end

	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Vòng lặp khởi chạy ESP cho toàn bộ Player
for _, player in ipairs(Players:GetPlayers()) do 
	setupPlayerESP(player) 
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(function(player)
	local skelFolder = ESP_Folder:FindFirstChild("Skeleton_" .. player.Name)
	if skelFolder then skelFolder:Destroy() end
end)

-- Nút tròn Đóng/Mở Menu
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleMenuBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- Khung Menu Chính
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 210)
menuFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.ZIndex = 10
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Tiêu đề Menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOBILE ESP MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.ZIndex = 11
titleLabel.Parent = menuFrame

-- Container chứa các nút bấm (Sử dụng UIListLayout)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.ZIndex = 11
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

-- Hàm khởi tạo nút bấm tính năng
local function createOptionButton(name, text, order, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.ZIndex = 12
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local function updateUI(state)
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Bật (Xanh)
			btn.Text = text .. ": ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Tắt (Đỏ)
			btn.Text = text .. ": OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	updateUI(defaultState)

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		updateUI(Settings[name])
		callback(Settings[name])
	end)
end

-- Bật/Ẩn Menu khi chạm nút ESP
toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

----------------------------------------------------
-- 2. TẠO NÚT BẤM VÀ ĐIỀU KHIỂN TÍNH NĂNG
----------------------------------------------------
createOptionButton("ESP", "Highlight ESP", 1, Settings.ESP, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("ESPHighlight") then
			plr.Character.ESPHighlight.Enabled = state
		end
	end
end)

createOptionButton("Skeleton", "Khung Xương", 2, Settings.Skeleton, function(state)
	for _, folder in ipairs(ESP_Folder:GetChildren()) do
		for _, beam in ipairs(folder:GetChildren()) do
			if beam:IsA("Beam") then
				beam.Enabled = state
			end
		end
	end
end)

createOptionButton("Health", "Hiện % Máu", 3, Settings.Health, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Head") then
			local ui = plr.Character.Head:FindFirstChild("HealthUI")
			if ui then
				ui.Enabled = state
			end
		end
	end
end)

----------------------------------------------------
-- 3. XỬ LÝ HIỂN THỊ ESP TRONG GAME
----------------------------------------------------
local function createHealthUI(character)
	local head = character:WaitForChild("Head", 5)
	if not head or head:FindFirstChild("HealthUI") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthUI"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = Settings.Health

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = 14
	textLabel.Text = "HP: 100%"
	textLabel.Parent = billboard

	billboard.Parent = head
	return textLabel
end

local function createSkeleton(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	local boneStructure = (humanoid.RigType == Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
	local folder = Instance.new("Folder")
	folder.Name = "Skeleton_" .. character.Name
	folder.Parent = ESP_Folder

	for _, pair in ipairs(boneStructure) do
		local partA = character:FindFirstChild(pair[1])
		local partB = character:FindFirstChild(pair[2])

		if partA and partB then
			local attA = Instance.new("Attachment", partA)
			local attB = Instance.new("Attachment", partB)

			local beam = Instance.new("Beam")
			beam.Attachment0 = attA
			beam.Attachment1 = attB
			beam.Color = ColorSequence.new(CONFIG.SkeletonColor)
			beam.Width0 = CONFIG.SkeletonThickness
			beam.Width1 = CONFIG.SkeletonThickness
			beam.AlwaysOnTop = true
			beam.FaceCamera = true
			beam.Enabled = Settings.Skeleton
			beam.Parent = folder
		end
	end
end

local function createHighlight(character)
	if character:FindFirstChild("ESPHighlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = character
	highlight.FillColor = CONFIG.HighlightColor
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = Settings.ESP
	highlight.Parent = character
end

local function setupPlayerESP(player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(character)
		task.wait(0.5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not humanoid then return end

		createHighlight(character)
		createSkeleton(character)
		local healthText = createHealthUI(character)

		if healthText then
			local function updateHealth()
				local percent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
				healthText.Text = string.format("%s | %d%%", player.DisplayName, math.max(0, percent))
				
				if percent > 50 then
					healthText.TextColor3 = Color3.fromRGB(0, 255, 0)
				elseif percent > 20 then
					healthText.TextColor3 = Color3.fromRGB(255, 165, 0)
				else
					healthText.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
			end

			humanoid.HealthChanged:Connect(updateHealth)
			updateHealth()
		end
	end

	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Vòng lặp khởi chạy ESP cho toàn bộ Player
for _, player in ipairs(Players:GetPlayers()) do 
	setupPlayerESP(player) 
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(function(player)
	local skelFolder = ESP_Folder:FindFirstChild("Skeleton_" .. player.Name)
	if skelFolder then skelFolder:Destroy() end
end)
----------------------------------------------------
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_MobileMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Nút tròn Đóng/Mở Menu (Dành riêng cho tay bấm Mobile)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleMenuBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0) -- Nằm góc trên bên trái
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0) -- Làm tròn nút
btnCorner.Parent = toggleBtn

-- Khung Menu Chính
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 190)
menuFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false -- Ban đầu ẩn đi
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

-- Tiêu đề Menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOBILE ESP MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = menuFrame

-- Hàm tạo Nút Bật/Tắt các tính năng
local function createOptionButton(name, text, positionY, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.85, 0, 0, 35)
	btn.Position = UDim2.new(0.075, 0, 0, positionY)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Parent = menuFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local function updateUI(state)
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Xanh lá (ON)
			btn.Text = text .. ": ON"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Đỏ (OFF)
			btn.Text = text .. ": OFF"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	updateUI(defaultState)

	btn.MouseButton1Click:Connect(function()
		local newState = not Settings[name]
		Settings[name] = newState
		updateUI(newState)
		callback(newState)
	end)
end

-- Đóng/mở khung Menu khi bấm nút ESP tròn
toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

----------------------------------------------------
-- 2. XỬ LÝ LOGIC ESP & CẬP NHẬT TRẠNG THÁI
----------------------------------------------------
local function createHealthUI(character)
	local head = character:WaitForChild("Head", 5)
	if not head or head:FindFirstChild("HealthUI") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthUI"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = Settings.Health

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = 14
	textLabel.Text = "HP: 100%"
	textLabel.Parent = billboard

	billboard.Parent = head
	return textLabel
end

local function createSkeleton(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	local boneStructure = (humanoid.RigType == Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
	local folder = Instance.new("Folder")
	folder.Name = "Skeleton_" .. character.Name
	folder.Parent = ESP_Folder

	for _, pair in ipairs(boneStructure) do
		local partA = character:FindFirstChild(pair[1])
		local partB = character:FindFirstChild(pair[2])

		if partA and partB then
			local attA = Instance.new("Attachment", partA)
			local attB = Instance.new("Attachment", partB)

			local beam = Instance.new("Beam")
			beam.Attachment0 = attA
			beam.Attachment1 = attB
			beam.Color = ColorSequence.new(CONFIG.SkeletonColor)
			beam.Width0 = CONFIG.SkeletonThickness
			beam.Width1 = CONFIG.SkeletonThickness
			beam.AlwaysOnTop = true
			beam.FaceCamera = true
			beam.Enabled = Settings.Skeleton
			beam.Parent = folder
		end
	end
end

local function createHighlight(character)
	if character:FindFirstChild("ESPHighlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = character
	highlight.FillColor = CONFIG.HighlightColor
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = Settings.ESP
	highlight.Parent = character
end

local function setupPlayerESP(player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(character)
		task.wait(0.5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not humanoid then return end

		createHighlight(character)
		createSkeleton(character)
		local healthText = createHealthUI(character)

		if healthText then
			local function updateHealth()
				local percent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
				healthText.Text = string.format("%s | %d%%", player.DisplayName, math.max(0, percent))
				
				if percent > 50 then
					healthText.TextColor3 = Color3.fromRGB(0, 255, 0)
				elseif percent > 20 then
					healthText.TextColor3 = Color3.fromRGB(255, 165, 0)
				else
					healthText.TextColor3 = Color3.fromRGB(255, 0, 0)
				end
			end

			humanoid.HealthChanged:Connect(updateHealth)
			updateHealth()
		end
	end

	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

----------------------------------------------------
-- 3. ĐIỀU KHIỂN BẬT/TẮT TỪ MENU
----------------------------------------------------
createOptionButton("ESP", "Highlight ESP", 40, Settings.ESP, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("ESPHighlight") then
			plr.Character.ESPHighlight.Enabled = state
		end
	end
end)

createOptionButton("Skeleton", "Khung Xương", 85, Settings.Skeleton, function(state)
	for _, folder in ipairs(ESP_Folder:GetChildren()) do
		for _, beam in ipairs(folder:GetChildren()) do
			if beam:IsA("Beam") then
				beam.Enabled = state
			end
		end
	end
end)

createOptionButton("Health", "Hiện % Máu", 130, Settings.Health, function(state)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Head") then
			local ui = plr.Character.Head:FindFirstChild("HealthUI")
			if ui then
				ui.Enabled = state
			end
		end
	end
end)

-- Khởi chạy cho người chơi
for _, player in ipairs(Players:GetPlayers()) do setupPlayerESP(player) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(function(player)
	local skelFolder = ESP_Folder:FindFirstChild("Skeleton_" .. player.Name)
	if skelFolder then skelFolder:Destroy() end
end)
