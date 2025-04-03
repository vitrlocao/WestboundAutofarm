--[[
    West Bounty Auto Farm Script
    Inclui:
    - Auto Mineração
    - Auto Venda
    - Aimbot simplificado
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações
local MiningRange = 20 -- Alcance da mineração
local SellDelay = 30 -- Vender a cada X segundos
local OreTypes = {"Copper", "Iron", "Gold", "Diamond"} -- Tipos de minério para farm

-- Auto Mineração
local function findNearestOre()
    local nearestOre, nearestDistance = nil, math.huge
    
    for _, ore in ipairs(Workspace:GetChildren()) do
        if table.find(OreTypes, ore.Name) and ore:FindFirstChild("CFrame") then
            local distance = (HumanoidRootPart.Position - ore.Position).Magnitude
            if distance < MiningRange and distance < nearestDistance then
                nearestOre = ore
                nearestDistance = distance
            end
        end
    end
    
    return nearestOre
end

local function mineOre(ore)
    -- Simular clique para minerar (pode precisar de adaptação)
    game:GetService("ReplicatedStorage").MiningEvents.MineOre:FireServer(ore)
end

-- Auto Venda
local function sellOres()
    local sellLocation = Workspace:FindFirstChild("SellLocation") -- Ajustar para o nome correto
    if sellLocation then
        HumanoidRootPart.CFrame = sellLocation.CFrame
        wait(1)
        -- Simular venda (pode precisar de adaptação)
        game:GetService("ReplicatedStorage").SellingEvents.SellAll:FireServer()
    end
end

-- Aimbot simplificado
local function findNearestPlayer()
    local nearestPlayer, nearestDistance = nil, math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestPlayer = player
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Loop principal
local lastSold = time()
RunService.Heartbeat:Connect(function()
    -- Auto Farm
    local ore = findNearestOre()
    if ore then
        HumanoidRootPart.CFrame = CFrame.new(ore.Position)
        mineOre(ore)
    end
    
    -- Auto Sell
    if time() - lastSold > SellDelay then
        sellOres()
        lastSold = time()
    end
    
    -- Aimbot (opcional)
    if _G.EnableAimbot then
        local target = findNearestPlayer()
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- Ajustar mira (depende do sistema de armas do jogo)
                -- Exemplo genérico:
                game:GetService("ReplicatedStorage").CombatEvents.Aim:FireServer(targetHRP.Position)
            end
        end
    end
end)

-- Interface simples (opcional)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("West Bounty Script", "DarkTheme")

local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Auto Farm")

MainSection:NewToggle("Enable Auto Farm", "Automatically mines ores", function(state)
    _G.EnableAutoFarm = state
end)

MainSection:NewToggle("Enable Auto Sell", "Automatically sells ores", function(state)
    _G.EnableAutoSell = state
end)

local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Aimbot")

CombatSection:NewToggle("Enable Aimbot", "Locks onto nearest player", function(state)
    _G.EnableAimbot = state
end)