-- [[ GitHub: main_hub.lua ]]
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ИМПОРТ МОДУЛЕЙ (Если тестируешь локально, оставь require. Если закинешь на GitHub — замени на loadstring)
local PickupSystem = loadstring(game:HttpGet("ссылка_на_твою_актуальную_версию_pickup_system.lua"))()
local FarmSystem = loadstring(game:HttpGet("ссылка_на_твою_актуальную_версию_farm_system.lua"))()

-- ГЛОБАЛЬНЫЙ СТЕЙТ (Конфиг, к которому обращаются модули)
local HUB_CONFIG = {
	AutoFarmEnabled = false,
	AutoPickupEnabled = true,
	CurrentTargetZone = "Coal Ore", -- Первая по твоему списку
	AllowedRarities = {
		Common    = false,
		Uncommon  = true,
		Rare      = true,
		Epic      = true,
		Legendary = true,
		Mythic    = true,
		Secret    = true,
		Godly     = true,
		Divine    = true
	}
}

-- Инициализируем фоновые процессы в модулях
PickupSystem.Init(HUB_CONFIG)
FarmSystem.StartLoop(HUB_CONFIG)

-- ====================================================================
-- СБОРКА ИНТЕРФЕЙСА (UI)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GitHub_Mining_Hub"
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 260, 0, 380)
MainPanel.Position = UDim2.new(0.05, 0, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Title.Text = "⛏️ GITHUB MINING HUB v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainPanel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- КНОПКА: Авто-Фарм
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.9, 0, 0, 35)
FarmBtn.Position = UDim2.new(0.05, 0, 0, 50)
FarmBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
FarmBtn.Text = "Auto-Farm Ores: OFF"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.Parent = MainPanel

FarmBtn.MouseButton1Click:Connect(function()
	HUB_CONFIG.AutoFarmEnabled = not HUB_CONFIG.AutoFarmEnabled
	FarmBtn.BackgroundColor3 = HUB_CONFIG.AutoFarmEnabled and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(180, 50, 50)
	FarmBtn.Text = HUB_CONFIG.AutoFarmEnabled and "Auto-Farm Ores: ON" or "Auto-Farm Ores: OFF"
end)

-- ВЫПАДАЮЩИЙ СПИСОК (Dropdown зон из Модуля Фарма)
local DropdownMain = Instance.new("Frame")
DropdownMain.Size = UDim2.new(0.9, 0, 0, 35)
DropdownMain.Position = UDim2.new(0.05, 0, 0, 95)
DropdownMain.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
DropdownMain.Parent = MainPanel

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, 0, 1, 0)
DropdownBtn.BackgroundTransparency = 1
DropdownBtn.Text = "Select Zone: " .. HUB_CONFIG.CurrentTargetZone
DropdownBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
DropdownBtn.Font = Enum.Font.SourceSansBold
DropdownBtn.Parent = DropdownMain

local DropdownContainer = Instance.new("ScrollingFrame")
DropdownContainer.Size = UDim2.new(1, 0, 0, 150)
DropdownContainer.Position = UDim2.new(0, 0, 1, 0)
DropdownContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, #FarmSystem.Zones * 30)
DropdownContainer.ScrollBarThickness = 4
DropdownContainer.Visible = false
DropdownContainer.ZIndex = 5
DropdownContainer.Parent = DropdownMain
local DropdownList = Instance.new("UIListLayout", DropdownContainer)

for _, zoneName in ipairs(FarmSystem.Zones) do
	local ZoneOption = Instance.new("TextButton")
	ZoneOption.Size = UDim2.new(1, 0, 0, 30)
	ZoneOption.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	ZoneOption.Text = zoneName
	ZoneOption.TextColor3 = Color3.fromRGB(255, 255, 255)
	ZoneOption.Font = Enum.Font.SourceSans
	ZoneOption.ZIndex = 6
	ZoneOption.Parent = DropdownContainer
	
	ZoneOption.MouseButton1Click:Connect(function()
		HUB_CONFIG.CurrentTargetZone = zoneName
		DropdownBtn.Text = "Zone: " .. zoneName
		DropdownContainer.Visible = false
	end)
end

DropdownBtn.MouseButton1Click:Connect(function()
	DropdownContainer.Visible = not DropdownContainer.Visible
end)

-- СКРОЛЛ-ФИЛЬТР ДЛЯ РЕДКОСТЕЙ (Из Модуля Автопикапа)
local ScrollFilter = Instance.new("ScrollingFrame")
ScrollFilter.Size = UDim2.new(0.9, 0, 0, 205)
ScrollFilter.Position = UDim2.new(0.05, 0, 0, 145)
ScrollFilter.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ScrollFilter.CanvasSize = UDim2.new(0, 0, 0, #PickupSystem.Rarities * 28)
ScrollFilter.ScrollBarThickness = 4
ScrollFilter.BorderSizePixel = 0
ScrollFilter.Parent = MainPanel
local ScrollList = Instance.new("UIListLayout", ScrollFilter)
ScrollList.Padding = UDim.new(0, 4)

for _, rarity in ipairs(PickupSystem.Rarities) do
	local enabled = HUB_CONFIG.AllowedRarities[rarity]
	
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, -10, 0, 25)
	Row.BackgroundTransparency = 1
	Row.Parent = ScrollFilter
	
	local Checkbox = Instance.new("TextButton")
	Checkbox.Size = UDim2.new(0, 20, 0, 20)
	Checkbox.Position = UDim2.new(0, 5, 0, 2)
	Checkbox.BackgroundColor3 = enabled and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(80, 80, 80)
	Checkbox.Text = enabled and "✓" or ""
	Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	Checkbox.Font = Enum.Font.SourceSansBold
	Checkbox.Parent = Row
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -35, 1, 0)
	Label.Position = UDim2.new(0, 30, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = rarity
	Label.TextColor3 = PickupSystem.RarityColors[rarity] or Color3.fromRGB(255, 255, 255)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 14
	Label.Parent = Row
	
	Checkbox.MouseButton1Click:Connect(function()
		HUB_CONFIG.AllowedRarities[rarity] = not HUB_CONFIG.AllowedRarities[rarity]
		local state = HUB_CONFIG.AllowedRarities[rarity]
		Checkbox.BackgroundColor3 = state and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(80, 80, 80)
		Checkbox.Text = state and "✓" or ""
	end)
end
