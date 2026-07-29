-- Blue Lock Ball Control - Clean Script v2
-- 🔒 Không chứa API Keys/Credentials - An toàn để chia sẻ
-- 📍 ĐẶT TẠI: StarterPlayer > StarterPlayerScripts
-- ⌨️ PHÍM: V = Toggle Menu | W/A/S/D = Điều khiển bóng

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ===================== CẤU HÌNH =====================
local CONFIG = {
    ballControlEnabled = false,
    menuVisible = true,
    ballSpeed = 81,
    ballMaxSpeed = 200,
    isMenuDragging = false,
    menuDragStart = Vector2.new(0, 0),
    menuDragOffset = Vector2.new(0, 0),
}

-- ===================== TẠO GUI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallControlGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 240)
mainFrame.Position = UDim2.new(0.35, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title Frame
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 35)
titleFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
titleFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.85, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🎮 Ball Control v2"
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleFrame

-- Nút Close
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -32, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleFrame

-- ===== NÚT ĐIỀU KHIỂN =====

-- Nút Control On/Off
local controlButton = Instance.new("TextButton")
controlButton.Name = "ControlButton"
controlButton.Size = UDim2.new(1, -10, 0, 40)
controlButton.Position = UDim2.new(0, 5, 0, 42)
controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
controlButton.BorderSizePixel = 0
controlButton.Text = "⭕ CONTROL OFF"
controlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
controlButton.TextSize = 15
controlButton.Font = Enum.Font.GothamBold
controlButton.Parent = mainFrame

-- Nút Teleport
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(1, -10, 0, 40)
teleportButton.Position = UDim2.new(0, 5, 0, 87)
teleportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "🔵 Teleport to Ball"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 15
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = mainFrame

-- Label tốc độ
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -10, 0, 18)
speedLabel.Position = UDim2.new(0, 5, 0, 132)
speedLabel.BackgroundTransparency = 1
speedLabel.BorderSizePixel = 0
speedLabel.Text = "⚡ Speed: 81"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- Slider tốc độ
local speedSlider = Instance.new("Frame")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, -10, 0, 12)
speedSlider.Position = UDim2.new(0, 5, 0, 152)
speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
speedSlider.BorderColor3 = Color3.fromRGB(80, 80, 120)
speedSlider.BorderSizePixel = 1
speedSlider.Parent = mainFrame

local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0.4, 0, 1, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = speedSlider

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -10, 0, 30)
statusLabel.Position = UDim2.new(0, 5, 0, 170)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
statusLabel.BorderColor3 = Color3.fromRGB(80, 120, 200)
statusLabel.BorderSizePixel = 1
statusLabel.Text = "✓ Ready\n[Press V to hide]"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = mainFrame

-- ===================== HÀM CHỨC NĂNG =====================

local function findBall()
    -- Tìm bóng với tên thường gặp
    local ballNames = {"Ball", "ball", "football", "Football", "Soccer", "soccer", "Soccerball"}
    
    for _, name in ipairs(ballNames) do
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("Part") then
            return ball
        end
    end
    
    -- Tìm bóng theo Sphere shape
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
            if not part:IsDescendantOf(player.Character) then
                return part
            end
        end
    end
    
    return nil
end

local function toggleControl()
    CONFIG.ballControlEnabled = not CONFIG.ballControlEnabled
    
    if CONFIG.ballControlEnabled then
        controlButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        controlButton.Text = "🟢 CONTROL ON"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "✓ Control Enabled\n[W/A/S/D to move]"
        print("✅ CONTROL ON")
    else
        controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        controlButton.Text = "⭕ CONTROL OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✗ Control Disabled\n[Press to enable]"
        print("❌ CONTROL OFF")
        
        -- Xóa BodyVelocity
        local ball = findBall()
        if ball then
            local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
            if bodyVel then bodyVel:Destroy() end
        end
    end
end

local function toggleMenu()
    CONFIG.menuVisible = not CONFIG.menuVisible
    
    local targetSize = CONFIG.menuVisible 
        and UDim2.new(0, 280, 0, 240)
        or UDim2.new(0, 280, 0, 35)
    
    mainFrame:TweenSize(targetSize, "Out", "Quad", 0.2, true)
end

