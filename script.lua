local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang tải cấu hình...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NguyenDZ1620_Config",
      FileName = "ArsenalSettings"
   }
})

-- Tạo vòng tròn FOV bằng Drawing API
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- Màu trắng
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- Cập nhật vị trí vòng tròn FOV theo chuột/tâm màn hình
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
end)

-- Tạo các Tab mới cho giao diện
local MainTab = Window:CreateTab("Chiến đấu", 4483345998) -- Icon kiếm
local VisualTab = Window:CreateTab("Hiển thị", 4483345998) -- Icon mắt

-- === SECTION CHIẾN ĐẤU ===
MainTab:CreateSection("Hỗ trợ ngắm")

MainTab:CreateToggle({
   Name = "Bật Silent Aim",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value)
      _G.SilentAim = Value
   end,
})

MainTab:CreateToggle({
   Name = "Hiện vòng tròn FOV",
   CurrentValue = true,
   Flag = "ShowFOVToggle",
   Callback = function(Value)
      _G.ShowFOV = Value
   end,
})

MainTab:CreateSlider({
   Name = "Kích thước FOV",
   Min = 50,
   Max = 500,
   Default = 150,
   Flag = "FOVSlider",
   Callback = function(Value)
      _G.FOV = Value
   end,
})

-- === SECTION HIỂN THỊ ===
VisualTab:CreateSection("Nhìn xuyên thấu")

VisualTab:CreateToggle({
   Name = "Hiện Wallhack (Highlight)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      _G.ESP = Value
   end,
})

-- === LOGIC SCRIPT (Giữ nguyên từ code Legit của bạn) ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function GetClosestToMouse()
    local Target = nil
    local MaxDist = _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= LocalPlayer.Team then
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
    return Target
end

-- Chặn (Hook) tia đạn để hướng vào mục tiêu
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local T = GetClosestToMouse()
        if T and T.Character then
            args[1] = Ray.new(workspace.CurrentCamera.CFrame.Position, (T.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- Vòng lặp cập nhật ESP
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
                    if not p.Character:FindFirstChild("Highlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.6
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
end)

Rayfield:Init()
