-- XÓA RÁC CŨ
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "UgPhone_Final" then v:Destroy() end
end

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH
local FOV_SIZE = 150        -- Tầm quét đạn đuổi
local ZOOM_VAL = 100        -- Độ rộng tầm nhìn
local THIRD_PERSON_DIST = 12 -- Khoảng cách góc nhìn thứ 3

-- === HÀM WALL CHECK (CHỈ BẮN KHI THẤY ĐỊCH) ===
function IsVisible(TargetPart)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 600, RayParams)
    return Result and Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- === TÌM MỤC TIÊU CHO SILENT AIM ===
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

-- === HOOK SILENT AIM (ĐẠN ĐUỔI - KHÔNG RUNG CAM) ===
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if not checkcaller() and (k == "Hit" or k == "Target") then
        local T = GetTarget()
        if T then 
            return (k == "Hit" and T.Character.Head.CFrame or T.Character.Head) 
        end
    end
    return old(self, k)
end)
setreadonly(mt, true)

-- === VÒNG LẶP HỆ THỐNG ===
RunService.RenderStepped:Connect(function()
    -- 1. GÓC NHÌN THỨ BA (THIRD PERSON)
    LocalPlayer.CameraMaxZoomDistance = THIRD_PERSON_DIST
    LocalPlayer.CameraMinZoomDistance = THIRD_PERSON_DIST
    Camera.FieldOfView = ZOOM_VAL

    -- 2. ESP BOX (HIGHLIGHT - XUYÊN TƯỜNG)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
            if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hl = p.Character:FindFirstChild("ESP_Box")
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "ESP_Box"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.5
                end
            end
        else
            if p.Character and p.Character:FindFirstChild("ESP_Box") then
                p.Character.ESP_Box:Destroy()
            end
        end
    end

    -- 3. SPIN BOT (XOAY)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "SILENT AIM + THIRD PERSON + BOX ĐÃ BẬT!",
    Duration = 5
})
