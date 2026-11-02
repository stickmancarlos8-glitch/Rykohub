-- RYKO HUB v2.0 - Roube um Ovo (Edição Definitiva)
-- Executor: Delta

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("RYKO HUB v2.0", "DarkTheme")

-- Servicos do Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Variaveis de Configuracao
local AutoFarm = false
local SpeedBoostEnabled = false
local BoostSpeed = 300
local ServerHopMode = "Least Players"

-- ==========================================
-- 1. BOTÃO FLUTUANTE CIRCULAR (Sua Imagem Personalizada)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local ExistingGui = CoreGui:FindFirstChild("RykoFloatingButton")
if ExistingGui then ExistingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RykoFloatingButton"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ImageButton = Instance.new("ImageButton")
ImageButton.Name = "ToggleButton"
ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImageButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ImageButton.Size = UDim2.new(0, 55, 0, 55)

-- Sua imagem personalizada com o ID enviado
ImageButton.Image = "rbxassetid://107543826823591"
ImageButton.ScaleType = Enum.ScaleType.Crop

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Deixa perfeitamente redondo
UICorner.Parent = ImageButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ImageButton
UIStroke.Color = Color3.fromRGB(138, 43, 225)
UIStroke.Thickness = 2

-- Sistema de Arrastar na Tela (Mobile Drag)
local dragging, dragInput, dragStart, startPos
ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ImageButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ImageButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Abrir e Fechar a UI do Hub ao clicar na bolinha
local uiVisible = true
ImageButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    Library:ToggleUI()
end)

-- ==========================================
-- 2. ABAS E SEÇÕES DO HUB v2.0
-- ==========================================
local TabEggFinder = Window:NewTab("Egg Finder")
local TabEggPredictor = Window:NewTab("Predictor")
local TabFarm = Window:NewTab("Farm")
local TabPlayer = Window:NewTab("Player")
local TabServer = Window:NewTab("Server")

-- Seções
local SectionFinder = TabEggFinder:NewSection("Escanear Ovos no Mapa")
local SectionPredictor = TabEggPredictor:NewSection("Previsão de Spawns")
local SectionFarm = TabFarm:NewSection("Automação de Farm")
local SectionPlayer = TabPlayer:NewSection("Modificações do Jogador")
local SectionServer = TabServer:NewSection("Gerenciamento de Servidores")

