-- [[ MOBILE ALL-IN-ONE SCRIPT ]] --
-- Aimlock (0.65) + ESP Purple + Team Check + Wall Check

local Settings = {
    WalkSpeedBoost = 1.10,
    AimSpeed = 0.65, -- Độ nhạy cũ bạn yêu cầu
    TeamCheck = true,
    WallCheck = true,
    ESPColor = Color3.fromRGB(160, 32, 240) -- Màu tím bản gốc
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tạo thư mục chứa ESP để dễ quản lý
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "DUNU_ESP_Mobile"

-- [[ HÀM TẠO BOX ESP ]] --
local function CreateESP(player)
    local Box = Instance.new("Frame")
    Box.Name = player.Name
    Box.Parent = ESPFolder
    Box.BackgroundColor3 = Settings.ESPColor
    Box.BackgroundTransparency = 0.5 -- Độ trong suốt của khung
    Box.BorderSizePixel = 0
    Box.Visible = false
    Box.Size = UDim2.new(0, 0, 0, 0) -- Khởi tạo size
    
    -- Thêm viền (Stroke) cho Box
    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Settings.ESPColor
    Stroke.Thickness = 1
    Stroke.Transparency = 0
    
    return Box
end

-- [[ HÀM KIỂM TRA TƯỜNG (WALL CHECK) ]] --
local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end
    
    local rayParam = RaycastParams.new()
    -- Bỏ qua bản thân và nhân vật mục tiêu khi check tia
    rayParam.FilterDescendantsInstances = {char, targetPart.Parent, ESPFolder} 
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    
    local raycastResult = workspace:Raycast(char.Head.Position, (targetPart.Position - char.Head.Position).Unit * 1000, rayParam)
    return raycastResult == nil 
end

-- [[ QUẢN LÝ ESP KHI NGƯỜI CHƠI VÀO/RA ]] --
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPFolder:FindFirstChild(player.Name) then
        ESPFolder[player.Name]:Destroy()
    end
end)

-- [[ VÒNG LẶP THỰC THI (MAIN LOOP) ]] --
RunService.RenderStepped:Connect(function()
    -- 1. SPEED HACK
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Settings.WalkSpeedBoost
        end
    end)

    local ClosestTarget = nil
    local MaxDistance = math.huge

    -- 2. TÌM KẺ ĐỊCH GẦN NHẤT & CẬP NHẬT ESP
    for _, player in pairs(Players:GetPlayers()) do
        local Box = ESPFolder:FindFirstChild(player.Name)
        
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra Team
            local isEnemy = not Settings.TeamCheck or (player.Team ~= LocalPlayer.Team)
            local head = player.Character:FindFirstChild("Head")
            
            if isEnemy and head then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local isSeen = onScreen and isVisible(head)

                -- CẬP NHẬT ESP
                if Box then
                    if isSeen then
                        -- Tính toán kích thước Box dựa trên khoảng cách (giống bản gốc)
                        local boxSize = 2200 / headPos.Z
                        Box.Size = UDim2.new(0, boxSize * 0.65, 0, boxSize)
                        Box.Position = UDim2.new(0, headPos.X - (boxSize * 0.325), 0, headPos.Y - (boxSize * 0.5))
                        Box.Visible = true
                    else
                        Box.Visible = false
                    end
                end

                -- TÌM MỤC TIÊU GẦN NHẤT (Để Aimlock)
                if isSeen then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if dist < MaxDistance then
                        MaxDistance = dist
                        ClosestTarget = head
                    end
                end
            elseif Box then
                -- Nếu đồng đội hoặc không có Character, ẩn ESP
                Box.Visible = false
            end
        elseif Box then
            -- Nếu người chơi không tồn tại, ẩn ESP
            Box.Visible = false
        end
    end

    -- 3. KHÓA MỤC TIÊU (AIMLOCK)
    if ClosestTarget then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.AimSpeed)
    end
end)
