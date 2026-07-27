local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HEIGHT_OFFSET = Vector3.new(0, 3.5, 0) -- Độ cao đứng trên đầu đối phương

-- Hàm tìm kẻ địch gần nhất (loại trừ đồng đội)
local function getNearestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = character.HumanoidRootPart.Position
    local nearestEnemy = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        -- Lọc bỏ bản thân
        if player ~= LocalPlayer then
            -- Kiểm tra khác team (Nếu game không phân team thì bỏ điều kiện Team)
            local isEnemy = true
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                isEnemy = false
            end

            if isEnemy then
                local enemyChar = player.Character
                if enemyChar and enemyChar:FindFirstChild("Head") and enemyChar:FindFirstChildOfClass("Humanoid") then
                    local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
                    
                    -- Chỉ chọn người còn sống
                    if humanoid.Health > 0 then
                        local distance = (enemyChar.Head.Position - myPos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            nearestEnemy = enemyChar
                        end
                    end
                end
            end
        end
    end

    return nearestEnemy
end

-- Hàm thực thi bay/dịch chuyển lên đầu
local function teleportToNearestEnemyHead()
    local targetChar = getNearestEnemy()
    local myChar = LocalPlayer.Character

    if targetChar and myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local targetHead = targetChar:FindFirstChild("Head")
        if targetHead then
            -- Cập nhật CFrame lên trên đầu mục tiêu
            myChar.HumanoidRootPart.CFrame = targetHead.CFrame + HEIGHT_OFFSET
        end
    end
end

-- Gọi hàm này khi cần (Ví dụ bind vào phím bấm hoặc vòng lặp RunService)
-- teleportToNearestEnemyHead()
    Box.Visible = false
    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Settings.ESPColor
    Stroke.Thickness = 1
    return Box
end

-- Vòng lặp chính
RunService.RenderStepped:Connect(function()
    -- Speed
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Settings.WalkSpeedBoost
        end
    end)

    local Target = nil
    local MaxDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        local Box = ESPFolder:FindFirstChild(p.Name) or CreateBox(p)
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isEnemy = not Settings.TeamCheck or (p.Team ~= LocalPlayer.Team)
            local head = p.Character:FindFirstChild("Head")
            
            if isEnemy and head then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local canSee = onScreen and isVisible(head)

                if canSee then
                    local size = 2000 / headPos.Z
                    Box.Size = UDim2.new(0, size * 0.7, 0, size)
                    Box.Position = UDim2.new(0, headPos.X - (size * 0.35), 0, headPos.Y - (size * 0.5))
                    Box.Visible = true
                    
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if dist < MaxDist then
                        MaxDist = dist
                        Target = head
                    end
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
            end
        elseif Box then
            Box.Visible = false
        end
    end

    if Target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), Settings.AimSpeed)
    end
end)
