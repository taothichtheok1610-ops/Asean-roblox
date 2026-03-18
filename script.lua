-- XÓA RÁC VÀ LINE CŨ
local function Clear()
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "BeamHolder" then v:Destroy() end
    end
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "TargetPart" or v.Name == "Attachment" then v:Destroy() end
    end
end
Clear()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH SIÊU CHIẾN
_G.FOV_SIZE = 200        -- Tầm quét địch
_G.ZOOM_VAL = 120        -- Độ Zoom (Càng cao càng nhìn xa, mặc định 70)
_G.SPIN_SPEED = 40       -- Tốc độ xoay

-- === TẠO HỆ THỐNG BEAM (LINE CHẮC CHẮN HIỆN) ===
local BeamGui = Instance.new("ScreenGui", game.CoreGui)
BeamGui.Name = "BeamHolder"

local function CreateBeam(targetPlayer)
    local part = Instance.new("Part", workspace)
    part.Name = "TargetPart"
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    
    local att0 = Instance.new("Attachment", workspace.Terrain)
    local att1 = Instance.new("Attachment", part)
    
    local beam = Instance.new("Beam", workspace.Terrain)
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.FaceCamera = true
    
    return part, att0, beam
end

-- === HÀM WALL CHECK ===
function IsVisible(TargetPart)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 600, RayParams)
    return Result and Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- === TÌM MỤC TIÊU ===
function GetTarget()
    local target, dist = nil, _G.FOV_SIZE
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if v.Team ~= LocalPlayer.Team then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen and IsVisible(v.Character.Head) then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < dist then dist = Mag target = v end
                end
            end
        end
    end
    return target
end

-- === VÒNG LẶP ĐIỀU KHIỂN ===
local ActiveBeams = {}

RunService.RenderStepped:Connect(function()
    -- 1. ZOOM CAMERA (ROOM CAM)
    Camera.FieldOfView = _G.ZOOM_VAL

    local T = GetTarget()
    
    -- 2. AIMLOCK SIÊU CHẶT (KHÓA THẲNG KHÔNG DÙNG LERP)
    if T then 
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, T.Character.Head.Position)
    end

    -- 3. ESP BEAM LINE
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            if not ActiveBeams[p] then
                local pPart, a0, b = CreateBeam(p)
                ActiveBeams[p] = {part = pPart, att0 = a0, beam = b}
            end
            
            local data = ActiveBeams[p]
            data.part.Position = root.Position
            data.att0.WorldPosition = Camera.CFrame.Position - Vector3.new(0, 2, 0) -- Xuất phát dưới camera một chút
            data.beam.Enabled = true
        else
            if ActiveBeams[p] then
                ActiveBeams[p].beam.Enabled = false
            end
        end
    end

    -- 4. SPIN BOT
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SPIN_SPEED), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "NGUYÊN DZ1620", Text = "ULTRA AIM + BEAM + ZOOM ĐÃ BẬT!", Duration = 5})
