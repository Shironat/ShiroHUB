-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- States
local ESP_ENABLED = true
local MAX_DISTANCE = 400
local ESP_ENABLED = true
local espCache = {}

local loaded = false
local antiIdleActive = false
local idleConnection

local noclipEnabled = false
local noclipConn

local speedEnabled = false
local originalSpeed

local jumpEnabled = false
local originalJump

local flying = false
local flyConn
local flyspeed = 50

local flingEnabled = false
local flingPower = 200000

local attacking = false

-- ================= FUNÇÕES =================

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():WaitForChild("Humanoid")
end

local function getHRP()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

-- Bring
local function bringPlayer(target)
    if not target or target == player then return end
    if not target.Character then return end

    local myHRP = getHRP()
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not targetHRP then return end

    local oldCF = targetHRP.CFrame
    targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
    targetHRP.Anchored = true

    task.delay(30, function()
        if targetHRP and targetHRP.Parent then
            targetHRP.Anchored = false
            targetHRP.CFrame = oldCF
        end
    end)
end

-- Cria lista em Dropdown
local function getPlayerList()
    local list = {"All"}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- Verifica se tem times
local function hasTeams()
    return #Teams:GetTeams() > 0
end

-- Cria ESP
local function createESP(char)
    if espCache[char] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 80, 80)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char

    espCache[char] = highlight
end

-- Remove ESP
local function removeESP(char)
    if espCache[char] then
        espCache[char]:Destroy()
        espCache[char] = nil
    end
end

-- Verifica se é inimigo
local function isEnemy(plr)
    if plr == player then
        return false
    end

    if hasTeams() then
        if not player.Team or not plr.Team then
            return true
        end
        return plr.Team ~= player.Team
    end

    return true
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then return end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if char and hrp and hum and hum.Health > 0 and isEnemy(plr) then
                local dist = (myHRP.Position - hrp.Position).Magnitude

                if dist <= MAX_DISTANCE then
                    createESP(char)
                else
                    removeESP(char)
                end
            else
                if char then
                    removeESP(char)
                end
            end
        end
    end
end)

-- Limpeza ao sair
Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        removeESP(plr.Character)
    end
end)

-- Jump helpers
local function getJumpValue(humanoid)
    return humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight
end

local function setJumpValue(humanoid, value)
    if humanoid.UseJumpPower then
        humanoid.JumpPower = value
    else
        humanoid.JumpHeight = value
    end
end

-- Noclip
local function setNoclip(state)
    for _, part in ipairs(getCharacter():GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- Player list
local function getPlayerList()
    local list = {"All"}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- Bring
local function bringLocal(target)
    if not target.Character then return end
    local myHRP = getHRP()
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local old = targetHRP.CFrame
    targetHRP.CFrame = myHRP.CFrame * CFrame.new(0,0,-3)
    targetHRP.Anchored = true

    task.delay(2, function()
        if targetHRP then
            targetHRP.Anchored = false
            targetHRP.CFrame = old
        end
    end)
end

-- Touch fling
local function onTouch(part)
    if not flingEnabled then return end
    if not part or not part.Parent then return end

    local hum = part.Parent:FindFirstChildOfClass("Humanoid")
    local hrp = part.Parent:FindFirstChild("HumanoidRootPart")

    if hum and hrp and part.Parent ~= getCharacter() then
        local myHRP = getHRP()
        local dir = (hrp.Position - myHRP.Position).Unit
        hrp.AssemblyLinearVelocity = dir * flingPower + Vector3.new(0, flingPower / 3, 0)
    end
end

-- ================= INPUT (FLY) =================

local keys = {W=false,A=false,S=false,D=false,Space=false,Ctrl=false}

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.W then keys.W = true end
    if i.KeyCode == Enum.KeyCode.A then keys.A = true end
    if i.KeyCode == Enum.KeyCode.S then keys.S = true end
    if i.KeyCode == Enum.KeyCode.D then keys.D = true end
    if i.KeyCode == Enum.KeyCode.Space then keys.Space = true end
    if i.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = true end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then keys.W = false end
    if i.KeyCode == Enum.KeyCode.A then keys.A = false end
    if i.KeyCode == Enum.KeyCode.S then keys.S = false end
    if i.KeyCode == Enum.KeyCode.D then keys.D = false end
    if i.KeyCode == Enum.KeyCode.Space then keys.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = false end
end)

-- ================= UI =================

local Window = Rayfield:CreateWindow({
    Name = "ShiroHub v1",
    LoadingTitle = "ShiroHub v1",
    LoadingSubtitle = "by Shiro",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "shirohub",
        FileName = "ShiroHub"
    }
})

local Exploits = Window:CreateTab("Exploits")
local Inject = Window:CreateTab("Injection")
local District = Window:CreateTab("District")

