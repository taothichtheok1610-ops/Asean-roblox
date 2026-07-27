-- MOBILE ESP MENU (FIX DÀNH RIÊNG CHO DELTA X / MOBILE EXECUTORS)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Trạng thái bật/tắt
local Settings = {
	ESP = true,
	Box = true,
	Health = true,
	Skeleton = true,
}

----------------------------------------------------
-- 1. TẠO GIAO DIỆN MENU MOBILE
----------------------------------------------------
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Xóa UI cũ nếu có
if playerGui:FindFirstChild("ESP_Mobile_Fix") then
	playerGui.ESP_Mobile_Fix:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_Mobile_Fix"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

-- Nút tròn Bật/Tắt Menu
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Active = true
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- Khung Menu
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0, 180, 0, 230)
menuFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DELTA ESP MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.Parent = menuFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

local function createOptionButton(key, text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local function updateUI()
		if Settings[key] then
			btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			btn.Text = text .. ": ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
			btn.Text = text .. ": OFF"
		end
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	updateUI()

	btn.MouseButton1Click:Connect(function()
		Settings[key] = not Settings[key]
		updateUI()
	end)
end

createOptionButton("ESP", "Nhìn Xuyên Tường")
createOptionButton("Box", "Hiện Khung (Box)")
createOptionButton("Health", "Hiện % Máu")

toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

----------------------------------------------------
-- 2. XỬ LÝ LOGIC HIGHLIGHT (ESP XUYÊN TƯỜNG)
----------------------------------------------------
local function applyHighlight(character)
	local highlight = character:FindFirstChild("DeltaHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "DeltaHighlight"
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end
	highlight.Enabled = Settings.ESP
end

----------------------------------------------------
-- 3. XỬ LÝ QUÉT & HIỂN THỊ CHI TIẾT (RENDER LOOP)
----------------------------------------------------
local drawFolder = Instance.new("Folder")
drawFolder.Name = "ESPDrawings"
drawFolder.Parent = screenGui

local function getPlayerDrawings(player)
	local name = player.Name
	local box = drawFolder:FindFirstChild(name .. "_Box")
	local text = drawFolder:FindFirstChild(name .. "_Text")

	if not box then
		box = Instance.new("Frame")
		box.Name = name .. "_Box"
		box.BackgroundTransparency = 1
		box.BorderSizePixel = 2
		box.BorderColor3 = Color3.fromRGB(0, 255, 255)
		box.Parent = drawFolder
	end

	if not text then
		text = Instance.new("TextLabel")
		text.Name = name .. "_Text"
		text.BackgroundTransparency = 1
		text.TextColor3 = Color3.fromRGB(0, 255, 0)
		text.TextStrokeTransparency = 0
		text.Font = Enum.Font.SourceSansBold
		text.TextSize = 12
		text.Parent = drawFolder
	end

	return box, text
end

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChild("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				-- Áp dụng Highlight ESP
				applyHighlight(char)

				-- Lấy vị trí 3D ra Màn hình 2D
				local position, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				local box, text = getPlayerDrawings(player)

				if onScreen then
					-- Tính toán kích thước Box theo khoảng cách
					local head = char:FindFirstChild("Head")
					local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or position
					local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

					local height = math.abs(headPos.Y - legPos.Y)
					local width = height / 1.8

					-- Vẽ Box ESP
					if Settings.Box then
						box.Size = UDim2.new(0, width, 0, height)
						box.Position = UDim2.new(0, position.X - width / 2, 0, position.Y - height / 2)
						box.Visible = true
					else
						box.Visible = false
					end

					-- Vẽ % Máu
					if Settings.Health then
						local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
						text.Text = string.format("%s [%d%%]", player.DisplayName, hpPercent)
						text.Position = UDim2.new(0, position.X - 50, 0, position.Y - (height / 2) - 15)
						text.Size = UDim2.new(0, 100, 0, 15)
						text.Visible = true
					else
						text.Visible = false
					end
				else
					box.Visible = false
					text.Visible = false
				end
			else
				local box = drawFolder:FindFirstChild(player.Name .. "_Box")
				local text = drawFolder:FindFirstChild(player.Name .. "_Text")
				if box then box.Visible = false end
				if text then text.Visible = false end
			end
		end
	end
end)

-- Tự dọn dẹp khi người chơi thoát
Players.PlayerRemoving:Connect(function(player)
	local box = drawFolder:FindFirstChild(player.Name .. "_Box")
	local text = drawFolder:FindFirstChild(player.Name .. "_Text")
	if box then box:Destroy() end
	if text then text:Destroy() end
end)
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
