-- [[ Script Aimbot cho Roblox: San Diego (phiên bản 1.0) ]]
-- [[ Tác giả: palofsc ]]
-- [[ Sử dụng với Synapse X, Krnl, hoặc Script Executor tương thích ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ CẤU HÌNH AIMBOT ]]
local Settings = {
    Enabled = true,              -- Bật/tắt aimbot
    TeamCheck = true,           -- Chỉ aim vào đối thủ khác team
    VisibleCheck = true,        -- Chỉ aim khi mục tiêu có thể nhìn thấy
    FOV = 200,                  -- Phạm vi tìm kiếm (pixels)
    Smoothness = 0.3,           -- Độ mượt (0 = tắt, 0.1-0.5 là tốt)
    AimPart = "Head",           -- Bộ phận nhắm: "Head", "HumanoidRootPart", "Torso"
    Keybind = Enum.KeyCode.RightShift -- Phím bật/tắt (Right Shift)
}

-- [[ BIẾN TOÀN CỤC ]]
local Target = nil
local AimbotEnabled = true
local CurrentTarget = nil
local LastTarget = nil

-- [[ HÀM TÌM MỤC TIÊU TỐT NHẤT ]]
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Settings.FOV
    local character = LocalPlayer.Character
    if not character then return nil end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Kiểm tra team (nếu bật)
            if Settings.TeamCheck then
                local LocalTeam = LocalPlayer.Team
                local TargetTeam = player.Team
                if LocalTeam and TargetTeam and LocalTeam == TargetTeam then
                    continue -- Bỏ qua đồng đội
                end
            end

            local targetChar = player.Character
            if not targetChar then continue end
            local targetPart = targetChar:FindFirstChild(Settings.AimPart)
            if not targetPart then
                targetPart = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetPart then continue end
            end

            -- Kiểm tra tầm nhìn (nếu bật)
            if Settings.VisibleCheck then
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                local hit, position = workspace:FindPartOnRay(ray, character, false, true)
                if hit and hit:IsDescendantOf(targetChar) == false then
                    continue -- Bị chặn bởi vật cản
                end
            end

            -- Chuyển đổi vị trí mục tiêu sang tọa độ màn hình
            local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end

            local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

-- [[ HÀM LÀM MƯỢT MỤC TIÊU ]]
local function SmoothAim(targetPos)
    if not targetPos then return end
    local currentPos = Camera.CFrame.Position
    local direction = (targetPos - currentPos).Unit
    local newCFrame = CFrame.new(currentPos, currentPos + direction)

    -- Làm mượt bằng phép nội suy (Lerp)
    local lerpFactor = Settings.Smoothness
    local currentLookVector = Camera.CFrame.LookVector
    local targetLookVector = newCFrame.LookVector
    local smoothLookVector = currentLookVector:Lerp(targetLookVector, lerpFactor)

    Camera.CFrame = CFrame.new(currentPos, currentPos + smoothLookVector)
end

-- [[ HÀM CHÍNH AIMBOT ]]
local function AimbotLoop()
    if not Settings.Enabled or not AimbotEnabled then
        Target = nil
        return
    end

    local player = GetClosestPlayer()
    if not player then
        Target = nil
        return
    end

    Target = player
    local targetChar = player.Character
    if not targetChar then return end

    local aimPart = targetChar:FindFirstChild(Settings.AimPart)
    if not aimPart then
        aimPart = targetChar:FindFirstChild("HumanoidRootPart")
        if not aimPart then return end
    end

    -- Tự động bắn (nếu muốn, có thể thêm logic)
    -- game:GetService("VirtualUser"):CaptureController()
    -- game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))

    -- Di chuyển chuột đến mục tiêu (nếu không dùng SmoothAim)
    if Settings.Smoothness > 0 then
        SmoothAim(aimPart.Position)
    else
        -- Di chuyển tức thời
        local vector, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if onScreen then
            mousemoverel(vector.X - Mouse.X, vector.Y - Mouse.Y)
        end
    end
end

-- [[ BẮT SỰ KIỆN BÀN PHÍM ĐỂ BẬT/TẮT ]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Keybind then
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            print("[Aimbot] Đã bật")
        else
            print("[Aimbot] Đã tắt")
        end
    end
end)

-- [[ CHẠY VÒNG LẶP CHÍNH ]]
RunService.RenderStepped:Connect(function()
    AimbotLoop()
end)

-- [[ HIỂN THỊ THÔNG BÁO ]]
print("[[ Script Aimbot San Diego đã tải thành công! ]]")
print("[[ Phím bật/tắt: Right Shift ]]")
print("[[ Cấu hình trong Settings ở đầu script ]]")