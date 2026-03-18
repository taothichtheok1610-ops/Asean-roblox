-- XÓA SẠCH RÁC CŨ ĐỂ KHÔNG BỊ CHỒNG MENU
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "UgPhoneFix" or v.Name == "Arsenal LITE" then v:Destroy() end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ARSENAL MOBILE - UGPHONE", "GrapeTheme")

-- === TẠO VÙNG CHẠM ẨN/HIỆN SIÊU NHẠY ===
local UI_Toggle = Instance.new("ScreenGui", game.CoreGui)
UI_Toggle.Name = "UgPhoneFix"

local ToggleArea = Instance.new("TextButton", UI_Toggle)
ToggleArea.Size = UDim2.new(0, 150, 0, 70) -- Làm vùng chạm thật to ở góc trái
ToggleArea.Position = UDim2.new(0, 0, 0, 0)
ToggleArea.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleArea.BackgroundTransparency = 0.5 -- Cho nó mờ mờ để bạn biết chỗ mà bấm
ToggleArea.Text = "CHẠM ĐỂ ẨN/HIỆN"
ToggleArea.TextColor3 = Color3.new(1,1,1)
ToggleArea.TextSize = 14
ToggleArea.ZIndex = 10000 -- Đảm bảo nó luôn nằm trên cùng

local isOpen = true
ToggleArea.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    game:GetService("CoreGui")["ARSENAL MOBILE - UGPHONE"].Enabled = isOpen
    -- Thay đổi màu để bạn biết đã bấm trúng hay chưa
    ToggleArea.BackgroundColor3 = isOpen and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- === BIẾN CẤU HÌNH ===
_G.Aimlock = false
_G.SilentAim = false
_G.Spin = false
_G.Bhop = false
_G.FOV = 120

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
local Sec = Tab:NewSection("Bật xong rồi bấm nút đỏ để ẩn")

Sec:NewToggle("Silent Aim (Đạn tự đuổi)", "", function(s) _G.SilentAim = s end)
Sec:NewToggle("Aimlock (Khóa Camera)", "", function(s) _G.Aimlock = s end)
Sec:NewToggle("SpinBot (Xoay nhân vật)", "", function(s) _G.Spin = s end)
Sec:NewToggle("Bunny Hop (Tự nhảy)", "", function(s) _G.Bhop = s end)
Sec:NewSlider("Tầm ngắm (FOV)", "", 400, 50, function(s) _G.FOV = s end)

-- === LOGIC HỆ THỐNG ===
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

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Aimlock then
        local T = GetTarget()
        if T then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character.Head.Position), 0.15) end
    end
    if _G.Spin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
    if _G.Bhop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)
