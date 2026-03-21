-- [[ ĐỢI GAME TẢI XONG RỒI MỚI CHẠY ]] --
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Cấu hình ngầm (Bật sẵn 100%)
local FOV = 140
local SMOOTH = 0.08
local COLOR = Color3.fromRGB(160, 32, 240)

-- Tạo Folder ẩn trong PlayerGui để lách Anti-Cheat
local UI = Instance.new("ScreenGui")
UI.Name = "RobloxGui_Internal_" .. math.random(100, 999) -- Tên giả hệ thống
UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
UI.ResetOnSpawn = false

local function CreateLine()
    local l = Instance.new("Frame")
    l.BackgroundColor3 = COLOR
    l.BorderSizePixel = 0
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.Visible = false
    l.Parent = UI
    return l
end

local PlayerLines = {}

-- Vòng lặp điều khiển chính
RunService.Heartbeat:Connect(function()
    local target = nil
    local shortest = FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            -- Chỉ hiện địch (Team Check)
            if p.Team ~= LocalPlayer.Team then
                local head = p.Character.Head
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

                -- 1. AIMLOCK
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < shortest then
                        shortest = mag
                        target = head
                    end
                end

                -- 2. ESP LINE (Dùng Frame)
                if hrp then
                    local line = PlayerLines[p] or CreateLine()
                    PlayerLines[p] = line
                    
                    local sPos, visible = Camera:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local start = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        local endP = Vector2.new(sPos.X, sPos.Y)
                        local dist = (endP - start).Magnitude
                        
                        line.Size = UDim2.new(0, 2, 0, dist)
                        line.Position = UDim2.new(0, (start.X + endP.X)/2, 0, (start.Y + endP.Y)/2)
                        line.Rotation = math.deg(math.atan2(endP.Y - start.Y, endP.X - start.X)) - 90
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                end
            else
                if PlayerLines[p] then PlayerLines[p].Visible = false end
            end
        end
    end

    -- Khóa tâm mượt
    if target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), SMOOTH)
    end
end)

warn("DUNU SYSTEM: READY!")
