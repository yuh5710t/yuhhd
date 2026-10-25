-- 影月脚本
-- 作者：影子

if getgenv().YingYueLoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "影月脚本", Text = "请勿重复执行", Duration = 3,
    })
    return
end
getgenv().YingYueLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua"))()
if not WindUI then warn("[影月] WindUI 加载失败") return end

local Window = WindUI:CreateWindow({
    Title = "影月脚本", Author = "影子", Icon = "moon", Theme = "Dark",
    Size = UDim2.fromOffset(600, 440), Transparent = true, Folder = "YingYue",
})

Window:EditOpenButton({
    Title = "影月", Icon = "moon", CornerRadius = UDim.new(1, 0), StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(80, 200, 255), Color3.fromRGB(140, 240, 255)),
    Draggable = true,
})

-- ===== 主页 =====
local HomeTab = Window:Tab({ Title = "主页", Icon = "house" })
HomeTab:Section({ Title = "影月脚本" })
HomeTab:Paragraph({ Title = "作者", Desc = "影子" })
HomeTab:Paragraph({ Title = "公告", Desc = "初始版本，持续更新。" })
HomeTab:Paragraph({ Title = "用户", Desc = LocalPlayer.Name })

-- ===== 通用 =====
local CommonTab = Window:Tab({ Title = "通用", Icon = "settings" })
local CommonMove = CommonTab:Section({ Title = "移动" })
local CommonVisual = CommonTab:Section({ Title = "视觉" })
local CommonMisc = CommonTab:Section({ Title = "杂项" })

-- ===== 通用：速度 =====
local speedEnabled = false
local speedValue = 16

local function applySpeed()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedValue end
end

CommonMove:Toggle({
    Title = "启用速度",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        if v then applySpeed() end
    end,
})

