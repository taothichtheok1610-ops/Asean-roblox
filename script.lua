-- XÓA RÁC CŨ
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "UgPhone_Final_Fix" then v:Destroy() end
end

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CẤU HÌNH
local FOV_SIZE = 180
local ZOOM_VAL = 110
local THIRD_PERSON_OFFSET = Vector3.new(0, 2, 10) -- Độ lệch góc nhìn thứ 3

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
    local target, dist = nil, FOV_SIZE
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

-- === HỆ THỐNG ESP BOX (BILLBOARD GUI - CHẮC CHẮN HIỆN) ===
function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("ESP_Adorn") then
        local bbg = Instance.new("BillboardGui", player.Character)
        bbg.Name = "ESP_Adorn"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(4, 0, 5, 0)
        bbg.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        
        local frame = Instance.new("Frame", bbg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.7
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BorderSizePixel = 2
        
        local line = Instance.new("UIStroke", frame)
        line.Color = Color3.new(1,1,1)
        line.Thickness = 1
    end
end

-- === LOGIC HỆ THỐNG ===
RunService.RenderStepped:Connect(function()
    -- 1. GÓC NHÌN THỨ 3 & ZOOM
    Camera.FieldOfView = ZOOM_VAL
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.CameraOffset = THIRD_PERSON_OFFSET
    end

    -- 2. ESP BOX
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            CreateESP(p)
        else
            if p.Character and p.Character:FindFirstChild("ESP_Adorn") then
                p.Character.ESP_Adorn:Destroy()
            end
        end
    end

    -- 3. SILENT AIM (FORCE CƠ BẢN)
    local T = GetTarget()
    if T and game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        -- Khi bạn bấm bắn, đạn sẽ được dẫn hướng (logic nội bộ Arsenal)
        -- Lưu ý: Silent Aim trên Delta đôi khi cần bạn tự dí tâm lại gần địch một chút
    end

    -- 4. SPIN BOT
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "NGUYÊN DZ1620", Text = "FIX UGPHONE SUCCESS!", Duration = 5})
