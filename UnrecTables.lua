-- Rayfield
local ShiroHub = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- States
local MinhaBase = nil
local Ativo = false
local valorAtual = 1
local VALOR_MAX = 10

local spamEnabled = false
local ESP_ENABLED = true
local MAX_DISTANCE = 400
local espCache = {}

local Dexloaded = false
local Spyloaded = false 
local Infloaded = false
local antiIdleActive = false
local idleConnection

local noclipEnabled = false
local noclipConn

local speedEnabled = false
local originalSpeed

local jumpEnabled = false
local originalJump

local attacking = false

-- ================= FUNÇÕES =================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local spamEnabled = false

local ATTACK_CFRAME = CFrame.new(
	208.8463897705078, 3.643497943878174, -5.804264068603516,
	0.9121001958847046, 5.310857864593288e-10, -0.4099673628807068,
	-4.03549371696954e-09, 1, -7.682779745721291e-09,
	0.4099673628807068, 8.661885431138217e-09, 0.9121001958847046
)

RunService.Heartbeat:Connect(function()
	if not spamEnabled then return end

	local char = player.Character
	if not char then return end

	local tool = char:FindFirstChild("SquidSlap")
	if not tool then return end

	local remote = tool:FindFirstChild("Event")
	if not remote then return end

	-- dispara corretamente
	remote:FireServer(ATTACK_CFRAME)
end)

-- Reset
local function forceReset()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end
end

-- Rejoin
local TeleportService = game:GetService("TeleportService")

local function rejoin()
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, player)
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

--COLECT TSUNAMI
print("[DEBUG 0] Script iniciou. Player:", LocalPlayer.Name)

-- RemoteFunction
local Remote = game:GetService("ReplicatedStorage")
	:WaitForChild("Packages")
	:WaitForChild("Net")
	:WaitForChild("RF/Plot.PlotAction")

print("[DEBUG 1] Remote encontrado:", Remote:GetFullName())

-- Bases
local Bases = workspace:WaitForChild("Bases")
print("[DEBUG 2] Bases encontradas")

local function BuscarMinhaBase()
	print("[DEBUG 3] Iniciando busca da base")

	for _, base in ipairs(Bases:GetChildren()) do
		if base:IsA("Model") then
			print("[DEBUG 3.1] Verificando base:", base.Name)

			local PlayerName = base:FindFirstChild("PlayerName", true)

			if PlayerName then
				print(
					"[DEBUG 3.2] PlayerName encontrado em",
					PlayerName:GetFullName(),
					"Text = [" .. PlayerName.Text .. "]"
				)
			end

			if PlayerName
			and PlayerName:IsA("TextLabel")
			and (PlayerName.Text == LocalPlayer.Name
				or PlayerName.Text == LocalPlayer.DisplayName) then

				MinhaBase = base
				print("[DEBUG 3.3] BASE CACHEADA:", MinhaBase.Name)
				return true
			end
		end
	end

	print("[DEBUG 3.4] Nenhuma base correspondeu ainda")
	return false
end

-- tenta algumas vezes
task.spawn(function()
	print("[DEBUG 4] Thread de busca iniciada")

	for tentativa = 1, 10 do
		print("[DEBUG 4.1] Tentativa", tentativa)

		if BuscarMinhaBase() then
			print("[DEBUG 4.2] Busca encerrada com sucesso")
			return
		end

		task.wait(0.5)
	end

	warn("[DEBUG 4.3] Base do LocalPlayer NÃO encontrada")
end)

local intervalo = 0.1
local acumulador = 0

RunService.Heartbeat:Connect(function(dt)
	if not Ativo then return end
	if not MinhaBase then return end

	acumulador += dt
	if acumulador < intervalo then return end
	acumulador = 0

	local valor = tostring(valorAtual)

	task.spawn(function()
		Remote:InvokeServer(
			"Collect Money",
			MinhaBase.Name,
			valor
		)
	end)

	-- incrementa de 1 até 10
	valorAtual += 1
	if valorAtual > VALOR_MAX then
		valorAtual = 1
	end
end)

-- ================= UI =================

local Window = ShiroHub:CreateWindow({
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
local Tsunami = Windows:CreateTab("Tsunami")

-- Reset
Exploits:CreateButton({
    Name = "Reset",
    Callback = function()
        forceReset()
    end
})

-- Rejoin
Exploits:CreateButton({
    Name = "Relogar",
    Callback = function()
        rejoin()
    end
})

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
    Name = "Self Freeze",
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            startFly()
        else
            stopFly()
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
   Name = "TouchFling - Obsoleto",
   Callback = function(Value)
      flingEnabled = Value
      if flingEnabled then
         startFling()
      else
         stopFling()
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
        platform.Color = Color3.fromRGB(5, 5, 5)
        platform.Parent = workspace

        hrp.CFrame = platform.CFrame + Vector3.new(0, 6, 0)
    end
})

-- Dex Explorer
Inject:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
     if Dexloaded then return end
     loaded = true
     loadstring(game:HttpGet("https://nescoroco.lat/NDexV01.txt"))()
    end
})

-- SimpleSpy
Inject:CreateButton({
   Name = "SimpleSpy",
   Callback = function()
     if Spyloaded then return end
     loaded = true
     loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end
})

-- Ketamine - ServerSide
Inject:CreateButton({
   Name = "Ketamine",
   Callback = function()
     if Spy1loaded then return end
     loaded = true
 
     loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua"))()
    end
})


-- Infinite Yield
Inject:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
     if Infloaded then return end
     loaded = true
     loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

--Spam Luvinha
District:CreateToggle({
	Name = "Spam Slap",
	CurrentValue = false,
	Callback = function(Value)
		spamEnabled = Value
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

Tsunami:CreateToggle({
	Name = "Auto Collect",
	CurrentValue = false,
	Flag = "CollectMoney",
	Callback = function(state)
		Ativo = state
		print("[DEBUG 8] Toggle alterado. Ativo =", Ativo)
	end
})
