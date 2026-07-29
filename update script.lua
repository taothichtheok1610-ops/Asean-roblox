-- Blue Lock Ball Control v6 - UPGRADE HOÀN TOÀN
-- 📷 Camera theo bóng luôn + Kick bóng gần để control + Tele thẳng
-- 📍 ĐẶT TẠI: StarterPlayer > StarterPlayerScripts

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
    foundBall = nil,
    cameraFollowsBall = false,
    playerNearBall = false,
    kickDistance = 5, -- Khoảng cách tối đa để kick bóng
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
mainFrame.Size = UDim2.new(0, 320, 0, 300)
mainFrame.Position = UDim2.new(0.35, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
mainFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title Frame
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 35)
titleFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 75)
titleFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.85, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.BorderSizePixel = 0
titleLabel.Text = "⚽ Ball Control v6"
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
teleportButton.Text = "🔵 Teleport Ball (Any Distance)"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 14
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
statusLabel.Size = UDim2.new(1, -10, 0, 50)
statusLabel.Position = UDim2.new(0, 5, 0, 170)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
statusLabel.BorderColor3 = Color3.fromRGB(80, 120, 200)
statusLabel.BorderSizePixel = 1
statusLabel.Text = "🔍 Tìm bóng...\n📖 Khi control ON:\n  • Camera sang góc bóng\n  • W/A/S/D = Điều khiển"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = mainFrame

-- Ball Name Label
local ballNameLabel = Instance.new("TextLabel")
ballNameLabel.Name = "BallNameLabel"
ballNameLabel.Size = UDim2.new(1, -10, 0, 20)
ballNameLabel.Position = UDim2.new(0, 5, 0, 228)
ballNameLabel.BackgroundTransparency = 1
ballNameLabel.BorderSizePixel = 0
ballNameLabel.Text = "🎯 Ball: Searching..."
ballNameLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
ballNameLabel.TextSize = 11
ballNameLabel.Font = Enum.Font.Gotham
ballNameLabel.TextXAlignment = Enum.TextXAlignment.Left
ballNameLabel.Parent = mainFrame

-- ===================== HÀM CHỨC NĂNG =====================

