-- ====================================================
-- CHỨC NĂNG TELEPORT & FLY TỚI ĐỊCH (BYPASS ANTI-CHEAT)
-- ====================================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hàm tìm kẻ địch gần nhất còn sống
local function GetClosestEnemy()
	local closestTarget = nil
	local shortestDistance = math.huge
	
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
		return nil 
	end
	
	local myPos = LocalPlayer.Character.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			-- Kiểm tra Team (nếu bật TeamCheck)
			local isTeammate = false
			if Settings and Settings.TeamCheck then
				if player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
					isTeammate = true
				end
			end

			if not isTeammate then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")

				if hrp and hum and hum.Health > 0 then
					local dist = (hrp.Position - myPos).Magnitude
					if dist < shortestDistance then
						shortestDistance = dist
						closestTarget = hrp
					end
				end
			end
		end
	end
	return closestTarget
end

-- 1. TELEPORT TỨC THỜI (Sử dụng Noclip + Safe Offset)
local function TeleportToEnemy()
	local targetHRP = GetClosestEnemy()
	if not targetHRP or not LocalPlayer.Character then return end
	
	local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	-- Tắt va chạm tạm thời để không bị kẹt
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end

	-- Dịch chuyển tới đằng sau lưng địch 3 Studs (tránh bị giật do trùng vị trí)
	local targetCFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
	
	-- Reset vận tốc rơi/di chuyển để tránh Anti-cheat kéo lại
	myHRP.AssemblyLinearVelocity = Vector3.zero
	myHRP.AssemblyAngularVelocity = Vector3.zero
	
	myHRP.CFrame = targetCFrame
end

-- 2. FLY / BÁM THEO ĐỊCH LIÊN TỤC (Chạy trong Loop)
table.insert(ScriptConnections, RunService.Heartbeat:Connect(function()
	if Settings and Settings.Fly then
		local targetHRP = GetClosestEnemy()
		if targetHRP and LocalPlayer.Character then
			local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myHRP then
				-- Tắt va chạm
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
				
				-- Bay phía trên đầu địch (Chiều cao tùy chỉnh qua Settings.FlyHeight)
				local height = Settings.FlyHeight or 5
				local flyCFrame = targetHRP.CFrame * CFrame.new(0, height, 2)
				
				-- Triệt tiêu trọng lực để không bị rơi khi đang bay
				myHRP.AssemblyLinearVelocity = Vector3.zero
				myHRP.CFrame = myHRP.CFrame:Lerp(flyCFrame, 0.2)
			end
		end
	end
end))
