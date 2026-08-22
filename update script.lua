-- [[ Script Aimbot cho Delta Mobile - Roblox San Diego ]]
-- [[ Tác giả: palofsc ]]
-- [[ Sử dụng với Delta Executor (Mobile) ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ CẤU HÌNH ]]
local Settings = {
    Enabled = true,
    TeamCheck = true,
    VisibleCheck = false,  -- Tắt kiểm tra tầm nhìn để tránh lỗi trên mobile
    FOV = 300,
    Smoothness = 0.2,
    AimPart = "Head",
    Keybind = 14  -- Mã phím D (14) cho Delta Mobile
}

-- [[ BIẾN ]]
local Target = nil
local AimbotEnabled = true

-- [[ HÀM TÌM MỤC TIÊU (TỐI ƯU CHO MOBILE) ]]
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Settings.FOV
    local character = LocalPlayer.Character
    if not character then return nil end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Bỏ qua đồng đội
            if Settings.TeamCheck then
                local LocalTeam = LocalPlayer.Team
                local TargetTeam = player.Team
                if LocalTeam and TargetTeam and LocalTeam == TargetTeam then
                    continue
                end
            end

            local targetChar = player.Character
            if not targetChar then continue end

            local targetPart = targetChar:FindFirstChild(Settings.AimPart)
            if not targetPart then
                targetPart = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetPart then continue end
            end

            -- Kiểm tra tầm nhìn (CÓ THỂ GÂY LỖI TRÊN MOBILE)
            if Settings.VisibleCheck then
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                local hit = workspace:FindPartOnRay(ray, character, false, true)
                if hit and not hit:IsDescendantOf(targetChar) then
                    continue
                end
            end

            -- Kiểm tra vị trí màn hình
            local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end

            -- Tính khoảng cách (FOV)
            local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
    return closest
end

-- [[ HÀM AIMBOT CHÍNH (KHÔNG DÙNG mousemoverel) ]]
local function AimbotLoop()
    if not Settings.Enabled or not AimbotEnabled then return end

    local player = GetClosestPlayer()
    if not player then return end

    local targetChar = player.Character
    if not targetChar then return end

    local aimPart = targetChar:FindFirstChild(Settings.AimPart)
    if not aimPart then
        aimPart = targetChar:FindFirstChild("HumanoidRootPart")
        if not aimPart then return end
    end

    -- Dùng CFrame để xoay camera (phương pháp duy nhất hoạt động trên Delta Mobile)
    local cameraPos = Camera.CFrame.Position
    local targetPos = aimPart.Position
    local direction = (targetPos - cameraPos).Unit
    local newCFrame = CFrame.new(cameraPos, cameraPos + direction)

    -- Làm mượt (nếu cần)
    if Settings.Smoothness > 0 then
        local currentLook = Camera.CFrame.LookVector
        local targetLook = newCFrame.LookVector
        local smoothLook = currentLook:Lerp(targetLook, Settings.Smoothness)
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothLook)
    else
        Camera.CFrame = newCFrame
    end
end

-- [[ BẮT PHÍM BẬT/TẮT (D - Mã 14) ]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.D then  -- Hoặc dùng Settings.Keybind nếu muốn
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "ĐÃ BẬT",
                Duration = 1
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "ĐÃ TẮT",
                Duration = 1
            })
        end
    end
end)

-- [[ VÒNG LẶP CHÍNH ]]
RunService.RenderStepped:Connect(AimbotLoop)

-- [[ THÔNG BÁO KHỞI ĐỘNG ]]
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Aimbot San Diego",
    Text = "Đã tải! Nhấn D để bật/tắt",
    Duration = 3
})
print("Aimbot San Diego đã tải thành công trên Delta Mobile!")