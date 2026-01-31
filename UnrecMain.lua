local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ShiroHub v2",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "by ShiroNat",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UnrecTables",
        FileName = "UnrecMain"
    }
})

--Tabs
local Tabs = {
    Exploits = Window:CreateTab("Exploits"),
    Inject = Window:CreateTab("Inject"),
    District = Window:CreateTab("District"),
    Muscle = Window:CreateTab("Muscle"),
    Sharp = Window:CreateTab("Sharp"),
    Tsunami = Window:CreateTab("Tsunami"),
    Logs = Windows:CreateTab("Logs"),
}

--Modulos
local Modules = {
    Exploits = require(script.Modules.Exploits),
    Inject = require(script.Modules.Inject),
    District = require(script.Modules.District),
    Muscle = require(script.Modules.Muscle),
    Tsunami = require(script.Modules.Tsunami),
    Sharp = require(script.Modules.Sharp),
    Logs = require(script.Modules.Logs),
}

--inicializar modulos
for name, module in pairs(Modules) do
    if module.Init then
        module.Init(Window, Tabs[name])
    end
end