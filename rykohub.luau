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
            -- Alterna o estado da UI Kavo de forma segura
            local mainUI = CoreGui:FindFirstChild("KavoUI") or CoreGui:FindFirstChild("ScreenGui")
            if mainUI then
                -- Procura a janela principal dentro da biblioteca
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
BtnCorner.Corner
