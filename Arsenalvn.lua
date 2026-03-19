-- XÓA RÁC CŨ ĐỂ TRÁNH LAG
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "UgPhone_Final_Fix" then v:Destroy() end
end

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH
_G.FOV_SIZE = 180        -- Tầm quét địch
_G.ZOOM_VAL = 110        -- Độ rộng tầm nhìn
_G.AIM_SMOOTH = 0.2      -- Độ mượt (Càng nhỏ càng chặt, 0.1 là dính như keo)
_G.THIRD_PERSON = Vector3.new(2, 2, 10) -- Độ lệch góc nhìn thứ 3 (Phải, Cao, Sau)

-- === HÀM WALL CHECK (CHỈ KHÓA KHI THẤY ĐỊCH) ===
function IsVisible(TargetPart)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 600, RayParams)
    return Result and Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- === HÀM TÌM MỤC TIÊU ===
function GetTarget()
    local target, dist = nil, _G.FOV_SIZE
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

-- === HỆ THỐNG ESP BOX (BILLBOARD GUI - CHẮC CHẮN HIỆN TRÊN UGPHONE) ===
function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("ESP_Adorn") then
        local bbg = Instance.new("BillboardGui", player.Character)
        bbg.Name = "ESP_Adorn"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(4, 0, 5.5, 0)
        bbg.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        
        local frame = Instance.new("Frame", bbg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.8 -- Khung đỏ mờ
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BorderSizePixel = 2
        
        local line = Instance.new("UIStroke", frame)
        line.Color = Color3.new(1,1,1) -- Viền trắng cho dễ nhìn
        line.Thickness = 1.5
    end
end

-- === VÒNG LẶP HỆ THỐNG ===
RunService.RenderStepped:Connect(function()
    -- 1. GÓC NHÌN THỨ 3 & ZOOM
    Camera.FieldOfView = _G.ZOOM_VAL
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.CameraOffset = _G.THIRD_PERSON
    end

    -- 2. ESP BOX
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            CreateESP(p)
        else
            if p.Character and p.Character:FindFirstChild("ESP_Adorn") then
                p.Character.ESP_Adorn:Destroy()
            end
        end
    end

    -- 3. AIM LOCK (KHÓA CAM SIÊU CHẶT)
    local T = GetTarget()
    if T then 
        -- Khóa camera thẳng vào đầu đối thủ
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), _G.AIM_SMOOTH)
    end

    -- 4. SPIN BOT (GIỮ ĐỂ KHÓ BẮN TRÚNG ĐẦU)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "AIMLOCK + BOX + 3RD PERSON LOADED!",
    Duration = 5
})
