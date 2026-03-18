-- Xóa sạch các UI cũ để tránh bị đè
if game.CoreGui:FindFirstChild("ControlGui") then game.CoreGui.ControlGui:Destroy() end
if game.CoreGui:FindFirstChild("Arsenal Mobile - CSGO Mode") then game.CoreGui["Arsenal Mobile - CSGO Mode"]:Destroy() end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arsenal Mobile - CSGO Mode", "GrapeTheme")

-- === NÚT BẤM CỐ ĐỊNH (KHÔNG DÙNG KÉO THẢ ĐỂ TRÁNH KẸT) ===
local OpenBtn = Instance.new("ScreenGui")
local MainBtn = Instance.new("TextButton")
local Corner = Instance.new("UICorner")

OpenBtn.Name = "ControlGui"
OpenBtn.Parent = game.CoreGui

MainBtn.Parent = OpenBtn
MainBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
MainBtn.Position = UDim2.new(0, 10, 0, 50) -- Để ở góc trên bên trái
MainBtn.Size = UDim2.new(0, 60, 0, 30)
MainBtn.Text = "MENU"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.TextSize = 12

Corner.Parent = MainBtn

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
_G.FOV = 120
_G.SpinSpeed = 30
_G.ESP = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === VÒNG TRÒN FOV (FIX LỖI TRẮNG MÀN HÌNH) ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false -- QUAN TRỌNG: Không tô màu
FOVCircle.Transparency = 1
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

-- === LOGIC SILENT AIM ===
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

-- === UI TABS ===
local Main = Window:NewTab("Chiến Đấu")
local Move = Window:NewTab("Di Chuyển")

local CombatSec = Main:NewSection("Aimbot")
CombatSec:NewToggle("Silent Aim", "Đạn tự đuổi", function(s) _G.SilentAim = s end)
CombatSec:NewToggle("Aimlock", "Khóa cam", function(s) _G.Aimlock = s end)
CombatSec:NewSlider("FOV", "Vòng ngắm", 400, 50, function(s) _G.FOV = s end)

local MoveSec = Move:NewSection("Movement")
MoveSec:NewToggle("B-Hop", "Tự nhảy", function(s) _G.Bhop = s end)
MoveSec:NewToggle("SpinBot", "Xoay nhân vật", function(s) _G.SpinBot = s end)
MoveSec:NewSlider("Speed Spin", "Tốc độ", 100, 10, function(s) _G.SpinSpeed = s end)

-- === VÒNG LẶP RENDER ===
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if _G.Aimlock then
        local T = GetTarget()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), 0.15)
        end
    end
    
    if _G.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end
end)

-- Bhop
game:GetService("RunService").PreSimulation:Connect(function()
    if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
