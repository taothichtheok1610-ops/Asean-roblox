-- Blue Lock Ball Control Script v4 - TOGGLE MENU + FIX ĐẦY ĐỦ
-- 📍 ĐẶT TẠI: StarterPlayer > StarterPlayerScripts
-- ⌨️ PHÍM TOGGLE MENU: V (Bấm V để bật/tắt menu)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ===================== BIẾN CẤU HÌNH =====================
local ballControlEnabled = false
local menuVisible = true
local ballSpeed = 81
local ballMaxSpeed = 200
local isMenuDragging = false
local menuDragStart = Vector2.new(0, 0)
local menuDragOffset = Vector2.new(0, 0)

-- ===================== TẠO GUI MENU =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallControlGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 220)
mainFrame.Position = UDim2.new(0.35, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title (kéo được + Close)
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 30)
titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Ball Control Gui"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleFrame

-- Nút Close
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -27, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleFrame

-- Nút Control
local controlButton = Instance.new("TextButton")
controlButton.Name = "ControlButton"
controlButton.Size = UDim2.new(1, -10, 0, 35)
controlButton.Position = UDim2.new(0, 5, 0, 40)
controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
controlButton.BorderSizePixel = 0
controlButton.Text = "CONTROL OFF"
controlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
controlButton.TextSize = 14
controlButton.Font = Enum.Font.GothamBold
controlButton.Parent = mainFrame

-- Nút Teleport
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(1, -10, 0, 35)
teleportButton.Position = UDim2.new(0, 5, 0, 80)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "Teleport to Ball"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 14
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = mainFrame

-- Label tốc độ
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -10, 0, 15)
speedLabel.Position = UDim2.new(0, 5, 0, 125)
speedLabel.BackgroundTransparency = 1
speedLabel.BorderSizePixel = 0
speedLabel.Text = "Speed: " .. ballSpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Slider tốc độ
local speedSlider = Instance.new("Frame")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, -10, 0, 10)
speedSlider.Position = UDim2.new(0, 5, 0, 145)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSlider.BorderColor3 = Color3.fromRGB(100, 100, 100)
speedSlider.BorderSizePixel = 1
speedSlider.Parent = mainFrame

local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0.4, 0, 1, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = speedSlider

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Ready | Press V to hide"
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

print("✅ Menu đã tạo!")
print("⌨️ PHÍM BẬT/TẮT MENU: V")
print("🎮 Các phím điều khiển: W/A/S/D")

-- ===================== CÁC HÀM CHÍNH =====================

local function getBall()
    local searchNames = {"Ball", "football", "Soccer", "Soccerball", "ball", "BALL"}
    
    for _, name in pairs(searchNames) do
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("Part") then
            return ball
        end
    end
    
    -- Tìm bóng theo Part có Sphere shape
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
            if not part:IsDescendantOf(player.Character) then
                return part
            end
        end
    end
    
    return nil
end

local function toggleBallControl()
    ballControlEnabled = not ballControlEnabled
    
    if ballControlEnabled then
        controlButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        controlButton.Text = "CONTROL ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        statusLabel.Text = "Status: CONTROL ON ✓"
        print("✅ BẬT điều khiển bóng!")
    else
        controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        controlButton.Text = "CONTROL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Status: CONTROL OFF"
        print("❌ TẮT điều khiển bóng!")
        
        -- Xóa BodyVelocity khi tắt
        local ball = getBall()
        if ball then
            local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
            if bodyVel then
                bodyVel:Destroy()
            end
        end
    end
end

local function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 220), "Out", "Quad", 0.3, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 250, 0, 30), "Out", "Quad", 0.3, true)
    end
end

local function teleportToBall()
    local character = player.Character
    if not character then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Status: Teleport Error - No Character"
        print("⚠️ Không tìm thấy character!")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Status: Teleport Error - No HumanoidRootPart"
        print("⚠️ Không tìm thấy HumanoidRootPart!")
        return
    end
    
    local ball = getBall()
    if ball then
        -- Teleport gần bóng an toàn
        local safePos = ball.Position + Vector3.new(2, 3, -2)
        
        -- Kiểm tra vị trí không quá cao/thấp
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoidRootPart.CFrame = CFrame.new(safePos)
            
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            statusLabel.Text = "Status: Teleported! ✓"
            print("📍 Đã tele đến bóng!")
            
            task.wait(2)
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
            statusLabel.Text = "Status: Ready"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Status: Ball Not Found!"
        print("⚠️ Không tìm thấy bóng!")
    end
