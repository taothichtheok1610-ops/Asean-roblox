-- Blue Lock Ball Control Script
-- Script này được dùng trong LocalScript (StarterPlayer > StarterCharacterScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Tìm quả bóng (thay tên theo game của bạn)
local ball = workspace:WaitForChild("Ball") or workspace:FindFirstChild("Ball")

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- ===================== BIẾN CẤU HÌNH =====================
local ballControlEnabled = false
local ballSpeed = 81
local ballMaxSpeed = 200
local originalCameraPos = camera.CFrame
local originalCameraFocus = camera.Focus

-- ===================== TẠO GUI MENU =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BallControlGui"
screenGui.ResetOnSpawn = false
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
controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Đỏ = CONTROL OFF
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
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Xanh = Teleport to Ball
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

-- ===================== CÁC HÀM CHÍNH =====================

-- Hàm bật/tắt điều khiển bóng
local function toggleBallControl()
    ballControlEnabled = not ballControlEnabled
    
    if ballControlEnabled then
        controlButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Xanh = CONTROL ON
        controlButton.Text = "CONTROL ON"
        
        -- Chuyển camera sang góc nhìn bóng
        if ball then
            local ballPos = ball.Position
            camera.CFrame = CFrame.new(ballPos + Vector3.new(0, 2, 5), ballPos)
        end
    else
        controlButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Đỏ = CONTROL OFF
        controlButton.Text = "CONTROL OFF"
        
        -- Quay lại view bình thường
        camera.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 2, 5), humanoidRootPart.Position)
    end
end

-- Hàm tele đến bóng
local function teleportToBall()
    if ball then
        humanoidRootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 3, -5))
        print("Teleported to ball!")
    end
end

-- Hàm điều khiển bóng với phím mũi tên
local function controlBall()
    if not ballControlEnabled or not ball then return end
    
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
        
        -- Áp dụng lực cho bóng
        if ball:FindFirstChild("BodyVelocity") then
            ball.BodyVelocity.Velocity = moveDirection * ballSpeed
        else
            -- Nếu không có BodyVelocity, tạo mới
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = moveDirection * ballSpeed
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Parent = ball
        end
    end
end

-- Hàm cập nhật camera khi điều khiển bóng
local function updateCameraWhileControlling()
    if not ballControlEnabled or not ball then return end
    
    local ballPos = ball.Position
    local cameraOffset = Vector3.new(0, 2, 5)
    camera.CFrame = CFrame.new(ballPos + cameraOffset, ballPos)
end

-- ===================== KẾT NỐI SỰ KIỆN =====================

-- Click nút Control
controlButton.MouseButton1Click:Connect(function()
    toggleBallControl()
end)

-- Click nút Teleport
teleportButton.MouseButton1Click:Connect(function()
    teleportToBall()
end)

-- Cập nhật slider tốc độ
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

-- Lặp chính để điều khiển bóng
RunService.RenderStepped:Connect(function()
    if ballControlEnabled then
        controlBall()
        updateCameraWhileControlling()
    end
end)

-- Xử lý khi nhân vật chết
humanoid.Died:Connect(function()
    screenGui:Destroy()
end)

print("Blue Lock Ball Control Script Loaded!")
