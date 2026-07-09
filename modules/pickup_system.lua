-- [[ GitHub: modules/pickup_system.lua ]]
local PickupSystem = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Правильный порядок редкостей по возрастанию
PickupSystem.Rarities = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Mythic",
	"Secret",
	"Godly",
	"Divine"
}

-- Цвета для кастомизации (можно использовать в GUI или ESP)
PickupSystem.RarityColors = {
	Common    = Color3.fromRGB(200, 200, 200),
	Uncommon  = Color3.fromRGB(85, 255, 127),
	Rare      = Color3.fromRGB(0, 170, 255),
	Epic      = Color3.fromRGB(170, 0, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic    = Color3.fromRGB(255, 0, 127),
	Secret    = Color3.fromRGB(0, 255, 255),
	Godly     = Color3.fromRGB(255, 255, 0),
	Divine    = Color3.fromRGB(255, 0, 0)
}

function PickupSystem.GetRarity(object, filterConfig)
	local itemStats = object:FindFirstChild("ItemStats", true)
	if itemStats and itemStats:FindFirstChild("BillboardGui") then
		local rarityGui = itemStats.BillboardGui:FindFirstChild("Rarity")
		if rarityGui then
			for _, rarityName in ipairs(PickupSystem.Rarities) do
				if rarityGui:FindFirstChild(rarityName) then 
					return rarityName 
				end
			end
		end
	end
	return "Common"
end

function PickupSystem.Init(config)
	Workspace.DescendantAdded:Connect(function(object)
		if not object:IsA("Model") and not object:IsA("BasePart") then return end
		local prompt = object:FindFirstChildOfClass("ProximityPrompt", true) or object:WaitForChild("ProximityPrompt", 2)
		
		if prompt and prompt:IsA("ProximityPrompt") then
			local rarity = PickupSystem.GetRarity(object)
			
			task.spawn(function()
				while object:IsDescendantOf(Workspace) do
					-- Проверяем, включен ли автопикап общим рубильником и разрешена ли эта редкость в GUI
					if config.AutoPickupEnabled and config.AllowedRarities[rarity] then
						prompt:InputHoldBegin()
						task.wait(prompt.HoldDuration)
						prompt:InputHoldEnd()
					end
					task.wait(0.05)
				end
			end)
		end
	end)
end

return PickupSystem