CommonMove:Slider({
    Title = "移动速度",
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(v)
        speedValue = v
        if speedEnabled then applySpeed() end
    end,
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if speedEnabled then applySpeed() end
end)

-- ===== 通用：跳跃 =====
local jumpEnabled = false
local jumpValue = 50

local function applyJump()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpValue
    end
end

CommonMove:Toggle({
    Title = "启用跳跃",
    Value = false,
    Callback = function(v)
        jumpEnabled = v
        if v then applyJump() end
    end,
})

CommonMove:Slider({
    Title = "跳跃高度",
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(v)
        jumpValue = v
        if jumpEnabled then applyJump() end
    end,
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if jumpEnabled then applyJump() end
end)-- ===== 通用：飞行 =====
local flying = false
local flyConn = nil
local flySpeed = 40

CommonMove:Toggle({
    Title = "飞行",
    Value = false,
    Callback = function(v)
        flying = v
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if v then
            if not hrp then return end
            if not flyConn then
                flyConn = RunService.Heartbeat:Connect(function()
                    if not flying or not hrp.Parent then return end
                    local cam = workspace.CurrentCamera
                    local move = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
                    if move.Magnitude > 0 then
                        hrp.CFrame += move.Unit * flySpeed * 0.1
                    end
                end)
            end
        else
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if hrp then hrp.Anchored = false end
        end
    end,
})

CommonMove:Slider({
    Title = "飞行速度",
    Value = { Min = 10, Max = 150, Default = 40 },
    Callback = function(v) flySpeed = v end,
})

-- ===== 通用：穿墙 =====
local noclipEnabled = false
local noclipConn = nil

CommonMove:Toggle({
    Title = "穿墙",
    Value = false,
    Callback = function(v)
        noclipEnabled = v
        if v then
            if not noclipConn then
                noclipConn = RunService.Stepped:Connect(function()
                    if not noclipEnabled then return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end)
            end
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
    end,
})-- ===== 通用：夜视 =====
local nightVisionEffect = nil

CommonVisual:Toggle({
    Title = "夜视",
    Value = false,
    Callback = function(v)
        if nightVisionEffect then
            nightVisionEffect:Destroy()
            nightVisionEffect = nil
        end
        if v then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "YY_NightVision"
            cc.Brightness = 0.35
            cc.Contrast = 0.25
            cc.TintColor = Color3.fromRGB(120, 255, 140)
            cc.Parent = Lighting
            nightVisionEffect = cc
        end
    end,
})

-- ===== 通用：FOV =====
local fovEnabled = false
local fovValue = 70

CommonVisual:Toggle({
    Title = "启用视野",
    Value = false,
    Callback = function(v)
        fovEnabled = v
        if v and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = fovValue end
    end,
})

CommonVisual:Slider({
    Title = "视野大小",
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(v)
        fovValue = v
        if fovEnabled and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = v end
    end,
})

RunService.Heartbeat:Connect(function()
    if fovEnabled then
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= fovValue then cam.FieldOfView = fovValue end
    end
end)

-- ===== 通用：无雾 =====
local originalFogEnd = Lighting.FogEnd
local originalFogStart = Lighting.FogStart

CommonVisual:Toggle({
    Title = "无雾",
    Value = false,
    Callback = function(v)
        if v then
            originalFogEnd = Lighting.FogEnd
            originalFogStart = Lighting.FogStart
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = originalFogEnd
            Lighting.FogStart = originalFogStart
        end
    end,
})

-- ===== 通用：全亮 =====
local origBrightness = Lighting.Brightness
local origAmbient = Lighting.Ambient
local origOutdoor = Lighting.OutdoorAmbient
local origShadows = Lighting.GlobalShadows

CommonVisual:Toggle({
    Title = "全亮",
    Value = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoor
            Lighting.Brightness = origBrightness
            Lighting.GlobalShadows = origShadows
        end
    end,
})

-- ===== 通用：去阴影 =====
CommonVisual:Toggle({
    Title = "移除阴影",
    Value = false,
    Callback = function(v)
        Lighting.GlobalShadows = not v
    end,
})

-- ===== 通用：低画质 =====
CommonVisual:Toggle({
    Title = "低画质",
    Value = false,
    Callback = function(v)
        if v then
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = false end
            end
        else
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = true end
            end
        end
    end,
})-- ===== 通用：ESP =====
local espEnabled = false
local espName = false
local espHealth = false
local espDistance = false
local espTeamCheck = false
local espMaxDist = 1000
local espData = {}

local function clearESP()
    for _, d in pairs(espData) do
        if d.highlight then d.highlight:Destroy() end
        if d.billboard then d.billboard:Destroy() end
    end
    espData = {}
end

local function createESPForPlayer(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "YY_ESP_HL"
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = Color3.fromRGB(80, 200, 255)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.Parent = char
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "YY_ESP_BB"
    bb.Size = UDim2.new(0, 180, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = espMaxDist
    bb.Adornee = hrp
    bb.Parent = char
    
    local lbl = Instance.new("TextLabel")
    lbl.Name = "YY_ESP_Label"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(80, 200, 255)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Text = ""
    lbl.Parent = bb
    
    espData[p] = { highlight = hl, billboard = bb, label = lbl, char = char }
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char then
                if not espData[p] or espData[p].char ~= char then
                    if espData[p] then
                        if espData[p].highlight then espData[p].highlight:Destroy() end
                        if espData[p].billboard then espData[p].billboard:Destroy() end
                    end
                    createESPForPlayer(p)
                end
                local d = espData[p]
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if d and hrp and hum and myHrp then
                    local dist = (myHrp.Position - hrp.Position).Magnitude
                    if dist <= espMaxDist then
                        local lines = {}
                        if espName then table.insert(lines, p.Name) end
                        if espHealth then table.insert(lines, string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))) end
                        if espDistance then table.insert(lines, string.format("%dm", math.floor(dist))) end
                        d.label.Text = table.concat(lines, "\n")
                        if espTeamCheck and p.Team and LocalPlayer.Team then
                            d.highlight.FillColor = (p.Team == LocalPlayer.Team) and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
                        else
                            d.highlight.FillColor = Color3.fromRGB(80, 200, 255)
                        end
                    else
                        d.label.Text = ""
                    end
                end
            end
        end
    end
end

CommonVisual:Toggle({
    Title = "启用 ESP",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do createESPForPlayer(p) end
            RunService.Heartbeat:Connect(function()
                if espEnabled then updateESP() end
            end)
        else
            clearESP()
        end
    end,
})
CommonVisual:Toggle({ Title = "显示名字", Value = false, Callback = function(v) espName = v end })
CommonVisual:Toggle({ Title = "显示血量", Value = false, Callback = function(v) espHealth = v end })
CommonVisual:Toggle({ Title = "显示距离", Value = false, Callback = function(v) espDistance = v end })
CommonVisual:Toggle({ Title = "队伍检测", Value = false, Callback = function(v) espTeamCheck = v end })
CommonVisual:Slider({
    Title = "最大显示距离",
    Value = { Min = 100, Max = 2000, Default = 1000 },
    Callback = function(v) espMaxDist = v end,
})
Players.PlayerRemoving:Connect(function(p)
    if espData[p] then
        if espData[p].highlight then espData[p].highlight:Destroy() end
        if espData[p].billboard then espData[p].billboard:Destroy() end
        espData[p] = nil
    end
end)-- ===== 通用：自瞄 =====
local aimEnabled = false
local aimFOV = 120
local aimSmooth = 0.35
local aimPart = "Head"
local aimWallCheck = true
local aimMaxDist = 300
local aimTeamCheck = false
local aimConn = nil

local aimCircle = Drawing.new("Circle")
aimCircle.Visible = false
aimCircle.Thickness = 1.5
aimCircle.NumSides = 64
aimCircle.Filled = false
aimCircle.Color = Color3.fromRGB(80, 200, 255)
aimCircle.Transparency = 1

local function hasWall(fromPos, toPos, ignoreChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = { LocalPlayer.Character }
    if ignoreChar then table.insert(filter, ignoreChar) end
    params.FilterDescendantsInstances = filter
    local hit = workspace:Raycast(fromPos, toPos - fromPos, params)
    return hit ~= nil
end

local function getBestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local camPos = cam.CFrame.Position
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, aimFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character:FindFirstChild(aimPart)
            if hum and hum.Health > 0 and part then
                if not (aimTeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team) then
                    local dist = (part.Position - camPos).Magnitude
                    if dist <= aimMaxDist then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mag = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if mag < bestDist then
                                if not aimWallCheck or not hasWall(camPos, part.Position, p.Character) then
                                    bestDist = mag
                                    best = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function aimLoop()
    if not aimEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    aimCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    aimCircle.Radius = aimFOV
    aimCircle.Visible = true
    local target = getBestTarget()
    if target then
        local current = cam.CFrame
        local targetCF = CFrame.lookAt(current.Position, target.Position)
        cam.CFrame = current:Lerp(targetCF, aimSmooth)
    end
end

CommonVisual:Toggle({
    Title = "启用自瞄",
    Value = false,
    Callback = function(v)
        aimEnabled = v
        if v then
            if not aimConn then aimConn = RunService.RenderStepped:Connect(aimLoop) end
        else
            aimCircle.Visible = false
            if aimConn then aimConn:Disconnect(); aimConn = nil end
        end
    end,
})

CommonVisual:Slider({
    Title = "FOV 大小",
    Value = { Min = 20, Max = 400, Default = 120 },
    Callback = function(v) aimFOV = v end,
})

CommonVisual:Slider({
    Title = "平滑度",
    Value = { Min = 0.05, Max = 1, Default = 0.35 },
    Callback = function(v) aimSmooth = v end,
})

CommonVisual:Slider({
    Title = "最大距离",
    Value = { Min = 50, Max = 1000, Default = 300 },
    Callback = function(v) aimMaxDist = v end,
})

CommonVisual:Dropdown({
    Title = "瞄准部位",
    Values = { "Head", "HumanoidRootPart", "UpperTorso" },
    Value = "Head",
    Callback = function(v) aimPart = v end,
})

CommonVisual:Toggle({ Title = "墙体检测", Value = true, Callback = function(v) aimWallCheck = v end })
CommonVisual:Toggle({ Title = "队伍检测", Value = false, Callback = function(v) aimTeamCheck = v end })-- ===== 通用：无限跳跃 =====
local infJumpEnabled = false

CommonMisc:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(v) infJumpEnabled = v end,
})

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ===== 通用：点击传送 =====
CommonMisc:Button({
    Title = "获取点击传送工具",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "影月传送"
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if mouse and mouse.Hit and hrp then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end,
})

-- ===== 通用：快捷操作 =====
CommonMisc:Button({
    Title = "重置角色",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end,
})

CommonMisc:Button({
    Title = "重新加入服务器",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end,
})

-- ===== 引擎级收尾清理 =====
local function cleanupCommon()
    if aimConn then pcall(function() aimConn:Disconnect() end) end
    if aimCircle then pcall(function() aimCircle:Remove() end) end
    if flyConn then pcall(function() flyConn:Disconnect() end) end
    if noclipConn then pcall(function() noclipConn:Disconnect() end) end
    if nightVisionEffect then pcall(function() nightVisionEffect:Destroy() end) end
    clearESP()
end

Window:OnClose(function()
    cleanupCommon()
end)

local SetTab = Window:Tab({ Title = "设置", Icon = "wrench" })
local SetSec = SetTab:Section({ Title = "界面" })
SetSec:Button({
    Title = "清理所有功能",
    Callback = function()
        cleanupCommon()
        WindUI:Notify({ Title = "影月", Content = "已清理所有通用功能", Duration = 3 })
    end,
})

SetSec:Button({
    Title = "卸载脚本",
    Callback = function()
        cleanupCommon()
        getgenv().YingYueLoaded = nil
        Window:Destroy()
    end,
})

Window:SelectTab(1)
print("[影月] 通用模块加载完成")-- ===== 森林模块 =====
local ForestTab = Window:Tab({ Title = "森林", Icon = "trees" })
local ForestMain = ForestTab:Section({ Title = "森林功能" })

local forestAuraThread, treeAuraThread = nil, nil
local forestAuraEnabled, treeAuraEnabled = false, false
local forestAuraRange, treeAuraRange = 50, 50

local function getForestRemotes()
    return game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
end

local function storeAndDrop(item)
    local inv = LocalPlayer:FindFirstChild("Inventory")
    local sack = inv and (inv:FindFirstChild("Old Sack") or inv:FindFirstChild("Good Sack") or inv:FindFirstChild("Giant Sack"))
    local re = getForestRemotes()
    if sack and re then
        local store, drop = re:FindFirstChild("RequestBagStoreItem"), re:FindFirstChild("RequestBagDropItem")
        if store then pcall(function() store:InvokeServer(sack, item) end) end
        if drop then pcall(function() drop:FireServer(sack, item, false) end) end
    end
end

ForestMain:Button({ Title = "传送所有原木", Callback = function()
    local items, hrp = workspace:FindFirstChild("Items"), LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if items and hrp then for _, v in ipairs(items:GetChildren()) do if v.Name == "Log" then v:PivotTo(hrp.CFrame); storeAndDrop(v) end end end
end})

ForestMain:Button({ Title = "传送所有食物", Callback = function()
    local items, hrp = workspace:FindFirstChild("Items"), LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if items and hrp then for _, v in ipairs(items:GetChildren()) do if v.Name ~= "Berry" and v:GetAttribute("RestoreHunger") then v:PivotTo(hrp.CFrame); storeAndDrop(v) end end end
end})

ForestMain:Button({ Title = "无敌模式 (双击)", DoubleClick = true, Callback = function()
    local dmg = game:GetService("ReplicatedStorage"):FindFirstChild("DamagePlayer", true)
    if dmg then pcall(function() dmg:FireServer(-math.huge) end) end
end})

-- 自动砍树
ForestMain:Toggle({ Title = "自动砍树", Value = false, Callback = function(v)
    treeAuraEnabled = v
    if v then
        if treeAuraThread then task.cancel(treeAuraThread) end
        treeAuraThread = task.spawn(function()
            while treeAuraEnabled do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local inv = LocalPlayer:FindFirstChild("Inventory")
                local re = getForestRemotes()
                local dmg = re and re:FindFirstChild("ToolDamageObject")
                local foliage = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Foliage")
                if hrp and inv and dmg and foliage then
                    local axe = inv:FindFirstChild("Old Axe") or inv:FindFirstChild("Good Axe") or inv:FindFirstChild("Strong Axe")
                    if axe then
                        for _, m in ipairs(foliage:GetChildren()) do
                            if string.match(m.Name, "Tree") or string.match(m.Name, "Pine") then
                                if (hrp.Position - m:GetPivot().Position).Magnitude < treeAuraRange then
                                    pcall(function() dmg:InvokeServer(m, axe, math.random(1,100).."_10012952131", hrp.CFrame) end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    else
        if treeAuraThread then task.cancel(treeAuraThread); treeAuraThread = nil end
    end
end})
ForestMain:Slider({ Title = "砍树范围", Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) treeAuraRange = v end })

-- 杀戮光环
local MONSTERS = { Wolf = true, ["Alpha Wolf"] = true, Mammoth = true, Cultist = true, ["Shadow Cultist"] = true, Bear = true, ["Crossbow Cultist"] = true, Frog = true, ["Brutal Cultist"] = true, Bunny = true }
ForestMain:Toggle({ Title = "自动杀戮光环", Value = false, Callback = function(v)
    forestAuraEnabled = v
    if v then
        if forestAuraThread then task.cancel(forestAuraThread) end
        forestAuraThread = task.spawn(function()
            while forestAuraEnabled do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local inv = LocalPlayer:FindFirstChild("Inventory")
                local re = getForestRemotes()
                local dmg = re and re:FindFirstChild("ToolDamageObject")
                local chars = workspace:FindFirstChild("Characters")
                if hrp and inv and dmg and chars then
                    local axe = inv:FindFirstChild("Old Axe") or inv:FindFirstChild("Good Axe") or inv:FindFirstChild("Strong Axe")
                    if axe then
                        for _, m in ipairs(chars:GetChildren()) do
                            if MONSTERS[m.Name] and (hrp.Position - m:GetPivot().Position).Magnitude < forestAuraRange then
                                pcall(function() dmg:InvokeServer(m, axe, math.random(1,100).."_10012952131", hrp.CFrame) end)
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    else
        if forestAuraThread then task.cancel(forestAuraThread); forestAuraThread = nil end
    end
end})
ForestMain:Slider({ Title = "光环范围", Value = { Min = 20, Max = 200, Default = 50 }, Callback = function(v) forestAuraRange = v end })-- ===== DOORS 模块 =====
local DoorsTab = Window:Tab({ Title = "DOORS", Icon = "door-open" })
local DoorsMain = DoorsTab:Section({ Title = "DOORS 功能" })

local function getDoorsRemotes()
    local rs = game:GetService("ReplicatedStorage")
    return rs:FindFirstChild("RemotesFolder") or rs:FindFirstChild("EntityInfo") or rs:FindFirstChild("Bricks") or rs:FindFirstChild("RemoteEvents")
end

local function fireDoors(name, ...)
    local folder = getDoorsRemotes()
    if not folder then return end
    local remote = folder:FindFirstChild(name)
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(...) end)
    end
end

DoorsMain:Button({ Title = "复活 (双击)", DoubleClick = true, Callback = function() fireDoors("Revive") end })
DoorsMain:Button({ Title = "重新开始 (双击)", DoubleClick = true, Callback = function() fireDoors("PlayAgain") end })
DoorsMain:Button({ Title = "返回大厅 (双击)", DoubleClick = true, Callback = function() fireDoors("Lobby") end })

-- 蹲下防听力
DoorsMain:Toggle({ Title = "防 Figure 听力", Value = false, Callback = function(v)
    fireDoors("Crouch", v)
end})

-- 快速破电闸
DoorsMain:Button({ Title = "快速破解电闸", Callback = function() fireDoors("EBF") end })

-- 远程开门
DoorsMain:Button({ Title = "远程开当前门", Callback = function()
    local room = LocalPlayer:GetAttribute("CurrentRoom")
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not room or not rooms then return end
    local current = rooms:FindFirstChild(tostring(room))
    if not current then return end
    local door = current:FindFirstChild("Door")
    local clientOpen = door and door:FindFirstChild("ClientOpen")
    if clientOpen then pcall(function() clientOpen:FireServer() end) end
end})

-- 自动图书馆密码
local libCodeEnabled = false
local libCodeThread = nil

local function getLibraryCode()
    local rs = game:GetService("ReplicatedStorage")
    local floorVal = rs:FindFirstChild("GameData") and rs.GameData:FindFirstChild("Floor")
    local length = (floorVal and floorVal.Value == "Fools") and 10 or 5
    local slot = table.create(length, "_")
    local paper
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            paper = char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard")
                or (plr.Backpack and (plr.Backpack:FindFirstChild("LibraryHintPaper") or plr.Backpack:FindFirstChild("LibraryHintPaperHard")))
            if paper then break end
        end
    end
    if not paper then return table.concat(slot) end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("PermUI")
    local hints = gui and gui:FindFirstChild("Hints")
    if not hints then return table.concat(slot) end
    local hintList = hints:GetChildren()
    for _, i in ipairs(paper.UI:GetChildren()) do
        if i:IsA("ImageLabel") and i.Name ~= "Image" then
            local pos = tonumber(i.Name)
            if pos and slot[pos] then
                for _, v in ipairs(hintList) do
                    if v.Name == "Icon" and v.ImageRectOffset.X == i.ImageRectOffset.X then
                        local lbl = v:FindFirstChild("TextLabel")
                        if lbl then slot[pos] = lbl.Text end
                        break
                    end
                end
            end
        end
    end
    return table.concat(slot)
end

DoorsMain:Toggle({
    Title = "自动图书馆密码",
    Value = false,
    Callback = function(v)
        libCodeEnabled = v
        if v then
            if libCodeThread then task.cancel(libCodeThread) end
            libCodeThread = task.spawn(function()
                while libCodeEnabled do
                    local code = getLibraryCode()
                    if code and #code > 0 then fireDoors("PL", code) end
                    task.wait(1)
                end
            end)
        else
            if libCodeThread then task.cancel(libCodeThread); libCodeThread = nil end
        end
    end,
})

-- 秒交互
DoorsMain:Toggle({
    Title = "秒交互 (无前摇)",
    Value = false,
    Callback = function(v)
        if v then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.MaxActivationDistance = 200
                        obj.RequiresLineOfSight = false
                    end)
                end
            end
            workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    task.wait(0.1)
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.MaxActivationDistance = 200
                        obj.RequiresLineOfSight = false
                    end)
                end
            end)
        end
    end,
})-- ===== Blood & Iron 模块 =====
local BITab = Window:Tab({ Title = "Blood & Iron", Icon = "swords" })
local BIMain = BITab:Section({ Title = "B&I 功能" })
local function getAnyAxe() local bp = LocalPlayer:FindFirstChild("Backpack"); if bp then for _,n in ipairs({"Axe","Pickaxe","Baguette"}) do if bp:FindFirstChild(n) then return bp[n] end end end end
local digEnabled, braceEnabled = false, false

