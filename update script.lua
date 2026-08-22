-- Aimbot San Diego - Delta Mobile (không thông báo, không phím tắt)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function GetClosest()
    local nearest = nil
    local minDist = 500
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and c:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(c.Head.Position)
                if vis then
                    local dx = pos.X - Mouse.X
                    local dy = pos.Y - Mouse.Y
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist < minDist then
                        minDist = dist
                        nearest = c
                    end
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    local target = GetClosest()
    if target then
        local head = target:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)