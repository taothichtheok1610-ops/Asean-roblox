-- XÓA SẠCH RÁC CŨ
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "UgPhoneFix" or v.Name == "ArsenalLITE" then v:Destroy() end
end

-- CẤU HÌNH SIÊU CHẶT
local FOV_SIZE = 150        -- Tầm quét
local SPIN_SPEED = 60       -- Tốc độ xoay CS:GO
local AIM_STICKY = 0.45     -- Độ bám (0.45 là cực chặt, tâm dính như keo)
local WALL_CHECK = true     -- Bật kiểm tra vật cản

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HÀM KIỂM TRA TƯỜNG (WALL CHECK)
function IsVisible(TargetPart)
    if not WALL_CHECK then return true end
    local Ray = Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 500)
    local Hit = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, Camera})
    if Hit and Hit:IsDescendantOf(TargetPart.Parent) then
        return true
    end
    return false
end

-- HÀM TÌM ĐỐI THỦ (ƯU TIÊN GẦN TÂM VÀ LỘ DIỆN)
function GetTarget()
    local target = nil
    local dist = FOV_SIZE
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen and IsVisible(v.Character.Head) then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
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

-- HOOK SILENT AIM (ĐẠN ĐUỔI KHI BẮN)
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

-- VÒNG LẶP HỆ THỐNG
game:GetService("RunService").RenderStepped:Connect(function()
    local T = GetTarget()
    
    -- 1. Aimlock Siêu Chặt
    if T then 
        -- Khóa thẳng Camera vào vị trí đầu đối phương với độ bám cao
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), AIM_STICKY) 
    end
    
    -- 2. SpinBot (Xoay CS:GO Style)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED), 0)
    end
    
    -- 3. Bhop (Tự nhảy)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

-- THÔNG BÁO TRÊN MÀN HÌNH
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "WALL CHECK & ULTRA AIM ĐÃ BẬT!",
    Duration = 5
})
