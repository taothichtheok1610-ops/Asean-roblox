-- [[ San Diego - Chỉnh Cam Lệch (Camera Offset) ]]
-- [[ Dùng Delta Mobile, không ảnh hưởng ESP/Aimbot ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ CÀI ĐẶT OFFSET ]]
local OffsetX = 0.5   -- Lệch ngang (0 = giữa, dương = phải, âm = trái)
local OffsetY = 0.3   -- Lệch dọc (0 = giữa, dương = lên, âm = xuống)
local OffsetZ = 0.0   -- Lệch sâu (0 = giữa, dương = ra sau, âm = vào trước)
local Enabled = true  -- Bật/tắt

-- [[ HÀM TÍNH OFFSET ]]
local function GetOffsettedCFrame()
    local character = LocalPlayer.Character
    if not character then return Camera.CFrame end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return Camera.CFrame end
    
    -- Lấy hướng nhìn hiện tại của camera
    local lookVector = Camera.CFrame.LookVector
    local upVector = Camera.CFrame.UpVector
    local rightVector = Camera.CFrame.RightVector
    
    -- Tính vị trí offset
    local offsetPos = Camera.CFrame.Position 
        + (rightVector * OffsetX) 
        + (upVector * OffsetY) 
        + (lookVector * OffsetZ)
    
    -- Trả về CFrame mới với vị trí offset và hướng nhìn giữ nguyên
    return CFrame.new(offsetPos, offsetPos + lookVector)
end

-- [[ VÒNG LẶP CHÍNH ]]
RunService.RenderStepped:Connect(function()
    if Enabled then
        local newCF = GetOffsettedCFrame()
        if newCF then
            Camera.CFrame = newCF
        end
    end
end)

-- [[ ĐIỀU KHIỂN BẰNG PHÍM (TÙY CHỌN) ]]
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Phím O: Bật/tắt
    if input.KeyCode == Enum.KeyCode.O then
        Enabled = not Enabled
        if Enabled then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cam Offset",
                Text = "ĐÃ BẬT",
                Duration = 1
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cam Offset",
                Text = "ĐÃ TẮT",
                Duration = 1
            })
        end
    end
    
    -- Phím I: Tăng offset ngang (sang phải)
    if input.KeyCode == Enum.KeyCode.I then
        OffsetX = OffsetX + 0.1
        print("OffsetX:", OffsetX)
    end
    
    -- Phím U: Giảm offset ngang (sang trái)
    if input.KeyCode == Enum.KeyCode.U then
        OffsetX = OffsetX - 0.1
        print("OffsetX:", OffsetX)
    end
    
    -- Phím P: Tăng offset dọc (lên)
    if input.KeyCode == Enum.KeyCode.P then
        OffsetY = OffsetY + 0.1
        print("OffsetY:", OffsetY)
    end
    
    -- Phím L: Giảm offset dọc (xuống)
    if input.KeyCode == Enum.KeyCode.L then
        OffsetY = OffsetY - 0.1
        print("OffsetY:", OffsetY)
    end
end)

print("[[ CAM LỆCH SAN DIEGO ĐÃ TẢI ]]")
print("[[ O: Bật/tắt | I/U: Lệch ngang | P/L: Lệch dọc ]]")