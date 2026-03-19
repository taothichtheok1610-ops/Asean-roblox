-- NGUYÊN DZ1620 - JJSPLOIT OPTIMIZED
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CẤU HÌNH CHO JJSPLOIT
_G.FOV_SIZE = 250        -- Tầm quét
_G.AIM_PART = "Head"     -- Khóa vào đầu
_G.AUTO_SHOOT = true     -- Bật tự động bắn
_G.TEAM_CHECK = true     -- Không bắn đồng đội

-- === HÀM TÌM ĐỊCH (TỐI ƯU CHO JJSPLOIT) ===
local function GetClosestPlayer()
    local target = nil
    local dist = _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(_G.AIM_PART) then
            -- Kiểm tra Team
            local isEnemy = not _G.TEAM_CHECK or (v.Team ~= LocalPlayer.Team)
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            
            if isEnemy and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character[_G.AIM_PART].Position)
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
    return target
end

-- === VÒNG LẶP CHÍNH (KHÓA CỨNG CFRAME) ===
RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayer()
    
    if target and target.Character and target.Character:FindFirstChild(_G.AIM_PART) then
        local targetPart = target.Character[_G.AIM_PART]
        
        -- KHÓA CỨNG CAMERA (Cách này JJSploit chạy rất mượt)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)

        -- TỰ ĐỘNG BẮN (Sử dụng Mouse Click ảo)
        if _G.AUTO_SHOOT then
            -- JJSploit hỗ trợ tốt mouse1click hoặc click chuột qua VirtualUser
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.02)
            vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
        end
    end
end)

-- THÔNG BÁO GÓC MÀN HÌNH
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "JJSPLOIT MODE ACTIVATED!",
    Duration = 5
})
