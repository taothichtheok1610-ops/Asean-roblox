-- NGUYÊN DZ1620 - ULTIMATE AIMLOCK (NO SMOOTH)
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH SIÊU CẤP
_G.FOV_SIZE = 300        -- Tầm quét rộng hơn
_G.AIM_PART = "Head"     -- Khóa thẳng vào đầu (có thể đổi thành "HumanoidRootPart")
_G.PREDICTION = 0.165    -- Bù độ trễ mạng (giúp bắn trúng khi địch đang chạy)
_G.ULTIMATE_MODE = true  -- Bật chế độ khóa cứng

-- === HÀM TÌM MỤC TIÊU ===
local function GetTarget()
    local target, dist = nil, _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character then
            local head = v.Character:FindFirstChild(_G.AIM_PART)
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - center).Magnitude
                    if Mag < dist then
                        dist = Mag
                        target = v
                    end
                end
            end
        end
    end
    return target
end

-- === VÒNG LẶP KHÓA MỤC TIÊU ===
RunService.RenderStepped:Connect(function()
    local T = GetTarget()
    
    if T and T.Character and T.Character:FindFirstChild(_G.AIM_PART) then
        local TargetPart = T.Character[_G.AIM_PART]
        
        -- Tính toán vị trí dự đoán dựa trên vận tốc của địch (Prediction)
        local PredictionOffset = TargetPart.Velocity * _G.PREDICTION
        local TargetPos = TargetPart.Position + PredictionOffset
        
        -- KHÓA CỨNG CAMERA (ULTIMATE)
        if _G.ULTIMATE_MODE then
            -- Không dùng Lerp nữa mà gán thẳng CFrame để dính chặt 100%
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
        end
    end
    
    -- SPIN BOT (GIỮ ĐỂ KHÓ BẮN TRÚNG)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "ULTIMATE AIMLOCK ACTIVATED!",
    Duration = 3
})
