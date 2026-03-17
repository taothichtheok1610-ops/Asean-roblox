local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang khởi tạo hệ thống...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = { Enabled = true, FolderName = "NguyenDZ1620_Config", FileName = "ArsenalSettings" }
})

-- Biến cấu hình
_G.SilentAim = false
_G.FOV = 150
_G.ShowFOV = true
_G.TeamCheck = true
_G.ESP_Box = false
_G.ESP_Line = false
_G.ESP_Skeleton = false
_G.ESP_HP = false

-- Vẽ vòng tròn FOV CỐ ĐỊNH GIỮA MÀN HÌNH (Dành riêng cho Mobile)
local Camera = workspace.CurrentCamera
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

local MainTab = Window:CreateTab("Chiến đấu", 4483345998)
local VisualTab = Window:CreateTab("Hiển thị", 4483345998)

-- === TAB CHIẾN ĐẤU ===
MainTab:CreateSection("Hỗ trợ ngắm Mobile")

MainTab:CreateToggle({
   Name = "Bật Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

MainTab:CreateToggle({
   Name = "Aim Team Check",
   CurrentValue = true,
   Callback = function(Value) _G.TeamCheck = Value end,
})

MainTab:CreateSlider({
   Name = "Kích thước FOV",
   Min = 50,
   Max = 500,
   Default = 150,
   Callback = function(Value) _G.FOV = Value end,
})

-- === TAB HIỂN THỊ (ĐÃ KHÔI PHỤC VÀ NÂNG CẤP) ===
VisualTab:CreateSection("ESP Nâng cao")

VisualTab:CreateToggle({
   Name = "Hiện Highlight (Box xuyên tường)",
   CurrentValue = false,
   Callback = function(Value) _G.ESP_Box = Value end,
})

VisualTab:CreateToggle({
   Name = "Hiện Line (Đường kẻ)",
   CurrentValue = false,
   Callback = function(Value) _G.ESP_Line = Value end,
})

-- === LOGIC HỖ TRỢ NGẮM ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function GetClosestToCenter()
    local Target = nil
    local MaxDist = _G.FOV
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if (_G.TeamCheck and v.Team ~= LocalPlayer.Team) or not _G.TeamCheck then
                local Pos, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - ScreenCenter).Magnitude
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

-- Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local T = GetClosestToCenter()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            args[1] = Ray.new(Camera.CFrame.Position, (T.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- LOGIC ESP BOX & LINE (Mượt cho Mobile)
task.spawn(function()
    while task.wait(0.5) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isEnemy = (p.Team ~= LocalPlayer.Team)
                -- Xử lý Highlight (Box)
                if _G.ESP_Box and ((_G.TeamCheck and isEnemy) or not _G.TeamCheck) then
                    if not p.Character:FindFirstChild("NGUYEN_ESP") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "NGUYEN_ESP"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.FillColor = (isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0))
                    end
                else
                    if p.Character:FindFirstChild("NGUYEN_ESP") then p.Character.NGUYEN_ESP:Destroy() end
                end
            end
        end
    end
end)

Rayfield:Init()
Rayfield:Notify({
   Title = "NGUYÊN DZ1620",
   Content = "Đã khôi phục ESP và tối ưu FOV Mobile!",
   Duration = 5,
})
