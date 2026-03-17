local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Arsenal Mobile | NGUYÊN DZ1620",
   LoadingTitle = "Đang khởi tạo cho Mobile...",
   LoadingSubtitle = "by NGUYÊN DZ1620",
   ConfigurationSaving = { Enabled = true, FolderName = "NguyenDZ1620_Config", FileName = "ArsenalSettings" }
})

-- Biến cấu hình
_G.SilentAim = false
_G.FOV = 150
_G.ShowFOV = true
_G.TeamCheck = true

-- Vẽ vòng tròn FOV CỐ ĐỊNH GIỮA MÀN HÌNH (Dành riêng cho Mobile)
local Camera = workspace.CurrentCamera
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- Cập nhật FOV theo tâm màn hình mỗi khung hình
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    -- Lấy tâm màn hình điện thoại
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

local MainTab = Window:CreateTab("Chiến đấu", 4483345998)

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

-- === LOGIC SILENT AIM FIX TÂM MÀN HÌNH ===
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
                    -- Tính khoảng cách từ địch đến TÂM MÀN HÌNH thay vì chuột
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

-- Hook hệ thống (Giữ nguyên phần bẻ tia đạn)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local T = GetClosestToCenter() -- Quét địch ở tâm màn hình
        if T and T.Character and T.Character:FindFirstChild("Head") then
            args[1] = Ray.new(Camera.CFrame.Position, (T.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    return oldNamecall(self, unpack(args))
end)

Rayfield:Init()
