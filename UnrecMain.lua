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
    Logs     = Window:CreateTab("Logs", 4483362458),
    Exploits = Window:CreateTab("Exploits", 4483362458),
    Inject   = Window:CreateTab("Inject", 4483362458),
    District = Window:CreateTab("District", 4483362458),
    Muscle   = Window:CreateTab("Muscle", 4483362458),
    Tsunami  = Window:CreateTab("Tsunami", 4483362458),
    Sharp    = Window:CreateTab("Sharp", 4483362458)
}

--Modulos
local Modules = {
    Logs     = require(script.Modules.Logs),
    Exploits = require(script.Modules.Exploits),
    Inject   = require(script.Modules.Inject),
    District = require(script.Modules.District),
    Muscle   = require(script.Modules.Muscle),
    Tsunami  = require(script.Modules.Tsunami),
    Sharp    = require(script.Modules.Sharp)
}

--inicializar modulos
for name, module in pairs(Modules) do
    if module.Init then
        module.Init(Window, Tabs[name])
    end
end