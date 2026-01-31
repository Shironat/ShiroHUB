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
local Sections = {
    Clogs = require(script.Sections.Logs)
    Exploits = require(script.Sections.Exploits),
    Inject = require(script.Sections.Inject),
    District = require(script.Sections.District)
    Muscle = require(script.Sections.Muscle)
    Tsunami = require(script.Sections.Tsunami)
    Sharp = require(script.Sections.Sharp)


}

-- Inicializa módulos
for _, section in pairs(Sections) do
    if section.Init then
        section.Init(Window)
    end
end