BIMain:Toggle({ Title = "自动挖雪", Value = false, Callback = function(v)
    digEnabled = v
    if v then task.spawn(function()
        while digEnabled do
            local paths = {"Vardohus Fortress/Modes/Objective/DoorSnow/Diggable", "Vardohus Fortress/Modes/Objective/Diggable"}
            local dig = nil
            for _, p in ipairs(paths) do local n = workspace; for part in string.gmatch(p, "[^/]+") do n = n:FindFirstChild(part); if not n then break end end; if n then dig = n; break end end
            local tool = getAnyAxe()
            if dig and tool and tool:FindFirstChild("RemoteEvent") then
                if tool.Parent ~= LocalPlayer.Character then tool.Parent = LocalPlayer.Character; task.wait(0.2) end
                tool.RemoteEvent:FireServer("Dig", dig, dig.Position)
            end
            task.wait(0.1)
        end
    end) end
end})

BIMain:Toggle({ Title = "静默格挡", Value = false, Callback = function(v)
    braceEnabled = v
    if v then task.spawn(function()
        while braceEnabled do
            local tool = getAnyAxe()
            if tool and tool:FindFirstChild("RemoteEvent") then tool.RemoteEvent:FireServer("BraceBlock") end
            task.wait(0.2)
        end
    end) end
end})

