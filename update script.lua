-- [[ MOBILE FIX - ALL IN ONE ]] --
local Settings = {
    WalkSpeedBoost = 1.10,
    AimSpeed = 0.65,
    TeamCheck = true,
    WallCheck = true,
    ESPColor = Color3.fromRGB(160, 32, 240)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Chuyển sang PlayerGui để tránh lỗi phân quyền trên Mobile
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MobileESP"
pcall(function()
    ESPFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)

local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent, ESPFolder}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(char.Head.Position, (targetPart.Position - char.Head.Position).Unit * 1000, params)
    return result == nil 
end

local function CreateBox(player)
    local Box = Instance.new("Frame", ESPFolder)
    Box.Name = player.Name
    Box.BackgroundColor3 = Settings.ESPColor
    Box.BackgroundTransparency = 0.6
    Box.BorderSizePixel = 0
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
