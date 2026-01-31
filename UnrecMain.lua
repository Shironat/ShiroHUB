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

-- Carregar modulos
local Modules = {
    Clogs = require(script.Modules.Logs)
    Exploits = require(script.Modules.Exploits),
    Inject = require(script.Modules.Inject),
    District = require(script.Modules.District)
    Muscle = require(script.Modules.Muscle)
    Tsunami = require(script.Modules.Tsunami)
    Sharp = require(script.Modules.Sharp)


}

-- Inicializa módulos
for _, modules in pairs(Modules) do
    if modules.Init then
        modules.Init(Window, Tabs)
    end
end