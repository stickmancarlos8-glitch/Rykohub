-- RYKO HUB v2.4 - Roube um Ovo (Correção de Fecho de Interface)
-- Executor: Delta

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("RYKO HUB v2.4", "DarkTheme")

-- Servicos do Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Variaveis de Configuracao
local SpeedBoostEnabled = false
local BoostSpeed = 300
local ServerHopMode = "Least Players"
local AutoStealEnabled = false

-- ==========================================
-- 1. BOTÃO FLUTUANTE PRINCIPAL (Abre/Fecha o Hub Corrigido)
-- ==========================================
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
ImageButton.Image = "rbxassetid://107543826823591"
ImageButton.ScaleType = Enum.ScaleType.Crop

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ImageButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ImageButton
UIStroke.Color = Color3.fromRGB(138, 43, 225)
UIStroke.Thickness = 2

-- Arrastar Botão Principal sem conflito
local dragging, dragInput, dragStart, startPos, clicked = false, nil, nil, nil, true
ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        clicked = true
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

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            clicked = false
        end
        ImageButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sistema de Toggle limpo para a UI Principal
ImageButton.MouseButton1Click:Connect(function()
    if clicked then
        pcall(function()
            local mainUI = CoreGui:FindFirstChild("KavoUI") or CoreGui:FindFirstChild("ScreenGui")
            if mainUI then
                for _, child in pairs(CoreGui:GetChildren()) do
                    if child:IsA("ScreenGui") and child:FindFirstChild("Main") then
                        child.Enabled = not child.Enabled
                        break
                    end
                end
            else
                Library:ToggleUI()
            end
        end)
    end
    clicked = true
end)

-- ==========================================
-- 2. PAINEL LATERAL FLUTUANTE (STEAL PANEL) COM FECHO PERFEITO
-- ==========================================
local ExistingStealGui = CoreGui:FindFirstChild("RykoStealPanel")
if ExistingStealGui then ExistingStealGui:Destroy() end

local StealGui = Instance.new("ScreenGui")
StealGui.Name = "RykoStealPanel"
StealGui.Parent = CoreGui
StealGui.ResetOnSpawn = false

local MainPanel = Instance.new("Frame")
MainPanel.Name = "Panel"
MainPanel.Parent = StealGui
MainPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainPanel.Position = UDim2.new(0.68, 0, 0.15, 0)
MainPanel.Size = UDim2.new(0, 260, 0, 310)
MainPanel.Active = true
MainPanel.Draggable = true

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 8)
PanelCorner.Parent = MainPanel

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainPanel
TitleLabel.BackgroundColor3 = Color3.fromRGB(138, 43, 225)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "RYKO - Steal Panel"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Botão de Fechar o Painel Lateral (X)
local ClosePanelBtn = Instance.new("TextButton")
ClosePanelBtn.Parent = TitleLabel
ClosePanelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClosePanelBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
ClosePanelBtn.Size = UDim2.new(0, 25, 0, 25)
ClosePanelBtn.Font = Enum.Font.SourceSansBold
ClosePanelBtn.Text = "X"
ClosePanelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePanelBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = ClosePanelBtn

-- Botão Flutuante Secundário para reabrir o Steal Panel
local StealToggleBtn = Instance.new("ImageButton")
StealToggleBtn.Name = "StealToggleButton"
StealToggleBtn.Parent = ScreenGui
StealToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StealToggleBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
StealToggleBtn.Size = UDim2.new(0, 45, 0, 45)
StealToggleBtn.Image = "rbxassetid://107543826823591"
StealToggleBtn.ScaleType = Enum.ScaleType.Crop
StealToggleBtn.Visible = false

local StealToggleCorner = Instance.new("UICorner")
StealToggleCorner.CornerRadius = UDim.new(1, 0)
StealToggleCorner.Parent = StealToggleBtn

ClosePanelBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
    StealToggleBtn.Visible = true
end)

StealToggleBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = true
    StealToggleBtn.Visible = false
end)

-- Botão Auto Steal
local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Parent = MainPanel
AutoStealBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AutoStealBtn.Position = UDim2.new(0.05, 0, 0.14, 0)
AutoStealBtn.Size = UDim2.new(0.9, 0, 0, 28)
AutoStealBtn.Font = Enum.Font.SourceSansBold
AutoStealBtn.Text = "Auto Steal: OFF"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
AutoStealBtn.TextSize = 13

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = AutoStealBtn

