local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang khởi tạo hệ thống...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NguyenDZ1620_Config",
      FileName = "ArsenalSettings"
   }
})

-- Biến cấu hình
_G.SilentAim = false
_G.FOV = 150
_G.ShowFOV = true
_G.TeamCheck = true -- Luôn kiểm tra đội để không bắn nhầm đồng đội
_G.ESP_Box = false

-- Vẽ vòng tròn FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
end)

local MainTab = Window:CreateTab("Chiến đấu", 4483345998)
local VisualTab = Window:CreateTab("Hiển thị", 4483345998)

-- === TAB CHIẾN ĐẤU ===
MainTab:CreateSection("Hỗ trợ ngắm")

MainTab:CreateToggle({
   Name = "Bật Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

MainTab:CreateToggle({
   Name = "Kiểm tra Đội (Aim Team Check)",
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

-- === TAB HIỂN THỊ ===
VisualTab:CreateSection("ESP Options")

VisualTab:CreateToggle({
   Name = "Hiện Box (Highlight)",
   CurrentValue = false,
   Callback = function(Value) _G.ESP_Box = Value end,
})

-- === LOGIC SILENT AIM + TEAM CHECK ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function GetClosestToMouse()
    local Target = nil
    local MaxDist = _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            -- Điều kiện Team Check
            if (_G.TeamCheck and v.Team ~= LocalPlayer.Team) or not _G.TeamCheck then
                local Pos, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
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

-- Hook hệ thống bắn của game (Silent Aim)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local T = GetClosestToMouse()
        if T and T.Character then
            -- Bẻ hướng đạn vào đầu kẻ địch
            args[1] = Ray.new(workspace.CurrentCamera.CFrame.Position, (T.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- Vòng lặp Highlight ESP (Dùng cho No Root cực mượt)
task.spawn(function()
    while task.wait(0.5) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if _G.ESP_Box and ((_G.TeamCheck and p.Team ~= LocalPlayer.Team) or not _G.TeamCheck) then
                    if not p.Character:FindFirstChild("NGUYEN_HL") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "NGUYEN_HL"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.FillTransparency = 0.5
                    end
                else
                    if p.Character:FindFirstChild("NGUYEN_HL") then
                        p.Character.NGUYEN_HL:Destroy()
                    end
                end
            end
        end
    end
end)

Rayfield:Init()
Rayfield:Notify({
   Title = "NGUYÊN DZ1620",
   Content = "Đã kích hoạt Aim Team Check!",
   Duration = 3,
})
