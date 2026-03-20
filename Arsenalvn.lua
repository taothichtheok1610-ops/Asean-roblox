-- [[ DUNU MOBILE ULTIMATE: FIX DELAY & NO ACTION ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- CẤU HÌNH TỐI ƯU
_G.ENABLED = true
_G.FOV_SIZE = 140 
_G.AIM_SMOOTH = 0.15 -- Độ mượt (Càng nhỏ càng dính, tăng lên nếu muốn tự nhiên)
_G.TEAM_CHECK = true
local MainColor = Color3.fromRGB(160, 32, 240)

-- === GUI DUNU (MÀU TÍM) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainBtn = Instance.new("TextButton")
MainBtn.Name = "DUNU_BTN"
MainBtn.Parent = ScreenGui
MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainBtn.Position = UDim2.new(0.5, -60, 0.5, -22) -- Bắt đầu ở giữa
MainBtn.Size = UDim2.new(0, 110, 0, 40)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.Text = "🔮 DUNU: ON"
MainBtn.TextColor3 = MainColor
MainBtn.TextSize = 14
MainBtn.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = MainColor
UIStroke.Thickness = 2
UIStroke.Parent = MainBtn

-- Vòng FOV Tím
local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = ScreenGui
FOVFrame.BackgroundColor3 = MainColor
FOVFrame.BackgroundTransparency = 0.95
FOVFrame.Position = UDim2.new(0.5, -_G.FOV_SIZE, 0.5, -_G.FOV_SIZE)
FOVFrame.Size = UDim2.new(0, _G.FOV_SIZE * 2, 0, _G.FOV_SIZE * 2)
local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

-- Hiệu ứng Intro
task.wait(0.5)
MainBtn:TweenPosition(UDim2.new(0.05, 0, 0.4, 0), "Out", "Quart", 1.5)

MainBtn.MouseButton1Click:Connect(function()
    _G.ENABLED = not _G.ENABLED
    MainBtn.Text = _G.ENABLED and "🔮 DUNU: ON" or "🔴 DUNU: OFF"
    MainBtn.TextColor3 = _G.ENABLED and MainColor or Color3.fromRGB(255, 50, 50)
    UIStroke.Color = MainBtn.TextColor3
    FOVFrame.Visible = _G.ENABLED
end)

-- === HÀM VẼ TIA ĐẠN (FIX LỖI KHÔNG HIỆN) ===
local function SpawnBeam(startPos, endPos)
    if not _G.ENABLED then return end
    local p = Instance.new("Part")
    p.Name = "DUNU_BEAM"
    p.Parent = workspace
    p.Anchored = true
    p.CanCollide = false
    p.Color = Color3.new(1, 1, 1) -- Tia trắng
    p.Material = Enum.Material.Neon
    p.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
    p.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
    p.Transparency = 0.4
    
    task.delay(0.05, function() p:Destroy() end)
end

-- === HÀM TÌM ĐỊCH TỐI ƯU ===
local function GetClosestTarget()
    local target = nil
    local shortestDist = _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local head = v.Character:FindFirstChild("Head")
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                if not _G.TEAM_CHECK or v.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- === VÒNG LẶP CHÍNH (FIX DELAY) ===
RunService.RenderStepped:Connect(function()
    if not _G.ENABLED then return end
    
    local targetPart = GetClosestTarget()
    
    if targetPart then
        -- AIM: Sử dụng Lerp để bám mục tiêu cực mượt, không bị khựng
        local aimPos = targetPart.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), _G.AIM_SMOOTH)
        
        -- AUTO FIRE: Dùng defer để không làm chậm luồng xử lý Camera
        task.defer(function()
            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
            SpawnBeam(Camera.CFrame.Position - Vector3.new(0,1,0), aimPos)
        end)
    else
        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ESP BOX (FIXED)
RunService.Heartbeat:Connect(function()
    if not _G.ENABLED then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local esp = root:FindFirstChild("DUNU_ESP")
            if not esp then
                esp = Instance.new("BoxHandleAdornment")
                esp.Name = "DUNU_ESP"
                esp.Parent = root
                esp.Adornee = root
                esp.AlwaysOnTop = true
                esp.ZIndex = 5
                esp.Size = p.Character:GetExtentsSize()
                esp.Transparency = 0.7
                esp.Color3 = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            end
        end
    end
end)
