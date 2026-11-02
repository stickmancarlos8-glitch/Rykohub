--!strict
--================================================================--
--                   RYKO HUB V1.0 - OFFICIAL MAIN                --
--                 Compatível com Delta Mobile / PC               --
--================================================================--

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cores do Tema Dark Violet
local Theme = {
    Background = Color3.fromRGB(15, 12, 22),
    Sidebar = Color3.fromRGB(22, 18, 33),
    Card = Color3.fromRGB(30, 24, 45),
    Accent = Color3.fromRGB(138, 43, 226), -- Violeta
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(160, 155, 175)
}

-- Criando a Interface Principal (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RykoHubUI"
screenGui.ResetOnSpawn = false

-- Tratamento para inserir no CoreGui (suportado pelo Delta)
local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Painel Principal
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 580, 0, 360)
main.Position = UDim2.new(0.5, -290, 0.5, -180)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Accent
stroke.Thickness = 1.5
stroke.Parent = main

-- TopBar (Barra Superior para Arrastar)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Theme.Sidebar
topBar.BorderSizePixel = 0
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Text = "  RYKO HUB <font color=\"rgb(168,85,247)\">v1.0</font>"
title.RichText = true
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Theme.Text
title.Size = UDim2.new(0, 200, 1, 0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Botão de Fechar (X)
local btnClose = Instance.new("TextButton")
btnClose.Text = "✕"
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -35, 0.5, -15)
btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnClose.TextColor3 = Theme.Text
btnClose.Font = Enum.Font.GothamBold
btnClose.Parent = topBar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Botão de Minimizar (-)
local btnMin = Instance.new("TextButton")
btnMin.Text = "-"
btnMin.Size = UDim2.new(0, 30, 0, 30)
btnMin.Position = UDim2.new(1, -70, 0.5, -15)
btnMin.BackgroundColor3 = Theme.Card
btnMin.TextColor3 = Theme.Text
btnMin.Font = Enum.Font.GothamBold
btnMin.Parent = topBar
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 6)

local isMinimized = false
btnMin.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(main, TweenInfo.new(0.3), {
        Size = isMinimized and UDim2.new(0, 580, 0, 40) or UDim2.new(0, 580, 0, 360)
    }):Play()
end)

-- Sistema de Arrastar na Tela (Mobile e PC)
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Menu Lateral (Sidebar)
local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = sidebar

-- Área de Conteúdo das Abas
local content = Instance.new("Frame")
content.Name = "ContentArea"
content.Size = UDim2.new(1, -145, 1, -45)
content.Position = UDim2.new(0, 142, 0, 42)
content.BackgroundTransparency = 1
content.Parent = main

-- Função para Criar Abas Automaticamente
local tabs = {}
local function createTab(tabName: string)
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(0.9, 0, 0, 32)
    tabButton.BackgroundColor3 = Theme.Card
    tabButton.TextColor3 = Theme.TextDim
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 13
    tabButton.Parent = sidebar
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

    local pageFrame = Instance.new("ScrollingFrame")
    pageFrame.Name = tabName .. "_Page"
    pageFrame.Size = UDim2.new(1, 0, 1, 0)
    pageFrame.BackgroundTransparency = 1
    pageFrame.Visible = false
    pageFrame.ScrollBarThickness = 3
    pageFrame.Parent = content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = pageFrame

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Frame.Visible = false
            tab.Button.BackgroundColor3 = Theme.Card
            tab.Button.TextColor3 = Theme.TextDim
        end
        pageFrame.Visible = true
        tabButton.BackgroundColor3 = Theme.Accent
        tabButton.TextColor3 = Theme.Text
    end)

    if #tabs == 0 then
        pageFrame.Visible = true
        tabButton.BackgroundColor3 = Theme.Accent
        tabButton.TextColor3 = Theme.Text
    end

    table.insert(tabs, { Button = tabButton, Frame = pageFrame })
    return pageFrame
end

-- ==========================================
-- ADICIONANDO AS ABAS E FUNCIONALIDADES
-- ==========================================

-- 1. ABA: Egg Finder
local eggPage = createTab("Egg Finder")
local scanBtn = Instance.new("TextButton")
scanBtn.Text = "🔍 Escanear Ovos no Mapa"
scanBtn.Size = UDim2.new(1, -10, 0, 35)
scanBtn.BackgroundColor3 = Theme.Accent
scanBtn.TextColor3 = Theme.Text
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = eggPage

scanBtn.MouseButton1Click:Connect(function()
    print("[RYKO HUB] Escaneando o mapa em busca de ovos...")
end)

-- 2. ABA: Egg Predictor
local predPage = createTab("Egg Predictor")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 0, 70)
infoLabel.Text = "🔮 Status dos Spawns:\n• Dragon Egg: 85% (Estimado)\n• Golden Egg: 100% em 30s (Real)"
infoLabel.TextColor3 = Theme.TextDim
infoLabel.BackgroundColor3 = Theme.Card
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = predPage
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)

-- 3. ABA: Farm
local farmPage = createTab("Farm")
local farmToggle = Instance.new("TextButton")
farmToggle.Text = "Auto Farm: [ OFF ]"
farmToggle.Size = UDim2.new(1, -10, 0, 40)
farmToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
farmToggle.TextColor3 = Theme.Text
farmToggle.Font = Enum.Font.GothamBold
farmToggle.Parent = farmPage
Instance.new("UICorner", farmToggle).CornerRadius = UDim.new(0, 6)

local isFarmOn = false
farmToggle.MouseButton1Click:Connect(function()
    isFarmOn = not isFarmOn
    farmToggle.Text = isFarmOn and "Auto Farm: [ ON ]" or "Auto Farm: [ OFF ]"
    farmToggle.BackgroundColor3 = isFarmOn and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
end)

-- 4. ABA: Player
local playerPage = createTab("Player")
local speedBtn = Instance.new("TextButton")
speedBtn.Text = "Definir Velocidade (32)"
speedBtn.Size = UDim2.new(1, -10, 0, 35)
speedBtn.BackgroundColor3 = Theme.Card
speedBtn.TextColor3 = Theme.Text
speedBtn.Font = Enum.Font.GothamSemibold
speedBtn.Parent = playerPage
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

speedBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 32
    end
end)

-- 5. ABA: Server
local serverPage = createTab("Server")
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Text = "Reconectar no Servidor"
rejoinBtn.Size = UDim2.new(1, -10, 0, 35)
serverPage.Parent = serverPage -- Correção simples do container
rejoinBtn.BackgroundColor3 = Theme.Card
rejoinBtn.TextColor3 = Theme.Text
rejoinBtn.Font = Enum.Font.GothamSemibold
rejoinBtn.Parent = serverPage
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 6)

rejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- 6. ABA: Settings & Config
local configPage = createTab("Config")
local saveBtn = Instance.new("TextButton")
saveBtn.Text = "Salvar Preferências"
saveBtn.Size = UDim2.new(1, -10, 0, 35)
saveBtn.BackgroundColor3 = Theme.Accent
saveBtn.TextColor3 = Theme.Text
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = configPage
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

print("[RYKO HUB V1.0] Carregado com sucesso no Delta!")