local function findBall()
    -- Nếu tìm thấy rồi thì trả về
    if CONFIG.foundBall and CONFIG.foundBall.Parent then
        return CONFIG.foundBall
    end
    
    -- Danh sách tên bóng cần tìm
    local ballNames = {
        "Ball", "ball", "BALL",
        "football", "Football", "FOOTBALL",
        "Soccer", "soccer", "SOCCER",
        "Soccerball", "soccerball",
        "ball_obj", "BallObject",
        "palla", "pelota", "Palla"
    }
    
    -- Tìm theo tên
    for _, name in ipairs(ballNames) do
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            CONFIG.foundBall = ball
            ballNameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            ballNameLabel.Text = "🎯 Ball: " .. name .. " ✓"
            return ball
        end
    end
    
    -- Tìm theo Sphere shape
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
            if part.Parent ~= player.Character then
                CONFIG.foundBall = part
                ballNameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                ballNameLabel.Text = "🎯 Ball: " .. part.Name .. " ✓"
                return part
            end
        end
    end
    
    -- Tìm trong descendants (sâu hơn)
    local function searchDeep(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:IsA("Part") then
                if obj.Shape == Enum.PartType.Ball and obj.Parent ~= player.Character then
                    CONFIG.foundBall = obj
                    ballNameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    ballNameLabel.Text = "🎯 Ball: " .. obj.Name .. " ✓ (found)"
                    return obj
                end
                local found = searchDeep(obj)
                if found then return found end
            end
        end
        return nil
    end
    
    local foundBall = searchDeep(workspace)
    if foundBall then return foundBall end
    
    ballNameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    ballNameLabel.Text = "🎯 Ball: NOT FOUND ✗"
    return nil
end

local function toggleControl()
    CONFIG.ballControlEnabled = not CONFIG.ballControlEnabled
    
    if CONFIG.ballControlEnabled then
        local ball = findBall()
        if not ball then
            controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            controlButton.Text = "⭕ CONTROL OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            statusLabel.Text = "✗ Ball Not Found\n❌ Cannot Enable"
            CONFIG.ballControlEnabled = false
            return
        end
        
        controlButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        controlButton.Text = "🟢 CONTROL ON"
        CONFIG.cameraFollowsBall = true
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "✓ CONTROL ON\n📷 Camera đang theo bóng\n📖 Sử dụng W/A/S/D"
        print("✅ CONTROL ON - Camera theo bóng")
    else
        controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        controlButton.Text = "⭕ CONTROL OFF"
        CONFIG.cameraFollowsBall = false
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "✗ CONTROL OFF\n❌ Ready to Enable"
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
        and UDim2.new(0, 320, 0, 300)
        or UDim2.new(0, 320, 0, 35)
    
    mainFrame:TweenSize(targetSize, "Out", "Quad", 0.2, true)
end

local function teleportToBall()
    local character = player.Character
    if not character then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✗ No Character\n❌ Teleport Failed"
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✗ No HumanoidRootPart\n❌ Teleport Failed"
        return
    end
    
    local ball = findBall()
    if ball then
        -- Tele thẳng vào bóng (không offset quá nhiều)
        local telePos = ball.Position + Vector3.new(0, 2, 0)
        humanoidRootPart.CFrame = CFrame.new(telePos)
        
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        statusLabel.Text = "✓ Teleported!\n🎯 Tại bóng rồi\n⚽ Sẵn sàng đá!"
        print("📍 Teleported to ball directly!")
        
        task.wait(2)
        if CONFIG.ballControlEnabled then
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            statusLabel.Text = "✓ CONTROL ON\n📷 Sẵn sàng điều khiển"
        else
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            statusLabel.Text = "✓ Ready\n📖 Bấm nút Control"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✗ Ball Not Found\n❌ Teleport Failed"
        print("⚠️ Ball not found")
    end
end

local function controlBall()
    if not CONFIG.ballControlEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local ball = findBall()
    if not ball then return end
    
    -- Kiểm tra xem người chơi có gần bóng không
    local distanceToBall = (ball.Position - humanoidRootPart.Position).Magnitude
    CONFIG.playerNearBall = distanceToBall < CONFIG.kickDistance
    
    -- ===== CAMERA THEO BÓN=====
    -- Camera luôn theo bóng khi control ON
    local ballPos = ball.Position
    local cameraOffset = Vector3.new(0, 2.5, 6)
    workspace.CurrentCamera.CFrame = CFrame.new(ballPos + cameraOffset, ballPos)
    
    -- ===== ĐIỀU KHIỂN BÓN=====
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
end

-- ===================== SỰ KIỆN =====================

controlButton.MouseButton1Click:Connect(function()
    toggleControl()
end)

teleportButton.MouseButton1Click:Connect(function()
    teleportToBall()
end)

closeButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

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

-- Tìm bóng liên tục
task.spawn(function()
    while true do
        task.wait(1)
        if not CONFIG.foundBall or not CONFIG.foundBall.Parent then
            findBall()
        end
    end
end)

-- Respawn
player.CharacterAdded:Connect(function()
    CONFIG.ballControlEnabled = false
    CONFIG.cameraFollowsBall = false
    controlButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    controlButton.Text = "⭕ CONTROL OFF"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Text = "✓ Character Loaded\n📖 Bấm Control để bắt đầu"
end)

print("=" .. string.rep("=", 60))
print("⚽ Blue Lock Ball Control v6 - NÂNG CẤP ĐẦY ĐỦ")
print("=" .. string.rep("=", 60))
print("")
print("🎯 CÁC TÍNH NĂNG MỚI:")
print("  1️⃣  📷 Camera tự động theo bóng khi bật Control")
print("  2️⃣  ⚽ Chỉ cần W/A/S/D là điều khiển bóng")
print("  3️⃣  🔵 Teleport thẳng vào bóng dù ở đâu trên sân")
print("")
print("⌨️  PHÍM TẮTSHORTCUT:")
print("  - V = Ẩn/Hiện Menu")
print("  - W/A/S/D = Điều khiển khi Control ON")
print("")
print("🖱️  NÚT BẤM:")
print("  - CONTROL = Bật/Tắt (Camera theo bóng)")
print("  - TELEPORT = Tele thẳng vào bóng")
print("  - X = Ẩn/Hiện menu")
print("  - Slider = Chỉnh tốc độ")
print("")
print("=" .. string.rep("=", 60))

-- Ban đầu tìm bóng
findBall()
