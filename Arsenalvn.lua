-- [[ DUNU MOBILE ULTIMATE - FIXED FOR DELTA/UGPHONE ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- CẤU HÌNH (Có thể chỉnh sửa)
_G.ENABLED = true
_G.FOV_SIZE = 140 
_G.AIM_SMOOTH = 0.1 -- Giảm xuống để dính hơn trên Mobile
_G.TEAM_CHECK = true

-- SỬ DỤNG PLAYERGUI THAY VÌ COREGUI ĐỂ TRÁNH LỖI DELTA
local ScreenGui = Instance.new("ScreenGui")
local MainBtn = Instance.new("TextButton")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainBtn.Name = "DUNU_FIXED"
MainBtn.Parent = ScreenGui
MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
MainBtn.Size = UDim2.new(0, 100, 0, 40)
MainBtn.Text = "🔮 DUNU: ON"
MainBtn.TextColor3 = Color3.fromRGB(160, 32, 240)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.Active = true
MainBtn.Draggable = true -- Hỗ trợ kéo trên Mobile

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainBtn

UIStroke.Color = Color3.fromRGB(160, 32, 240)
UIStroke.Thickness = 2
UIStroke.Parent = MainBtn

-- Vòng FOV Tím (Sử dụng ImageLabel để mượt hơn trên UGPhone)
local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = ScreenGui
FOVFrame.BackgroundColor3 = Color3.fromRGB(160, 32, 240)
FOVFrame.BackgroundTransparency = 0.9
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, _G.FOV_SIZE * 2, 0, _G.FOV_SIZE * 2)

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

-- Toggle Bật/Tắt
MainBtn.MouseButton1Click:Connect(function()
    _G.ENABLED = not _G.ENABLED
    MainBtn.Text = _G.ENABLED and "🔮 DUNU: ON" or "🔴 DUNU: OFF"
    MainBtn.TextColor3 = _G.ENABLED and Color3.fromRGB(160, 32, 240) or Color3.fromRGB(255, 50, 50)
    UIStroke.Color = MainBtn.TextColor3
    FOVFrame.Visible = _G.ENABLED
end)

-- Hàm tìm mục tiêu (Tối ưu cho Delay của UGPhone)
local function GetClosestTarget()
    local target = nil
    local shortestDist = _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local head = v.Character:FindFirstChild("Head")
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                if not _G.TEAM_CHECK or v.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Vòng lặp chính (Sử dụng Heartbeat thay vì RenderStepped để tránh lag trên UGPhone)
RunService.Heartbeat:Connect(function()
    if not _G.ENABLED then return end
    
    local targetPart = GetClosestTarget()
    if targetPart then
        -- AIM: Lerp nhẹ để bám mục tiêu
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), _G.AIM_SMOOTH)
        
        -- AUTO FIRE: Fix lỗi VirtualUser trên Delta
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
    else
        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end
end)