local function teleportToBall()
    local character = player.Character
    if not character then
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "⚠ No Character Found"
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "⚠ HumanoidRootPart Not Found"
        return
    end
    
    local ball = findBall()
    if ball then
        local safePos = ball.Position + Vector3.new(2, 3, -2)
        humanoidRootPart.CFrame = CFrame.new(safePos)
        
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        statusLabel.Text = "✓ Teleported!\n[Enjoy!]"
        print("📍 Teleported to ball")
        
        task.wait(2)
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "✓ Ready\n[Press V to hide]"
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✗ Ball Not Found"
        print("⚠️ Ball not found")
    end
end

local function controlBall()
    if not CONFIG.ballControlEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local ball = findBall()
    if not ball then return end
    
    local moveDir = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir + Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir + Vector3.new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + Vector3.new(1, 0, 0)
    end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        
        local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.D = 500
            bodyVel.P = 10000
            bodyVel.Parent = ball
        end
        
        bodyVel.Velocity = moveDir * CONFIG.ballSpeed
    else
        local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
        if bodyVel then
            bodyVel.Velocity = bodyVel.Velocity * 0.95
        end
    end
    
    -- Update camera
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local ballPos = ball.Position
        if (ballPos - humanoidRootPart.Position).Magnitude < 150 then
            local camOffset = Vector3.new(0, 2, 5)
            workspace.CurrentCamera.CFrame = CFrame.new(ballPos + camOffset, ballPos)
        end
    end
end

-- ===================== SỰ KIỆN =====================

controlButton.MouseButton1Click:Connect(toggleControl)
teleportButton.MouseButton1Click:Connect(teleportToBall)
closeButton.MouseButton1Click:Connect(toggleMenu)

-- Kéo Menu
titleLabel.MouseButton1Down:Connect(function()
    CONFIG.isMenuDragging = true
    CONFIG.menuDragStart = mouse.Position
    CONFIG.menuDragOffset = mainFrame.Position
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        CONFIG.isMenuDragging = false
    end
end)

-- Chuột di chuyển
mouse.Move:Connect(function()
    if CONFIG.isMenuDragging then
        local delta = mouse.Position - CONFIG.menuDragStart
        mainFrame.Position = CONFIG.menuDragOffset + UDim2.new(0, delta.X, 0, delta.Y)
    end
    
    -- Slider
    if not CONFIG.isMenuDragging and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local isOverSlider = mouse.X >= speedSlider.AbsolutePosition.X and 
                            mouse.X <= speedSlider.AbsolutePosition.X + speedSlider.AbsoluteSize.X and
                            mouse.Y >= speedSlider.AbsolutePosition.Y and 
                            mouse.Y <= speedSlider.AbsolutePosition.Y + speedSlider.AbsoluteSize.Y
        
        if isOverSlider then
            local sliderX = mouse.X - speedSlider.AbsolutePosition.X
            sliderX = math.max(0, math.min(sliderX, speedSlider.AbsoluteSize.X))
            
            local percent = sliderX / speedSlider.AbsoluteSize.X
            CONFIG.ballSpeed = math.max(1, math.floor(percent * CONFIG.ballMaxSpeed))
            
            sliderButton.Size = UDim2.new(percent, 0, 1, 0)
            speedLabel.Text = "⚡ Speed: " .. CONFIG.ballSpeed
        end
    end
end)

-- Toggle Menu - Phím V
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        toggleMenu()
    end
end)

-- Loop chính
RunService.RenderStepped:Connect(controlBall)

-- Respawn
player.CharacterAdded:Connect(function()
    CONFIG.ballControlEnabled = false
    controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    controlButton.Text = "⭕ CONTROL OFF"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Text = "✓ New Character Loaded"
end)

-- ===================== THÔNG TIN =====================
print("=" .. string.rep("=", 50))
print("✅ Blue Lock Ball Control v2 - Clean Script")
print("=" .. string.rep("=", 50))
print("")
print("📖 HƯỚNG DẪN SỬ DỤNG:")
print("  🎮 V = Ẩn/Hiện Menu")
print("  🎮 W/A/S/D = Điều khiển bóng")
print("  🎮 Nhấn CONTROL = Bật/Tắt")
print("  🎮 Nhấn TELEPORT = Tele đến bóng")
print("  🎮 Kéo Slider = Chỉnh tốc độ")
print("  🎮 Kéo Thanh Title = Di chuyển menu")
print("")
print("✨ Script này không chứa API Keys")
print("✨ An toàn để chia sẻ với mọi người")
print("=" .. string.rep("=", 50))
