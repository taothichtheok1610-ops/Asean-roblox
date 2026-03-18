-- Xóa sạch rác cũ
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "ControlGui" or v.Name == "ArsenalLite" then v:Destroy() end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arsenal LITE - UgPhone", "GrapeTheme")

-- === NÚT MENU SIÊU TO (DỄ BẤM TRÊN MOBILE) ===
local OpenBtn = Instance.new("ScreenGui", game.CoreGui)
OpenBtn.Name = "ControlGui"
local MainBtn = Instance.new("TextButton", OpenBtn)
MainBtn.Size = UDim2.new(0, 100, 0, 50)
MainBtn.Position = UDim2.new(0, 5, 0.4, 0) -- Nằm giữa cạnh trái
MainBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainBtn.Text = "ẨN/HIỆN"
MainBtn.TextColor3 = Color3.new(1,1,1)
MainBtn.ZIndex = 999

local toggled = true
MainBtn.MouseButton1Click:Connect(function()
    toggled = not toggled
    game:GetService("CoreGui")["Arsenal LITE - UgPhone"].Enabled = toggled
end)

-- === TÂM NGẮM THAY THẾ (KHÔNG DÙNG DRAWING ĐỂ TRÁNH TRẮNG MÀN HÌNH) ===
local Crosshair = Instance.new("Frame", OpenBtn)
Crosshair.Size = UDim2.new(0, 4, 0, 4)
Crosshair.Position = UDim2.new(0.5, -2, 0.5, -2)
Crosshair.BackgroundColor3 = Color3.new(1,0,0)
Crosshair.BorderSizePixel = 0

-- === BIẾN CẤU HÌNH ===
_G.Aimlock = false
_G.SilentAim = false
_G.Spin = false
_G.Bhop = false
_G.FOV = 150

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === HÀM TÌM MỤC TIÊU ===
function GetTarget()
    local target = nil
    local dist = _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < dist then dist = Mag target = v end
                end
            end
        end
    end
    return target
end

-- === TAB CHÍNH ===
local Tab = Window:NewTab("HACK")
local Sec = Tab:NewSection("Arsenal Mobile")

Sec:NewToggle("Silent Aim (Đạn đuổi)", "", function(s) _G.SilentAim = s end)
Sec:NewToggle("Aimlock (Khóa Cam)", "", function(s) _G.Aimlock = s end)
Sec:NewToggle("SpinBot (Xoay)", "", function(s) _G.Spin = s end)
Sec:NewToggle("Bhop (Nhảy)", "", function(s) _G.Bhop = s end)
Sec:NewSlider("Chỉnh FOV", "", 400, 50, function(s) _G.FOV = s end)

-- === HOOK SILENT AIM ===
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if _G.SilentAim and (k == "Hit" or k == "Target") then
        local T = GetTarget()
        if T then return (k == "Hit" and T.Character.Head.CFrame or T.Character.Head) end
    end
    return old(self, k)
end)
setreadonly(mt, true)

-- === VÒNG LẶP RENDER ===
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock then
        local T = GetTarget()
        if T then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), 0.1) end
    end
    if _G.Spin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(40), 0)
    end
    if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)
