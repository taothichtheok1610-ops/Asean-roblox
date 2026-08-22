-- [[ San Diego - Sửa lỗi Camera lệch khỏi hướng súng ]]
-- [[ Đồng bộ hóa CFrame của Camera và HumanoidRootPart ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ CẤU HÌNH ]]
local Enabled = true
local OffsetX = 0    -- Lệch ngang (0 = chuẩn)
local OffsetY = 1.2  -- Lệch dọc (thường để cao hơn đầu 1.2 stud)
local OffsetZ = 0    -- Lệch sâu

-- [[ HÀM ĐỒNG BỘ CAMERA VỚI SÚNG ]]
local function SyncCameraWithGun()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Lấy HumanoidRootPart (định hướng nhân vật)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Lấy Head (để lấy vị trí chính xác)
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Lấy tool đang cầm (súng)
    local tool = character:FindFirstChildOfClass("Tool")
    local gunPart = nil
    if tool then
        -- Tìm Part chính của súng (thường là Handle hoặc Part đầu tiên)
        for _, child in pairs(tool:GetChildren()) do
            if child:IsA("BasePart") then
                gunPart = child
                break
            end
        end
    end
    
    -- Lấy hướng nhìn từ CFrame của RootPart (hoặc súng nếu có)
    local rootCF = rootPart.CFrame
    local lookVector = rootCF.LookVector
    
    -- Nếu có súng, lấy hướng từ súng để chính xác hơn
    if gunPart then
        lookVector = gunPart.CFrame.LookVector
    end
    
    -- Vị trí camera: từ đầu + offset
    local camPos = head.Position + Vector3.new(0, OffsetY, 0)  -- Đặt trên đầu
    
    -- Nếu có súng, lấy vị trí súng làm chuẩn
    if gunPart then
        camPos = gunPart.Position + Vector3.new(OffsetX, OffsetY, OffsetZ)
    end
    
    -- Tạo CFrame mới: vị trí cam, nhìn theo hướng lookVector
    local newCF = CFrame.new(camPos, camPos + lookVector)
    
    -- Áp dụng
    Camera.CFrame = newCF
end

-- [[ VÒNG LẶP CHÍNH ]]
RunService.RenderStepped:Connect(function()
    if Enabled then
        SyncCameraWithGun()
    end
end)

-- [[ ĐIỀU KHIỂN BẰNG PHÍM ]]
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.O then
        Enabled = not Enabled
        print("Cam Sync:", Enabled and "ON" or "OFF")
    end
    
    -- Điều chỉnh offset
    if input.KeyCode == Enum.KeyCode.I then OffsetY = OffsetY + 0.2 print("OffsetY:", OffsetY) end
    if input.KeyCode == Enum.KeyCode.U then OffsetY = OffsetY - 0.2 print("OffsetY:", OffsetY) end
    if input.KeyCode == Enum.KeyCode.P then OffsetX = OffsetX + 0.2 print("OffsetX:", OffsetX) end
    if input.KeyCode == Enum.KeyCode.L then OffsetX = OffsetX - 0.2 print("OffsetX:", OffsetX) end
end)

print("[[ CAMERA SYNC ĐÃ TẢI - Phím O: Bật/Tắt ]]")
print("[[ I/U: Tăng/Giảm chiều cao | P/L: Tăng/Giảm lệch ngang ]]")