-- WalkSpeed
Exploits:CreateToggle({
    Name = "WalkSpeed",
    Callback = function(Value)
        speedEnabled = Value
        local hum = getHumanoid()

        if speedEnabled then
            originalSpeed = originalSpeed or hum.WalkSpeed
            hum.WalkSpeed = originalSpeed * 1.5
        else
            if originalSpeed then
                hum.WalkSpeed = originalSpeed
                originalSpeed = nil
            end
        end
    end
})

-- Jump
Exploits:CreateToggle({
    Name = "JumpForce",
    Callback = function(Value)
        jumpEnabled = Value
        local hum = getHumanoid()

        if jumpEnabled then
            originalJump = originalJump or getJumpValue(hum)
            setJumpValue(hum, originalJump * 2)
        else
            if originalJump then
                setJumpValue(hum, originalJump)
                originalJump = nil
            end
        end
    end
})

-- Fly
Exploits:CreateToggle({
    Name = "Fly",
    Callback = function(Value)
        flying = Value
        local hrp = getHRP()
        local hum = getHumanoid()

        if flying then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.AutoRotate = false

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P = 9e4
            bg.CFrame = workspace.CurrentCamera.CFrame
            bg.Parent = hrp

            flyConn = RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                local move = Vector3.zero

                if keys.W then move += cam.CFrame.LookVector end
                if keys.S then move -= cam.CFrame.LookVector end
                if keys.D then move += cam.CFrame.RightVector end
                if keys.A then move -= cam.CFrame.RightVector end
                if keys.Space then move += cam.CFrame.UpVector end
                if keys.Ctrl then move -= cam.CFrame.UpVector end

                if move.Magnitude > 0 then
                    bv.Velocity = move.Unit * flyspeed
                else
                    bv.Velocity = Vector3.zero
                end

                bg.CFrame = cam.CFrame
            end)
        else
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end

            for _, v in ipairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                    v:Destroy()
                end
            end

            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
})

-- Noclip
Exploits:CreateToggle({
    Name = "Noclip",
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            noclipConn = RunService.Stepped:Connect(function()
                setNoclip(true)
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
            setNoclip(false)
        end
    end
})

-- ESP
Exploits:CreateToggle({
    Name = "ESP",
    Callback = function(Value)
        ESP_ENABLED = Value
        if not Value then
            for char in pairs(espCache) do
                removeESP(char)
            end
        end
    end
})

-- Touch Fling
Exploits:CreateToggle({
    Name = "TouchFling",
    Callback = function(Value)
        flingEnabled = Value
        if flingEnabled then
            for _, p in ipairs(getCharacter():GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Touched:Connect(onTouch)
                end
            end
        end
    end
})

-- Bring
local BringDropdown = Exploits:CreateDropdown({
    Name = "Bring",
    Options = getPlayerList(),
    CurrentOption = {"All"},
    MultipleOptions = false,
    Callback = function(Option)
        local selected = Option[1]

        if selected == "All" then
            for _, plr in ipairs(Players:GetPlayers()) do
                bringPlayer(plr)
            end
        else
            local target = Players:FindFirstChild(selected)
            if target then
                bringPlayer(target)
            end
        end
    end
})

Players.PlayerAdded:Connect(function()
    BringDropdown:Refresh(getPlayerList())
end)
Players.PlayerRemoving:Connect(function()
    BringDropdown:Refresh(getPlayerList())
end)

-- Anti Afk
Exploits:CreateButton({
    Name = "Anti AFK",
    Callback = function()
        if antiIdleActive then return end
        antiIdleActive = true

        idleConnection = player.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
})

-- Plataforma AFK
Exploits:CreateButton({
    Name = "Plataforma AFK",
    Callback = function()
        local hrp = getHRP()

        if workspace:FindFirstChild("AFK_Platform") then
            workspace.AFK_Platform:Destroy()
        end

        local platform = Instance.new("Part")
        platform.Name = "AFK_Platform"
        platform.Size = Vector3.new(200, 5, 200)
        platform.Position = hrp.Position + Vector3.new(0, 2000, 0)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.SmoothPlastic
        platform.Color = Color3.fromRGB(80, 80, 80)
        platform.Parent = workspace

        hrp.CFrame = platform.CFrame + Vector3.new(0, 6, 0)
    end
})

-- Dex Explorer
Injection:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
     if loaded then return end
     loaded = true
     loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Dex%20Explorer.lua"))()
    end
})

-- SimpleSpy
Injection:CreateButton({
   Name = "SimpleSpy",
   Callback = function()
     if loaded then return end
     loaded = true
     loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end
})

-- Infinite Yield
Injection:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
     if loaded then return end
     loaded = true
     loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- Fast Attack
District:CreateToggle({
    Name = "Ataque - District",
    Callback = function(Value)
        attacking = Value
        if attacking then
            task.spawn(function()
                while attacking do
                    ReplicatedStorage.Remotes.Attacks.BasicAttack:FireServer()
                    task.wait()
                end
            end)
        end
    end
})