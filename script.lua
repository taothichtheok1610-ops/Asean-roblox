local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arsenal Mobile - CSGO Mode", "GrapeTheme")

-- === NÚT BẤM ĐIỀU KHIỂN MENU (QUAN TRỌNG CHO UGPHONE) ===
local OpenBtn = Instance.new("ScreenGui")
local MainBtn = Instance.new("TextButton")
OpenBtn.Name = "ControlGui"
OpenBtn.Parent = game.CoreGui
MainBtn.Parent = OpenBtn
MainBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
MainBtn.Position = UDim2.new(0, 10, 0, 150)
MainBtn.Size = UDim2.new(0, 80, 0, 35)
MainBtn.Text = "Ẩn/Hiện UI"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.Draggable = true

local toggled = true
MainBtn.MouseButton1Click:Connect(function()
    toggled = not toggled
    game:GetService("CoreGui"):FindFirstChild("Arsenal Mobile - CSGO Mode").Enabled = toggled
end)

-- === CẤU HÌNH BIẾN ===
_G.Aimlock = false
_G.SilentAim = false
_G.SpinBot = false
_G.Bhop = false
_G.FOV = 150
_G.SpinSpeed = 50
_G.ESP = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === VÒNG TRÒN FOV ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = true

-- === HÀM TÌM MỤC TIÊU ===
function GetTarget()
    local Closest = nil
    local Dist = _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < Dist then
                        Dist = Mag
                        Closest = v
                    end
                end
            end
        end
    end
    return Closest
end

-- === LOGIC SILENT AIM (METATABLE HOOK) ===
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if not checkcaller() and _G.SilentAim and (k == "Hit" or k == "Target") then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            return (k == "Hit" and T.Character.Head.CFrame or T.Character.Head)
        end
    end
    return oldIndex(self, k)
end)
setreadonly(mt, true)

-- === GIAO DIỆN UI ===
local Main = Window:NewTab("Chiến Đấu")
local Move = Window:NewTab("Di Chuyển")
local Visual = Window:NewTab("Hiển Thị")

-- Tab Chiến Đấu
local CombatSec = Main:NewSection("Aimbot & Silent")
CombatSec:NewToggle("Bật Silent Aim (Đạn đuổi)", "Đạn tự tìm mục tiêu", function(s) _G.SilentAim = s end)
CombatSec:NewToggle("Bật Aimlock (Khóa Cam)", "Tự xoay camera", function(s) _G.Aimlock = s end)
CombatSec:NewSlider("Kích thước FOV", "Độ rộng vòng ngắm", 500, 50, function(s) _G.FOV = s end)

-- Tab Di Chuyển
local MoveSec = Move:NewSection("CS:GO Style")
MoveSec:NewToggle("Bunny Hop (B-Hop)", "Tự động nhảy", function(s) _G.Bhop = s end)
MoveSec:NewToggle("Spin Bot (Xoay nhân vật)", "Xoay như CS:GO", function(s) _G.SpinBot = s end)
MoveSec:NewSlider("Tốc độ xoay", "Chỉnh độ nhanh chậm", 300, 10, function(s) _G.SpinSpeed = s end)

-- Tab Hiển Thị
local VisualSec = Visual:NewSection("Xuyên tường")
VisualSec:NewToggle("Bật ESP", "Hiện highlight đối phương", function(s) _G.ESP = s end)

-- === VÒNG LẶP HỆ THỐNG ===
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Aimlock logic
    if _G.Aimlock then
        local T = GetTarget()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), 0.2)
        end
    end
    
    -- Spin Bot logic
    if _G.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end
end)

-- Bhop logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
    end
end)

-- ESP logic (Tối ưu cho UgPhone)
task.spawn(function()
    while task.wait(0.8) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("Highlight")
                if _G.ESP and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Team ~= LocalPlayer.Team then
                    if not hl then Instance.new("Highlight", p.Character).FillColor = Color3.fromRGB(255, 0, 0) end
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end
end)
