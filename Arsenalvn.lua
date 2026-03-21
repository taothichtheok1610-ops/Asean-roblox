-- [[ CONFIG CHO ARSENAL ]] --
_G.ENABLED = true
_G.FOV_SIZE = 120 
_G.AIM_SMOOTH = 0.08 -- Càng thấp càng dính tâm
_G.TEAM_CHECK = true 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Tạo UI đơn giản để Test
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 120, 0, 40)
MainBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
MainBtn.Text = "ARSENAL: ON"
MainBtn.BackgroundColor3 = Color3.fromRGB(160, 32, 240)
MainBtn.TextColor3 = Color3.new(1,1,1)

-- Vòng tròn FOV (Dùng để ngắm)
local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.Size = UDim2.new(0, _G.FOV_SIZE * 2, 0, _G.FOV_SIZE * 2)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 0.8
FOVFrame.BackgroundColor3 = Color3.fromRGB(160, 32, 240)
local Corner = Instance.new("UICorner", FOVFrame)
Corner.CornerRadius = UDim.new(1, 0)

MainBtn.MouseButton1Click:Connect(function()
    _G.ENABLED = not _G.ENABLED
    MainBtn.Text = _G.ENABLED and "ARSENAL: ON" or "ARSENAL: OFF"
    FOVFrame.Visible = _G.ENABLED
end)

-- Hàm tìm mục tiêu chuẩn Arsenal
local function GetClosestPlayer()
    local target = nil
    local dist = _G.FOV_SIZE
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            -- Kiểm tra Team trong Arsenal
            if not _G.TEAM_CHECK or v.Team ~= LocalPlayer.Team then
                local head = v.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mouseDist < dist then
                        dist = mouseDist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- Vòng lặp khóa tâm (Dùng RenderStepped cho game bắn súng)
RunService.RenderStepped:Connect(function()
    if _G.ENABLED then
        local target = GetClosestPlayer()
        if target then
            -- Cách khóa tâm mới: Thay đổi hướng nhìn thay vì gán cứng CFrame
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AIM_SMOOTH)
        end
    end
end)
