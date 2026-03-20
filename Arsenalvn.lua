-- [[ DUNU MOBILE ULTIMATE: AIM + ESP + AUTO FIRE + FOV ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- CẤU HÌNH
_G.ENABLED = true
_G.FOV_SIZE = 130 
_G.TEAM_CHECK = true
local MainColor = Color3.fromRGB(150, 50, 255)

-- === GIAO DIỆN NÚT BẤM DUNU ===
local ScreenGui = Instance.new("ScreenGui")
local MainBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local FOVRing = Instance.new("Frame")
local FOVCorner = Instance.new("UICorner")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Cấu hình Vòng tròn FOV
FOVRing.Name = "DUNU_FOV"
FOVRing.Parent = ScreenGui
FOVRing.BackgroundColor3 = MainColor
FOVRing.BackgroundTransparency = 0.9 -- Rất mờ để không chói mắt
FOVRing.BorderSizePixel = 0
FOVRing.Position = UDim2.new(0.5, -_G.FOV_SIZE, 0.5, -_G.FOV_SIZE)
FOVRing.Size = UDim2.new(0, _G.FOV_SIZE * 2, 0, _G.FOV_SIZE * 2)
FOVRing.ZIndex = 0

FOVCorner.CornerRadius = UDim.new(1, 0) -- Làm cho Frame thành hình tròn
FOVCorner.Parent = FOVRing

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = MainColor
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.5
FOVStroke.Parent = FOVRing

-- Cấu hình Nút DUNU
MainBtn.Name = "DUNU_MOBILE"
MainBtn.Parent = ScreenGui
MainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainBtn.Position = UDim2.new(0.5, -60, 0.5, -22)
MainBtn.Size = UDim2.new(0, 120, 0, 45)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.Text = "🔮 DUNU: ON"
MainBtn.TextColor3 = MainColor
MainBtn.TextSize = 16
MainBtn.Draggable = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainBtn
UIStroke.Color = MainColor
UIStroke.Thickness = 2
UIStroke.Parent = MainBtn

-- Hiệu ứng Intro
task.wait(1)
TweenService:Create(MainBtn, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {Position = UDim2.new(0.05, 0, 0.4, 0)}):Play()

-- === XỬ LÝ BẬT/TẮT ===
MainBtn.MouseButton1Click:Connect(function()
    _G.ENABLED = not _G.ENABLED
    FOVRing.Visible = _G.ENABLED
    if _G.ENABLED then
        MainBtn.Text = "🔮 DUNU: ON"
        MainBtn.TextColor3 = MainColor
    else
        MainBtn.Text = "🔴 DUNU: OFF"
        MainBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("DUNU_ESP") then v.Character.DUNU_ESP:Destroy() end
        end
    end
end)

-- === HÀM ESP (SIÊU NHẸ) ===
local function AddESP(player)
    if player == LocalPlayer then return end
    local function Update()
        if not _G.ENABLED then return end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("DUNU_ESP") then
                local Box = Instance.new("BoxHandleAdornment")
                Box.Name = "DUNU_ESP"
                Box.Parent = player.Character.HumanoidRootPart
                Box.Adornee = player.Character.HumanoidRootPart
                Box.AlwaysOnTop = true
                Box.Size = player.Character:GetExtentsSize()
                Box.Transparency = 0.7
                Box.Color3 = (_G.TEAM_CHECK and player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end
    player.CharacterAdded:Connect(Update)
    task.spawn(function() while task.wait(1) do Update() end end)
end
for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)

-- === VÒNG LẶP AIMBOT & AUTO FIRE ===
RunService.RenderStepped:Connect(function()
    if not _G.ENABLED then return end
    
    local target = nil
    local dist = _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not _G.TEAM_CHECK or v.Team ~= LocalPlayer.Team then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if mag < dist then
                            dist = mag
                            target = v
                        end
                    end
                end
            end
        end
    end

    if target then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
    else
        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end
end)
