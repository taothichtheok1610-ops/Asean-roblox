-- MOBILE ESP MENU - FIX TRIỆT ĐỂ UI TRỒNG NHAU & KÉO THẢ MENU
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình trạng thái
local Settings = {
	ESP = true,       -- Khung Box 3D
	Health = true,    -- Tên + % Máu
}

----------------------------------------------------
-- 1. DỌN SẠCH TẤT CẢ UI CŨ (TẬN GỐC COREGUI & GETHUI)
----------------------------------------------------
local function cleanOldUI(parent)
	if not parent then return end
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == "Delta_ESP_UI" or child.Name == "ESP_MobileMenu" or child.Name == "ESP_Mobile_Fix" then
			child:Destroy()
		end
	end
end

cleanOldUI(LocalPlayer:FindFirstChild("PlayerGui"))
cleanOldUI(CoreGui)
if gethui then cleanOldUI(gethui()) end

-- Lựa chọn Nơi chứa UI tốt nhất cho Executor
local targetParent = LocalPlayer:WaitForChild("PlayerGui")
if gethui then
	targetParent = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
	targetParent = CoreGui
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Delta_ESP_UI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = targetParent

-- Nút Bật/Tắt Menu tròn
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- Bảng Menu (Đã đẩy ra xa lề trái)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "Menu"
menuFrame.Size = UDim2.new(0, 190, 0, 150)
menuFrame.Position = UDim2.new(0.18, 0, 0.3, 0) -- Vị trí thoáng mát hơn
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.1
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

----------------------------------------------------
-- CHỨC NĂNG KÉO THẢ MENU CHO MOBILE (DRAGGABLE)
----------------------------------------------------
local dragging, dragInput, dragStart, startPos
menuFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = menuFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

menuFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

----------------------------------------------------
-- 2. TẠO CÁC NÚT BẤM VÀ KHUNG TỰ ĐỘNG CĂN
----------------------------------------------------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "DELTA ESP MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = menuFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -40)
container.Position = UDim2.new(0, 10, 0, 35)
container.BackgroundTransparency = 1
container.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = container

local function createToggle(name, text, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
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

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		update()
		callback(Settings[name])
	end)
end

toggleBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

----------------------------------------------------
-- 3. LOGIC ESP 3D & HEALTH UI
----------------------------------------------------
local function applyESP(player)
	if player == LocalPlayer then return end

	local function characterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 10)
		local humanoid = char:WaitForChild("Humanoid", 10)
		if not hrp or not humanoid then return end

		-- Box 3D
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

		humanoid.HealthChanged:Connect(updateHP)
		updateHP()
	end

	if player.Character then
		task.spawn(characterAdded, player.Character)
	end
	player.CharacterAdded:Connect(characterAdded)
end

----------------------------------------------------
-- 4. KÍCH HOẠT
----------------------------------------------------
createToggle("ESP", "Nhìn Xuyên Tường", Settings.ESP, function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local box = p.Character.HumanoidRootPart:FindFirstChild("ESP_Box3D")
			if box then box.Visible = state end
		end
	end
end)

createToggle("Health", "Hiện Tên & % Máu", Settings.Health, function(state)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local ui = p.Character.HumanoidRootPart:FindFirstChild("ESP_HealthUI")
			if ui then ui.Enabled = state end
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	applyESP(player)
end

Players.PlayerAdded:Connect(applyESP)