end

local function controlBall()
    if not ballControlEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = getBall()
    if not ball then return end
    
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
        
        -- Tạo hoặc cập nhật BodyVelocity
        local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.D = 500
            bodyVel.P = 10000
            bodyVel.Parent = ball
        end
        
        bodyVel.Velocity = moveDirection * ballSpeed
    else
        -- Giảm tốc độ khi không bấm phím
        local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
        if bodyVel then
            -- Giảm từ từ thay vì tắt ngay
            bodyVel.Velocity = bodyVel.Velocity * 0.95
        end
    end
    
    -- Update camera
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local ballPos = ball.Position
        local cameraDistance = (ballPos - humanoidRootPart.Position).Magnitude
        
        if cameraDistance < 150 then
            local cameraOffset = Vector3.new(0, 2, 5)
            workspace.CurrentCamera.CFrame = CFrame.new(ballPos + cameraOffset, ballPos)
        end
    end
end

-- ===================== KẾT NỐI SỰ KIỆN =====================

-- Nút Control - bật/tắt điều khiển
controlButton.MouseButton1Click:Connect(function()
    toggleBallControl()
end)

-- Nút Teleport
teleportButton.MouseButton1Click:Connect(function()
    teleportToBall()
end)

-- Nút Close/Hide
closeButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

-- ✨ KÉOTYPI MENU (Dragging Menu)
titleLabel.MouseButton1Down:Connect(function()
    isMenuDragging = true
    menuDragStart = mouse.Position
    menuDragOffset = mainFrame.Position
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMenuDragging = false
    end
end)

mouse.Move:Connect(function()
    -- Kéo menu
    if isMenuDragging then
        local dragDelta = mouse.Position - menuDragStart
        mainFrame.Position = menuDragOffset + UDim2.new(0, dragDelta.X, 0, dragDelta.Y)
    end
    
    -- Kéo slider tốc độ
    if not isMenuDragging and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mouseOverSlider = mouse.X >= speedSlider.AbsolutePosition.X and 
                               mouse.X <= speedSlider.AbsolutePosition.X + speedSlider.AbsoluteSize.X and
                               mouse.Y >= speedSlider.AbsolutePosition.Y and 
                               mouse.Y <= speedSlider.AbsolutePosition.Y + speedSlider.AbsoluteSize.Y
        
        if mouseOverSlider then
            local sliderPos = mouse.X - speedSlider.AbsolutePosition.X
            sliderPos = math.max(0, math.min(sliderPos, speedSlider.AbsoluteSize.X))
            
            local percentage = sliderPos / speedSlider.AbsoluteSize.X
            ballSpeed = math.max(1, math.floor(percentage * ballMaxSpeed))
            
            sliderButton.Size = UDim2.new(percentage, 0, 1, 0)
            speedLabel.Text = "Speed: " .. ballSpeed
        end
    end
end)

-- ⌨️ PHÍM BẬT/TẮT MENU: V
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        toggleMenu()
    end
end)

-- Loop chính - điều khiển bóng
RunService.RenderStepped:Connect(function()
    controlBall()
end)

-- Kiểm tra character
player.CharacterAdded:Connect(function()
    ballControlEnabled = false
    controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    controlButton.Text = "CONTROL OFF"
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    statusLabel.Text = "Status: Character Loaded"
end)

print("🎮 Blue Lock Ball Control v4 Loaded!")
print("=====================================")
print("📖 HƯỚNG DẪN SỬ DỤNG:")
print("  ⌨️  V = Bật/Tắt Menu (Hide/Show)")
print("  🎮 W/A/S/D = Điều khiển bóng")
print("  🔴 CONTROL = Bật/Tắt điều khiển")
print("  🔵 TELEPORT = Tele đến bóng")
print("  📊 SLIDER = Chỉnh tốc độ (0-200)")
print("  🖱️  Kéo thanh title để di chuyển menu")
print("=====================================")
