local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang khởi tạo Hệ thống...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = { Enabled = true, FolderName = "NguyenDZ1620_Config", FileName = "ArsenalSettings" }
})

-- === CẤU HÌNH BIẾN ===
_G.Aimlock = false
_G.SilentAim = false
_G.FOV = 150
_G.ShowFOV = true
_G.TeamCheck = true
_G.Smoothness = 0.5 -- Độ mượt (càng thấp càng mượt)
_G.ESP_Box = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === VẼ VÒNG TRÒN FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- === HÀM TÌM MỤC TIÊU GẦN TÂM NHẤT ===
function GetClosestToCenter()
    local Target = nil
    local MaxDist = _G.FOV
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if (_G.TeamCheck and v.Team ~= LocalPlayer.Team) or not _G.TeamCheck then
                local Pos, OnScreen = Camera:WorldToScreenPoint(v.Character.Head.Position)
                if OnScreen then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
                    if Dist < MaxDist then
                        Target = v
                        MaxDist = Dist
                    end
                end
            end
        end
    end
    return Target
end

-- === LOGIC SILENT AIM (HOOKING) ===
-- Tự động chuyển hướng đạn mà không cần xoay Camera
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, k)
    if not checkcaller() and _G.SilentAim and (k == "Hit" or k == "Target") then
        local Target = GetClosestToCenter()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            return (k == "Hit" and Target.Character.Head.CFrame or Target.Character.Head)
        end
    end
    return oldIndex(self, k)
end)
setreadonly(mt, true)

-- === GIAO DIỆN UI ===
local MainTab = Window:CreateTab("Chiến đấu", 4483345998)
local VisualTab = Window:CreateTab("Hiển thị", 4483345998)

-- TAB CHIẾN ĐẤU
MainTab:CreateSection("--- Chế độ Silent Aim ---")
MainTab:CreateToggle({
   Name = "Bật Silent Aim (Đạn tự trúng)",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

MainTab:CreateSection("--- Chế độ Aimlock ---")
MainTab:CreateToggle({
   Name = "Bật Aimlock (Khóa Camera)",
   CurrentValue = false,
   Callback = function(Value) _G.Aimlock = Value end,
})

MainTab:CreateSlider({
   Name = "Độ mượt Aimlock (Smooth)",
   Min = 0.1, Max = 1, Default = 0.5,
   Callback = function(Value) _G.Smoothness = Value end,
})

MainTab:CreateSection("--- Cài đặt FOV ---")
MainTab:CreateSlider({
   Name = "Kích thước FOV",
   Min = 50, Max = 800, Default = 150,
   Callback = function(Value) _G.FOV = Value end,
})

MainTab:CreateToggle({
   Name = "Hiện vòng tròn FOV",
   CurrentValue = true,
   Callback = function(Value) _G.ShowFOV = Value end,
})

-- TAB HIỂN THỊ
VisualTab:CreateSection("Cài đặt ESP")
VisualTab:CreateToggle({
   Name = "Team Check (Bỏ qua đồng đội)",
   CurrentValue = true,
   Callback = function(Value) _G.TeamCheck = Value end,
})

VisualTab:CreateToggle({
   Name = "Hiện ESP Xuyên tường",
   CurrentValue = false,
   Callback = function(Value) _G.ESP_Box = Value end,
})

-- === VÒNG LẶP XỬ LÝ AIMLOCK ===
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock then
        local T = GetClosestToCenter()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            -- Sử dụng Lerp để xoay camera mượt mà
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), _G.Smoothness)
        end
    end
end)

-- (Phần Logic ESP đã được tối ưu hóa)
task.spawn(function()
    while task.wait(0.5) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isEnemy = (p.Team ~= LocalPlayer.Team)
                if _G.ESP_Box and ((_G.TeamCheck and isEnemy) or not _G.TeamCheck) then
                    if not p.Character:FindFirstChild("NGUYEN_ESP") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "NGUYEN_ESP"
                        hl.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                        hl.FillTransparency = 0.5
                    end
                else
                    if p.Character:FindFirstChild("NGUYEN_ESP") then p.Character.NGUYEN_ESP:Destroy() end
                end
            end
        end
    end
end)

Rayfield:Init()