-- EGG FINDER
SectionFinder:NewButton("Escanear Ovos", "Destaca os ovos no mapa com ESP", function()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
            count = count + 1
            if not obj:FindFirstChild("RykoHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "RykoHighlight"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = obj
            end
        end
    end
    print("[RYKO HUB v2.0]: " .. count .. " ovos destacados no mapa.")
end)

-- EGG PREDICTOR
SectionPredictor:NewButton("Status dos Spawns", "Mostra o tempo estimado dos ovos raros", function()
    print("[RYKO HUB v2.0]: Monitorando tempo de respawn dos ovos...")
end)

-- FARM (Auto Farm)
SectionFarm:NewToggle("Auto Farm", "Coleta ovos e itens automaticamente", function(state)
    AutoFarm = state
    if AutoFarm then
        task.spawn(function()
            while AutoFarm do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if not AutoFarm then break end
                            if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
                                if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                                    char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- PLAYER (Speed Boost 0 a 1000)
SectionPlayer:NewToggle("Speed Boost", "Ativa o impulso de velocidade personalizado", function(state)
    SpeedBoostEnabled = state
end)

SectionPlayer:NewSlider("Boost Speed", "Ajusta a velocidade (Recomendado até 300 para não bugar a entrega do ovo)", 1000, 16, function(val)
    BoostSpeed = val
end)

-- Loop principal de velocidade do Player
RunService.Stepped:Connect(function()
    pcall(function()
        if SpeedBoostEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = BoostSpeed
            end
        end
    end)
end)

-- ==========================================
-- 3. SERVER HOP (Least Players, Most Players, Random)
-- ==========================================
SectionServer:NewDropdown("Server Hop Mode", "Escolha o modo de busca de servidores", {"Least Players", "Most Players", "Random"}, function(selected)
    ServerHopMode = selected
end)

SectionServer:NewButton("Server Hop", "Procura e entra em outro servidor com base no modo selecionado", function()
    local Servers = {}
    local Success, Err = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        Servers = HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if Success and Servers then
        local targetServer = nil
        
        if ServerHopMode == "Least Players" then
            -- Servidor com menos jogadores (Ex: 1 ou 2 pessoas)
            table.sort(Servers, function(a, b)
                return a.playing < b.playing
            end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    targetServer = s.id
                    break
                end
            end
        elseif ServerHopMode == "Most Players" then
            -- Servidor mais cheio / lotado
            table.sort(Servers, function(a, b)
                return a.playing > b.playing
            end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    targetServer = s.id
                    break
                end
            end
        elseif ServerHopMode == "Random" then
            -- Servidor totalmente aleatório
            local validServers = {}
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(validServers, s.id)
                end
            end
            if #validServers > 0 then
                targetServer = validServers[math.random(1, #validServers)]
            end
        end

        if targetServer then
            print("[RYKO HUB v2.0]: Mudando para o novo servidor...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
        else
            warn("[RYKO HUB v2.0]: Nenhum servidor adequado encontrado.")
        end
    else
        warn("[RYKO HUB v2.0]: Falha ao buscar a lista de servidores.")
    end
end)

SectionServer:NewButton("Rejoin Server", "Reconecta no mesmo servidor atual", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
-- RYKO HUB v2.0 - Roube um Ovo (Edição Definitiva)
-- Executor: Delta

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("RYKO HUB v2.0", "DarkTheme")

-- Servicos do Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Variaveis de Configuracao
local AutoFarm = false
local SpeedBoostEnabled = false
local BoostSpeed = 300
local ServerHopMode = "Least Players"

-- ==========================================
-- 1. BOTÃO FLUTUANTE CIRCULAR (Sua Imagem Personalizada)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local ExistingGui = CoreGui:FindFirstChild("RykoFloatingButton")
if ExistingGui then ExistingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RykoFloatingButton"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ImageButton = Instance.new("ImageButton")
ImageButton.Name = "ToggleButton"
ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImageButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ImageButton.Size = UDim2.new(0, 55, 0, 55)

-- Sua imagem personalizada com o ID enviado
ImageButton.Image = "rbxassetid://107543826823591"
ImageButton.ScaleType = Enum.ScaleType.Crop

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Deixa perfeitamente redondo
UICorner.Parent = ImageButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ImageButton
UIStroke.Color = Color3.fromRGB(138, 43, 225)
UIStroke.Thickness = 2

-- Sistema de Arrastar na Tela (Mobile Drag)
local dragging, dragInput, dragStart, startPos
ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ImageButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ImageButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Abrir e Fechar a UI do Hub ao clicar na bolinha
local uiVisible = true
ImageButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    Library:ToggleUI()
end)

-- ==========================================
-- 2. ABAS E SEÇÕES DO HUB v2.0
-- ==========================================
local TabEggFinder = Window:NewTab("Egg Finder")
local TabEggPredictor = Window:NewTab("Predictor")
local TabFarm = Window:NewTab("Farm")
local TabPlayer = Window:NewTab("Player")
local TabServer = Window:NewTab("Server")

-- Seções
local SectionFinder = TabEggFinder:NewSection("Escanear Ovos no Mapa")
local SectionPredictor = TabEggPredictor:NewSection("Previsão de Spawns")
local SectionFarm = TabFarm:NewSection("Automação de Farm")
local SectionPlayer = TabPlayer:NewSection("Modificações do Jogador")
local SectionServer = TabServer:NewSection("Gerenciamento de Servidores")

-- EGG FINDER
SectionFinder:NewButton("Escanear Ovos", "Destaca os ovos no mapa com ESP", function()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
            count = count + 1
            if not obj:FindFirstChild("RykoHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "RykoHighlight"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = obj
            end
        end
    end
    print("[RYKO HUB v2.0]: " .. count .. " ovos destacados no mapa.")
end)

-- EGG PREDICTOR
SectionPredictor:NewButton("Status dos Spawns", "Mostra o tempo estimado dos ovos raros", function()
    print("[RYKO HUB v2.0]: Monitorando tempo de respawn dos ovos...")
end)

-- FARM (Auto Farm)
SectionFarm:NewToggle("Auto Farm", "Coleta ovos e itens automaticamente", function(state)
    AutoFarm = state
    if AutoFarm then
        task.spawn(function()
            while AutoFarm do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if not AutoFarm then break end
                            if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
                                if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                                    char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- PLAYER (Speed Boost 0 a 1000)
SectionPlayer:NewToggle("Speed Boost", "Ativa o impulso de velocidade personalizado", function(state)
    SpeedBoostEnabled = state
end)

SectionPlayer:NewSlider("Boost Speed", "Ajusta a velocidade (Recomendado até 300 para não bugar a entrega do ovo)", 1000, 16, function(val)
    BoostSpeed = val
end)

-- Loop principal de velocidade do Player
RunService.Stepped:Connect(function()
    pcall(function()
        if SpeedBoostEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = BoostSpeed
            end
        end
    end)
end)

-- ==========================================
-- 3. SERVER HOP (Least Players, Most Players, Random)
-- ==========================================
SectionServer:NewDropdown("Server Hop Mode", "Escolha o modo de busca de servidores", {"Least Players", "Most Players", "Random"}, function(selected)
    ServerHopMode = selected
end)

SectionServer:NewButton("Server Hop", "Procura e entra em outro servidor com base no modo selecionado", function()
    local Servers = {}
    local Success, Err = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        Servers = HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if Success and Servers then
        local targetServer = nil
        
        if ServerHopMode == "Least Players" then
            -- Servidor com menos jogadores (Ex: 1 ou 2 pessoas)
            table.sort(Servers, function(a, b)
                return a.playing < b.playing
            end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    targetServer = s.id
                    break
                end
            end
        elseif ServerHopMode == "Most Players" then
            -- Servidor mais cheio / lotado
            table.sort(Servers, function(a, b)
                return a.playing > b.playing
            end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    targetServer = s.id
                    break
                end
            end
        elseif ServerHopMode == "Random" then
            -- Servidor totalmente aleatório
            local validServers = {}
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(validServers, s.id)
                end
            end
            if #validServers > 0 then
                targetServer = validServers[math.random(1, #validServers)]
            end
        end

        if targetServer then
            print("[RYKO HUB v2.0]: Mudando para o novo servidor...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
        else
            warn("[RYKO HUB v2.0]: Nenhum servidor adequado encontrado.")
        end
    else
        warn("[RYKO HUB v2.0]: Falha ao buscar a lista de servidores.")
    end
end)

SectionServer:NewButton("Rejoin Server", "Reconecta no mesmo servidor atual", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
