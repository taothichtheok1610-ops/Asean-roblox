-- [[ DUNU PROTECT - VIRTUAL ENCRYPTION LAYER ]] --
local _0xEE = {
    ["\87\97\108\107\83\112\101\101\100"] = 1.10, -- WalkSpeed (10%)
    ["\65\105\109\83\112\101\101\100"] = 0.65, -- AimSpeed
    ["\67\111\108\111\114"] = Color3.fromRGB(160, 32, 240)
}

local function _0xG(s) 
    local r = ""
    for i=1,#s do r = r .. string.char(string.byte(s,i)) end
    return r
end

local _0xS = {
    P = game:GetService(_0xG("\80\108\97\121\101\114\115")),
    R = game:GetService(_0xG("\82\117\110\83\101\114\118\105\99\101")),
    V = game:GetService(_0xG("\86\105\114\116\117\97\108\85\115\101\114")),
    L = game:GetService(_0xG("\80\108\97\121\101\114\115")).LocalPlayer,
    C = workspace.CurrentCamera
}

local _0xU = Instance.new("\83\99\114\101\101\110\71\117\105", _0xS.L:WaitForChild("\80\108\97\121\101\114\71\117\105"))
_0xU.Name = tostring(math.random(100000, 999999))
_0xU.ResetOnSpawn = false

local function _0xM()
    local _0xL = Instance.new("\70\114\97\109\101", _0xU)
    _0xL.BackgroundColor3 = _0xEE["\67\111\108\111\114"]
    _0xL.BorderSizePixel = 0
    _0xL.Visible = false
    
    local _0xB = Instance.new("\70\114\97\109\101", _0xU)
    _0xB.BackgroundTransparency = 1
    _0xB.BorderColor3 = _0xEE["\67\111\108\111\114"]
    _0xB.BorderSizePixel = 2
    _0xB.Visible = false
    
    return {L = _0xL, B = _0xB}
end

local _0xD = {}

_0xS.R.RenderStepped:Connect(function()
    -- [[ SPEED BYPASS - ENCRYPTED ]] --
    pcall(function()
        local h = _0xS.L.Character:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
        if h then
            h[_0xG("\87\97\108\107\83\112\101\101\100")] = 16 * _0xEE["\87\97\108\107\83\112\101\101\100"]
        end
    end)

    local _0xT = nil
    local _0xDIST = math.huge

    for _, v in pairs(_0xS.P:GetPlayers()) do
        if v ~= _0xS.L and v.Character and v.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116") then
            if v.Team ~= _0xS.L.Team or v.Team == nil then
                local hrp = v.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
                local head = v.Character:FindFirstChild("\72\101\97\100") or hrp
                local pos, vis = _0xS.C:WorldToViewportPoint(hrp.Position)
                
                local d = _0xD[v] or _0xM()
                _0xD[v] = d

                if vis then
                    -- CALIBRATED ESP
                    local s = Vector2.new(_0xS.C.ViewportSize.X/2, _0xS.C.ViewportSize.Y)
                    local e = Vector2.new(pos.X, pos.Y)
                    d.L.Size = UDim2.new(0, 2, 0, (e - s).Magnitude)
                    d.L.Position = UDim2.new(0, (s.X + e.X)/2, 0, (s.Y + e.Y)/2)
                    d.L.Rotation = math.deg(math.atan2(e.Y - s.Y, e.X - s.X)) - 90
                    d.L.Visible = true
                    
                    local bZ = 2200 / pos.Z
                    d.B.Size = UDim2.new(0, bZ * 0.65, 0, bZ)
                    d.B.Position = UDim2.new(0, pos.X - (bZ * 0.32), 0, pos.Y - (boxH and boxH/2 or bZ/2))
                    d.B.Visible = true

                    -- 360 AIMLOCK SCAN
                    local mag = (_0xS.L.Character.HumanoidRootPart.Position - head.Position).Magnitude
                    if mag < _0xDIST then
                        _0xDIST = mag
                        _0xT = head
                    end
                else
                    d.L.Visible = false
                    d.B.Visible = false
                end
            end
        end
    end

    -- [[ AUTO-EXECUTION RAGE ]] --
    if _0xT then
        _0xS.C.CFrame = _0xS.C.CFrame:Lerp(CFrame.lookAt(_0xS.C.CFrame.Position, _0xT.Position), _0xEE["\65\105\109\83\112\101\101\100"])
        _0xS.V:Button1Down(Vector2.new(0,0), _0xS.C.CFrame)
    else
        _0xS.V:Button1Up(Vector2.new(0,0), _0xS.C.CFrame)
    end
end)
