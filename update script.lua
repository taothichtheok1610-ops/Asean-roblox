-- Blue Lock Ball Control Script v2
-- 📍 ĐẶT TẠI: StarterPlayer > StarterPlayerScripts (KHÔNG phải CharacterScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ===================== BIẾN CẤU HÌNH =====================
local ballControlEnabled = false
local ballSpeed = 81
local ballMaxSpeed = 200

-- ===================== TẠO GUI MENU =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallControlGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Ball Control Gui"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

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
speedLabel.Position = UDim2.new(0, 5, 0, 120)
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
speedSlider.Position = UDim2.new(0, 5, 0, 140)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSlider.BorderColor3 = Color3.fromRGB(100, 100, 100)
speedSlider.BorderSizePixel = 1
speedSlider.Parent = mainFrame

local sliderButton = Instance.new("Frame")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 15, 1, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = speedSlider

print("✅ Menu đã tạo! Bạn sẽ thấy nó ở trên cùng màn hình")

-- ===================== CÁC HÀM CHÍNH =====================

local function getBall()
    -- Tìm bóng với nhiều tên khác nhau
    local ball = workspace:FindFirstChild("Ball")
    if ball then return ball end
    
    ball = workspace:FindFirstChild("football")
    if ball then return ball end
    
    ball = workspace:FindFirstChild("Soccer")
    if ball then return ball end
    
    -- Tìm bóng theo Part có Sphere shape
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
            return part
        end
    end
    
    return nil
end

local function toggleBallControl()
    ballControlEnabled = not ballControlEnabled
    
    if ballControlEnabled then
        controlButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        controlButton.Text = "CONTROL ON"
        print("✅ Bật điều khiển bóng!")
    else
        controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        controlButton.Text = "CONTROL OFF"
        print("❌ Tắt điều khiển bóng!")
    end
end

local function teleportToBall()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local ball = getBall()
    if ball then
        humanoidRootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 3, -5))
        print("📍 Đã tele đến bóng!")
    else
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
        
        -- Kiểm tra và tạo BodyVelocity nếu cần
        local bodyVel = ball:FindFirstChildOfClass("BodyVelocity")
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Parent = ball
        end
        
        bodyVel.Velocity = moveDirection * ballSpeed
    end
    
    -- Update camera
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local ballPos = ball.Position
        local cameraOffset = Vector3.new(0, 2, 5)
        workspace.CurrentCamera.CFrame = CFrame.new(ballPos + cameraOffset, ballPos)
    end
end

-- ===================== KẾT NỐI SỰ KIỆN =====================

controlButton.MouseButton1Click:Connect(function()
    toggleBallControl()
end)

teleportButton.MouseButton1Click:Connect(function()
    teleportToBall()
end)

-- Slider
local sliderDragging = false

sliderButton.MouseButton1Down:Connect(function()
    sliderDragging = true
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

mouse.Move:Connect(function()
    if sliderDragging then
        local sliderPos = mouse.X - speedSlider.AbsolutePosition.X
        sliderPos = math.max(0, math.min(sliderPos, speedSlider.AbsoluteSize.X))
        
        local percentage = sliderPos / speedSlider.AbsoluteSize.X
        ballSpeed = math.floor(percentage * ballMaxSpeed)
        
        sliderButton.Size = UDim2.new(percentage, 0, 1, 0)
        speedLabel.Text = "Speed: " .. ballSpeed
    end
end)

-- Loop chính
RunService.RenderStepped:Connect(function()
    controlBall()
end)

print("🎮 Blue Lock Ball Control v2 Loaded!")