BIMain:Button({ Title = "自动打绷带", Callback = function()
    task.spawn(function()
        local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health < hum.MaxHealth * 0.5 then
            local bandage = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Bandage")
            if bandage then bandage.Parent = char; task.wait(0.3); local r = bandage:FindFirstChild("RemoteEvent"); if r then r:FireServer() end end
        end
    end)
end})

-- ===== 游戏大全模块 =====
local GameTab = Window:Tab({ Title = "游戏大全", Icon = "layers" })
local GameMain = GameTab:Section({ Title = "外链导航" })
local function loadG(u, n)
    WindUI:Notify({Title="影月", Content="加载: "..n, Duration=2})
    task.spawn(function() pcall(function() loadstring(game:HttpGet(u))() end) end)
end

GameMain:Button({ Title = "力量传奇", Callback = function() loadG("网址1", "力量传奇") end})
GameMain:Button({ Title = "最强战场", Callback = function() loadG("网址2", "最强战场") end})
GameMain:Button({ Title = "自然灾害", Callback = function() loadG("网址3", "自然灾害") end})
GameMain:Button({ Title = "监狱人生", Callback = function() loadG("网址4", "监狱人生") end})
GameMain:Button({ Title = "方块战争", Callback = function() loadG("网址5", "方块战争") end})
GameMain:Button({ Title = "后街生存", Callback = function() loadG("网址6", "后街生存") end})
GameMain:Button({ Title = "谋杀决斗", Callback = function() loadG("网址7", "谋杀决斗") end})
GameMain:Button({ Title = "狗对警察", Callback = function() loadG("网址8", "狗对警察") end})

Window:SelectTab(1)
print("[影月] 全部模块加载完成！")
