-- Sử dụng thư viện Kavo UI (Nhẹ hơn và ổn định hơn Rayfield trên Delta Mobile)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arsenal Mobile FIX - Delta", "GrapeTheme")

-- CẤU HÌNH
_G.Aimlock = false
_G.ESP = false
_G.FOV = 150
_G.Smoothness = 0.25

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Vòng tròn FOV (Dùng bản vẽ cơ bản)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = true

-- Hàm tìm mục tiêu
function GetTarget()
    local Closest = nil
    local Dist = _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
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
    return Closest
end

-- Tab Chiến Đấu
local Main = Window:NewTab("Chiến Đấu")
local Section = Main:NewSection("Tính năng chính")

Section:NewToggle("Bật Aimlock", "Khóa camera vào đầu", function(state)
    _G.Aimlock = state
end)

Section:NewSlider("Kích thước FOV", "Độ rộng vòng tròn ngắm", 500, 50, function(s)
    _G.FOV = s
end)

-- Tab Hiển Thị
local Visual = Window:NewTab("Hiển Thị")
local VisualSec = Visual:NewSection("ESP")

VisualSec:NewToggle("Bật ESP Xuyên Tường", "Hiện khung người chơi", function(state)
    _G.ESP = state
end)

-- Vòng lặp xử lý (RenderStepped)
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if _G.Aimlock then
        local T = GetTarget()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), _G.Smoothness)
        end
    end
end)

-- Logic ESP nhẹ cho Delta
task.spawn(function()
    while task.wait(0.7) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if _G.ESP and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if not p.Character:FindFirstChild("Highlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    if p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
                end
            end
        end
    end
end)
