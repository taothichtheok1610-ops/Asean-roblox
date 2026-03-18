-- XÓA RÁC CŨ
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "LineHolder" then v:Destroy() end
end

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH
local FOV_SIZE = 150
local AIM_STICKY = 0.5 -- Tâm dính cực chặt
local LINE_COLOR = Color3.fromRGB(255, 0, 0) -- Màu đỏ

-- Tạo Folder chứa Line để dễ quản lý
local Holder = Instance.new("ScreenGui", game.CoreGui)
Holder.Name = "LineHolder"

-- === HÀM WALL CHECK (KIỂM TRA VẬT CẢN) ===
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

-- === HÀM TẠO LINE (DÙNG FRAME THAY CHO DRAWING API) ===
local Lines = {}
function UpdateLine(player, index)
    if not Lines[index] then
        local f = Instance.new("Frame", Holder)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = LINE_COLOR
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        Lines[index] = f
    end
    
    local line = Lines[index]
    local head = player.Character:FindFirstChild("HumanoidRootPart")
    
    if head then
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(head.Position)
        if OnScreen then
            local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local Dest = Vector2.new(ScreenPos.X, ScreenPos.Y)
            local Distance = (Center - Dest).Magnitude
            
            line.Visible = true
            line.Size = UDim2.new(0, Distance, 0, 1.5) -- Độ dày đường kẻ
            line.Position = UDim2.new(0, (Center.X + Dest.X) / 2, 0, (Center.Y + Dest.Y) / 2)
            line.Rotation = math.deg(math.atan2(Dest.Y - Center.Y, Dest.X - Center.X))
        else
            line.Visible = false
        end
    else
        line.Visible = false
    end
end

-- === VÒNG LẶP CHÍNH ===
RunService.RenderStepped:Connect(function()
    local T = GetTarget()
    
    -- 1. Aimlock Siêu Chặt
    if T then 
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), AIM_STICKY) 
    end

    -- 2. ESP Line (Dùng Frame nên chắc chắn hiện)
    local idx = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            UpdateLine(p, idx)
            idx = idx + 1
        end
    end
    
    -- Ẩn các line dư
    for i = idx, #Lines do Lines[i].Visible = false end

    -- 3. Spin Bot
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
end)

print("Script Loaded - No Drawing API Mode")
