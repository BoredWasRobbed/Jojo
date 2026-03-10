local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)

DataManager.Init()

DataManager.PlayerLoaded.Event:Connect(function(player: Player, data)
	if #data.Inventory == 0 then
		DataManager:Update(player, "Inventory", function(inventory)
			table.insert(inventory, "Mysterious Arrow")
			return inventory
		end)
		print("Gave " .. player.Name .. " a starting Mysterious Arrow!")
	end
end)

-- DataManager:Get(player, "Money")
-- DataManager:Increment(player, "Money", 100)
-- DataManager:Set(player, "Stand", "The World")
