local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang khởi tạo Cheat CS:GO Edition...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = { Enabled = true, FolderName = "NguyenDZ1620_Config", FileName = "ArsenalSettings" }
})

-- === BIẾN CẤU HÌNH ===
_G.Aimlock = false
_G.SilentAim = false
_G.SpinBot = false
_G.SpinSpeed = 50
_G.Bhop = false -- Biến mới cho B-Hop
_G.FOV = 150
_G.ShowFOV = true
_G.TeamCheck = true
_G.Smoothness = 0.5
_G.ESP_Box = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === VÒNG TRÒN FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- === LOGIC BUNNY HOP (TỰ NHẢY) ===
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.Bhop then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
    end
end)

-- === LOGIC SPIN BOT ===
task.spawn(function()
    while task.wait() do
        if _G.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
        end
    end
end)

-- === HÀM TÌM MỤC TIÊU ===
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
                    if Dist < MaxDist then Target = v MaxDist = Dist end
                end
            end
        end
    end
    return Target
end

-- === HOOK SILENT AIM (METATABLE) ===
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if not checkcaller() and _G.SilentAim and (k == "Hit" or k == "Target") then
        local T = GetClosestToCenter()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            return (k == "Hit" and T.Character.Head.CFrame or T.Character.Head)
        end
    end
    return oldIndex(self, k)
end)
setreadonly(mt, true)

-- === GIAO DIỆN UI ===
local MainTab = Window:CreateTab("Chiến đấu", 4483345998)
local MovementTab = Window:CreateTab("Di chuyển", 4483345998)
local VisualTab = Window:CreateTab("Hiển thị", 4483345998)

-- TAB CHIẾN ĐẤU
MainTab:CreateSection("--- Ngắm bắn ---")
MainTab:CreateToggle({ Name = "Silent Aim (Đạn đuổi)", CurrentValue = false, Callback = function(V) _G.SilentAim = V end })
MainTab:CreateToggle({ Name = "Aimlock (Khóa Cam)", CurrentValue = false, Callback = function(V) _G.Aimlock = V end })
MainTab:CreateSlider({ Name = "FOV Size", Min = 50, Max = 800, Default = 150, Callback = function(V) _G.FOV = V end })

-- TAB DI CHUYỂN (MOVEMENT)
MovementTab:CreateSection("--- CS:GO Style ---")
MovementTab:CreateToggle({ 
    Name = "Bunny Hop (Tự nhảy liên tục)", 
    CurrentValue = false, 
    Callback = function(V) _G.Bhop = V end 
})
MovementTab:CreateToggle({ 
    Name = "Spin Bot (Xoay tròn)", 
    CurrentValue = false, 
    Callback = function(V) _G.SpinBot = V end 
})
MovementTab:CreateSlider({ Name = "Tốc độ xoay", Min = 10, Max = 300, Default = 50, Callback = function(V) _G.SpinSpeed = V end })

-- TAB HIỂN THỊ
VisualTab:CreateToggle({ Name = "ESP Xuyên tường", CurrentValue = false, Callback = function(V) _G.ESP_Box = V end })
VisualTab:CreateToggle({ Name = "Hiện vòng FOV", CurrentValue = true, Callback = function(V) _G.ShowFOV = V end })

-- === RENDER STEP ===
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock then
        local T = GetClosestToCenter()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), _G.Smoothness)
        end
    end
end)

Rayfield:Init()
