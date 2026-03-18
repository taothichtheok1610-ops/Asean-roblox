-- XÓA SẠCH CÁC VÒNG TRÒN TRẮNG LỖI CŨ
if game.CoreGui:FindFirstChild("UgPhoneFix") then game.CoreGui.UgPhoneFix:Destroy() end

-- CẤU HÌNH TỰ ĐỘNG (BẬT SẴN HẾT CHO BẠN)
local FOV_SIZE = 120 -- Độ rộng ngắm bắn
local SPIN_SPEED = 45 -- Tốc độ xoay
local AIM_SMOOTH = 0.15 -- Độ mượt khóa cam

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HIỂN THỊ THÔNG BÁO ĐÃ CHẠY THÀNH CÔNG
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "CHEAT ĐÃ TỰ ĐỘNG BẬT HẾT!",
    Duration = 5
})

-- HÀM TÌM ĐỐI THỦ GẦN NHẤT
function GetTarget()
    local target = nil
    local dist = FOV_SIZE
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < dist then dist = Mag target = v end
                end
            end
        end
    end
    return target
end

-- HOOK SILENT AIM (TỰ ĐỘNG ĐẠN ĐUỔI)
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if (k == "Hit" or k == "Target") then
        local T = GetTarget()
        if T then return (k == "Hit" and T.Character.Head.CFrame or T.Character.Head) end
    end
    return old(self, k)
end)
setreadonly(mt, true)

-- VÒNG LẶP XỬ LÝ (AIMLOCK, SPINBOT, BHOP)
game:GetService("RunService").RenderStepped:Connect(function()
    local T = GetTarget()
    
    -- 1. Tự động khóa Camera (Aimlock)
    if T then 
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), AIM_SMOOTH) 
    end
    
    -- 2. Tự động xoay nhân vật (SpinBot)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED), 0)
    end
    
    -- 3. Tự động nhảy (Bhop)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)
