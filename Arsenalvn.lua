-- NGUYÊN DZ1620 - JJSPLOIT OPTIMIZED (FIX AIM & ESP)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- CẤU HÌNH
_G.FOV_SIZE = 250
_G.AIM_PART = "Head"
_G.TEAM_CHECK = true
_G.ESP_ENABLED = true

-- === HÀM VẼ ESP BOX (DÙNG HIGHLIGHT - SIÊU NHẸ) ===
local function AddESP(player)
    if player == LocalPlayer then return end
    
    local function CreateHighlight()
        if player.Character then
            -- Xóa ESP cũ nếu có
            local old = player.Character:FindFirstChild("NGUYEN_ESP")
            if old then old:Destroy() end
            
            -- Tạo Highlight (Viền Box)
            local highlight = Instance.new("Highlight")
            highlight.Name = "NGUYEN_ESP"
            highlight.Parent = player.Character
            highlight.Adornee = player.Character
            highlight.FillTransparency = 0.5 -- Độ trong suốt của thân
            highlight.OutlineTransparency = 0 -- Độ rõ của viền
            
            -- Màu sắc theo Team
            if _G.TEAM_CHECK and player.Team == LocalPlayer.Team then
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Đồng đội màu Xanh
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Địch màu Đỏ
            end
        end
    end
    
    player.CharacterAdded:Connect(CreateHighlight)
    CreateHighlight()
end

-- Kích hoạt ESP cho tất cả người chơi
for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)

-- === HÀM TÌM ĐỊCH (TỐI ƯU TỐC ĐỘ) ===
local function GetClosestPlayer()
    local target = nil
    local dist = _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(_G.AIM_PART) then
            if not _G.TEAM_CHECK or v.Team ~= LocalPlayer.Team then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
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
    end
    return target
end

-- === VÒNG LẶP KHÓA AIM & TỰ BẮN ===
RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayer()
    
    if target and target.Character and target.Character:FindFirstChild(_G.AIM_PART) then
        -- Khóa mục tiêu không delay
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[_G.AIM_PART].Position)
        
        -- Rao (Auto Click)
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
    else
        -- Nhả chuột khi không có địch
        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

print("NGUYÊN DZ1620: AIM & ESP LOADED!")