AutoStealBtn.MouseButton1Click:Connect(function()
    AutoStealEnabled = not AutoStealEnabled
    if AutoStealEnabled then
        AutoStealBtn.Text = "Auto Steal: ON"
        AutoStealBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        AutoStealBtn.Text = "Auto Steal: OFF"
        AutoStealBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Lista de Ovos no Painel Lateral
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainPanel
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0.26, 0)
ScrollingFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Atualizador dos Ovos
task.spawn(function()
    while true do
        pcall(function()
            for _, child in pairs(ScrollingFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
                    if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                        local itemFrame = Instance.new("Frame")
                        itemFrame.Parent = ScrollingFrame
                        itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                        itemFrame.Size = UDim2.new(1, -5, 0, 32)
                        
                        local fCorner = Instance.new("UICorner")
                        fCorner.CornerRadius = UDim.new(0, 4)
                        fCorner.Parent = itemFrame
                        
                        local itemText = Instance.new("TextLabel")
                        itemText.Parent = itemFrame
                        itemText.BackgroundTransparency = 1
                        itemText.Position = UDim2.new(0.05, 0, 0, 0)
                        itemText.Size = UDim2.new(0.65, 0, 1, 0)
                        itemText.Font = Enum.Font.SourceSansBold
                        itemText.Text = tostring(obj.Name)
                        itemText.TextColor3 = Color3.fromRGB(255, 215, 0)
                        itemText.TextSize = 12
                        itemText.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local stealActionBtn = Instance.new("TextButton")
                        stealActionBtn.Parent = itemFrame
                        stealActionBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
                        stealActionBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
                        stealActionBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
                        stealActionBtn.Font = Enum.Font.SourceSansBold
                        stealActionBtn.Text = "Steal"
                        stealActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        stealActionBtn.TextSize = 11
                        
                        local sCorner = Instance.new("UICorner")
                        sCorner.CornerRadius = UDim.new(0, 4)
                        sCorner.Parent = stealActionBtn
                        
                        local targetObj = obj
                        stealActionBtn.MouseButton1Click:Connect(function()
                            pcall(function()
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetObj.CFrame + Vector3.new(0, 3, 0)
                                end
                            end)
                        end)
                    end
                end
            end
        end)
        task.wait(3)
    end
end)

-- Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(1)
        if AutoStealEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if not AutoStealEnabled then break end
                        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "ovo")) then
                            if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                                char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- 3. ABAS DO HUB v2.4
-- ==========================================
local TabPlayer = Window:NewTab("Player")
local TabServer = Window:NewTab("Server")

local SectionPlayer = TabPlayer:NewSection("Modificações do Jogador")
local SectionServer = TabServer:NewSection("Gerenciamento de Servidores")

-- PLAYER (Speed Boost Anti-Stun)
SectionPlayer:NewToggle("Speed Boost", "Velocidade otimizada sem puxar para trás", function(state)
    SpeedBoostEnabled = state
end)

SectionPlayer:NewSlider("Boost Speed", "Ajusta a velocidade (Recomendado até 300)", 1000, 16, function(val)
    BoostSpeed = val
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if SpeedBoostEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local humanoid = char.Humanoid
                humanoid.WalkSpeed = BoostSpeed
                if humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (humanoid.MoveDirection * (BoostSpeed / 15000))
                end
            end
        end
    end)
end)

-- ==========================================
-- 4. SERVER HOP
-- ==========================================
SectionServer:NewDropdown("Server Hop Mode", "Modo de troca de servidor", {"Least Players", "Most Players", "Random"}, function(selected)
    ServerHopMode = selected
end)

SectionServer:NewButton("Server Hop", "Procura e entra em outro servidor", function()
    local Servers = {}
    local Success = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        Servers = HttpService:JSONDecode(game:HttpGet(url)).data
    end)

    if Success and Servers then
        local targetServer = nil
        if ServerHopMode == "Least Players" then
            table.sort(Servers, function(a, b) return a.playing < b.playing end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then targetServer = s.id break end
            end
        elseif ServerHopMode == "Most Players" then
            table.sort(Servers, function(a, b) return a.playing > b.playing end)
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then targetServer = s.id break end
            end
        elseif ServerHopMode == "Random" then
            local validServers = {}
            for _, s in ipairs(Servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(validServers, s.id) end
            end
            if #validServers > 0 then targetServer = validServers[math.random(1, #validServers)] end
        end

        if targetServer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
        end
    end
end)

SectionServer:NewButton("Rejoin Server", "Reconecta no mesmo servidor", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
