-- NGUYÊN DZ1620 - ANTI-ADMIN + FULL OPTION
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

-- CẤU HÌNH
_G.FOV_SIZE = 200
_G.AIM_PART = "Head"
_G.PREDICTION = 0.155
_G.AUTO_SHOOT = true
_G.NO_RECOIL = true
_G.SHOOT_DELAY = 0.03
_G.SPIN_BOT = true
_G.ANTI_ADMIN = true -- BẬT CHẾ ĐỘ CHỐNG ADMIN

local ScriptActive = true

-- === HỆ THỐNG PHÁT HIỆN ADMIN ===
local function CheckForAdmin(player)
    if not _G.ANTI_ADMIN then return end
    
    -- Kiểm tra dựa trên Rank trong Group hoặc ID đặc biệt
    -- Bạn có thể thêm ID của các Admin cụ thể vào đây
    if player:GetRankInGroup(game.CreatorId) >= 200 or player.UserId == game.CreatorId then
        ScriptActive = false
        -- Xóa mọi ESP ngay lập tức
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Asean_ESP" then v:Destroy() end
        end
        -- Thông báo khẩn cấp
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ CẢNH BÁO ADMIN!",
            Text = "Phát hiện Admin: " .. player.Name .. ". Script đã tạm dừng!",
            Duration = 10
        })
    end
end

-- Quét Admin khi có người mới vào
Players.PlayerAdded:Connect(CheckForAdmin)
for _, p in pairs(Players:GetPlayers()) do CheckForAdmin(p) end

-- === HÀM TẠO ESP BOX ===
local function CreateBox(player)
    local function AddESP(char)
        if not char or not ScriptActive then return end
        task.wait(1)
        if char:FindFirstChild("Asean_ESP") then char.Asean_ESP:Destroy() end
        if #Teams:GetTeams() > 1 and player.Team == LocalPlayer.Team then return end
        
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        local bbg = Instance.new("BillboardGui", char)
        bbg.Name = "Asean_ESP"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(4.5, 0, 6, 0)
        bbg.Adornee = root

        local frame = Instance.new("Frame", bbg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 0, 0)
        
        local nameTag = Instance.new("TextLabel", bbg)
        nameTag.Text = player.Name
        nameTag.Size = UDim2.new(1, 0, 0.2, 0)
        nameTag.Position = UDim2.new(0, 0, -0.3, 0)
        nameTag.BackgroundTransparency = 1
        nameTag.TextColor3 = Color3.new(1, 1, 1)
        nameTag.TextStrokeTransparency = 0
    end
    player.CharacterAdded:Connect(AddESP)
    if player.Character then AddESP(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateBox(p) end
end
Players.PlayerAdded:Connect(CreateBox)

-- === VÒNG LẶP CHÍNH ===
local LastShot = 0
RunService.RenderStepped:Connect(function()
    if not ScriptActive then return end -- Dừng mọi thứ nếu phát hiện Admin

    -- 1. No Recoil
    if _G.NO_RECOIL then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("recoil") or v.Name:lower():find("spread")) then
                    v.Value = 0
                end
            end
        end
    end

    -- 2. Aimlock & Auto Shoot
    local target, dist = nil, _G.FOV_SIZE
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        local isEnemy = (#Teams:GetTeams() <= 1) or (v.Team ~= LocalPlayer.Team)
        if v ~= LocalPlayer and isEnemy and v.Character and v.Character:FindFirstChild(_G.AIM_PART) then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character[_G.AIM_PART].Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - center).Magnitude
                    if Mag < dist then dist = Mag target = v end
                end
            end
        end
    end

    if target then
        local head = target.Character[_G.AIM_PART]
        local predPos = head.Position + (head.Velocity * _G.PREDICTION)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predPos)

        if _G.AUTO_SHOOT and (tick() - LastShot) >= _G.SHOOT_DELAY then
            LastShot = tick()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.delay(0.01, function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
        end
    end

    -- 3. Spin Bot
    if _G.SPIN_BOT and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45), 0)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NGUYÊN DZ1620",
    Text = "Hệ thống bảo vệ Admin đã sẵn sàng!",
    Duration = 5
})
