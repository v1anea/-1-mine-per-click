-- [[ GitHub: modules/farm_system.lua ]]
local FarmSystem = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Твой точный список зон по порядку
FarmSystem.Zones = {
	-- 🟢 Бесплатные зоны (для апа и перерождений)
	"Coal Ore",
	"Gold Ore",
	"Iron Ore",
	"Quartz Ore",
	"Diamond Ore",
	"Demonite",
	-- 🔵 Продвинутые зоны
	"Amethyst",
	"Emerald",
	"Azurite"
}

function FarmSystem.StartLoop(config)
	-- Защита от AFK-кика
	LocalPlayer.Idled:Connect(function()
		VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
	end)

	task.spawn(function()
		while true do
			task.wait(0.05)
			
			if config.AutoFarmEnabled then
				local character = LocalPlayer.Character
				local hrp = character and character:FindFirstChild("HumanoidRootPart")
				local trainingAreas = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Training Areas")
				
				if trainingAreas and hrp then
					-- Подтягиваем зону, которую юзер выбрал в выпадающем списке
					local targetZone = trainingAreas:FindFirstChild(config.CurrentTargetZone)
					local hitbox = targetZone and targetZone:FindFirstChild("Hitbox")
					
					if hitbox and hitbox:IsA("BasePart") then
						hrp.CFrame = hitbox.CFrame
						VirtualUser:CaptureController()
						VirtualUser:ClickButton1(Vector2.new(0, 0))
					end
				end
			end
		end
	end)
end

return FarmSystem
