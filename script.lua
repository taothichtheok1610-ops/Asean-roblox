-- XÓA RÁC CŨ ĐỂ TRÁNH LAG
if _G.Lines then 
    for _, v in pairs(_G.Lines) do 
        pcall(function() v:Visible = false v:Remove() end) 
    end 
end
_G.Lines = {}

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH
local FOV_SIZE = 150
local AIM_STICKY = 0.5 -- Độ bám cực chặt
local LINE_COLOR = Color3.fromRGB(255, 0, 0) -- Đường kẻ đỏ

-- === HÀM KIỂM TRA TƯỜNG (WALL CHECK) ===
function IsVisible(TargetPart)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 500, RayParams)
    return Result and Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- === HÀM TÌM MỤC TIÊU ===
function GetTarget()
    local target, dist = nil, FOV_SIZE
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen and IsVisible(v.Character.Head) then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < dist then dist = Mag target = v end
                end
            end
        end
    end
    return target
end

-- === HÀM TẠO ĐƯỜNG KẺ ESP ===
function CreateLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.2
    line.Color = LINE_COLOR
    line.Transparency = 1
    line.Visible = false
    return line
end

-- === VÒNG LẶP HỆ THỐNG (CHẠY MỖI KHUNG HÌNH) ===
RunService.RenderStepped:Connect(function()
    local T = GetTarget()
    
    -- 1. Aimlock Siêu Chặt (Khóa Cam)
    if T then 
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), AIM_STICKY) 
    end

    -- 2. Xử lý ESP Line (Đường kẻ từ tâm đến địch)
    local index = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 and p.Team ~= LocalPlayer.Team then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            
            if OnScreen then
                if not _G.Lines[index] then _G.Lines[index] = CreateLine() end
                local line = _G.Lines[index]
                line.Visible = true
                -- Điểm bắt đầu: Giữa màn hình (Bạn có thể đổi sang dưới cùng nếu muốn)
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                index = index + 1
            end
        end
    end
    
    -- Ẩn các đường kẻ dư thừa khi địch chết hoặc thoát
    for i = index, #_G.Lines do
        if _G.Lines[i] then _G.Lines[i].Visible = false end
    end

    -- 3. SpinBot (Xoay nhân vật liên tục)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
    
    -- ĐÃ XÓA LOGIC JUMP (BUNNY HOP) TẠI ĐÂY
end)

-- THÔNG BÁO TRÊN MÀN HÌNH UGPHONE
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "ĐÃ TẮT BHOP - AIM & LINE ĐANG BẬT",
    Duration = 4
})
