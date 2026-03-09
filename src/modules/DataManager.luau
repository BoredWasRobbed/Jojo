--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)

local DataTemplate = {
	Money = 0,
	Level = 1,
	Experience = 0,

	Stand = "None",
	StandSkin = "Default",
	PityCounter = 0,

	Inventory = {},

	Stats = {
		Strength = 1,
		Vitality = 1,
		Agility = 1,
		Worthiness = 1,
	},

	Settings = {
		MusicVolume = 1,
		SFXVolume = 1,
		TradingEnabled = true,
	},
}

local GameProfileStore = ProfileService.GetProfileStore("PlayerData_v1", DataTemplate)

local DataManager = {}
DataManager.Profiles = {} :: { [Player]: any }

DataManager.PlayerLoaded = Instance.new("BindableEvent")

local function PlayerAdded(player: Player)
	local profile: any = GameProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			DataManager.Profiles[player] = nil
			player:Kick(
				"Data session ended. Your data was loaded on another server or an error occurred. Please rejoin."
			)
		end)

		if player:IsDescendantOf(Players) then
			DataManager.Profiles[player] = profile
			print("[DataManager] Successfully loaded profile for " .. player.Name)

			DataManager.PlayerLoaded:Fire(player, profile.Data)
		else
			profile:Release()
		end
	else
		player:Kick("Could not load your game data. Please try rejoining in a moment.")
	end
end

local function PlayerRemoving(player: Player)
	local profile: any = DataManager.Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end

function DataManager.Init()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerRemoving)

	print("[DataManager] Initialized!")
end

function DataManager:GetProfile(player: Player): any
	return self.Profiles[player]
end

function DataManager:HasData(player: Player): boolean
	return self.Profiles[player] ~= nil
end

function DataManager:Get(player: Player, key: string): any
	local profile: any = self.Profiles[player]
	if profile then
		return profile.Data[key]
	end
	warn("[DataManager] Attempted to GET data for " .. player.Name .. " but profile is nil.")
	return nil
end

function DataManager:Set(player: Player, key: string, value: any)
	local profile: any = self.Profiles[player]
	if profile then
		profile.Data[key] = value
	else
		warn("[DataManager] Attempted to SET data for " .. player.Name .. " but profile is nil.")
	end
end

function DataManager:Increment(player: Player, key: string, amount: number)
	local profile: any = self.Profiles[player]
	if profile then
		if type(profile.Data[key]) == "number" then
			profile.Data[key] = (profile.Data[key] :: number) + amount
		else
			warn("[DataManager] Cannot increment a non-number key: " .. tostring(key))
		end
	else
		warn("[DataManager] Attempted to INCREMENT data for " .. player.Name .. " but profile is nil.")
	end
end

function DataManager:Update(player: Player, key: string, callback: (any) -> any)
	local profile: any = self.Profiles[player]
	if profile then
		local currentData = profile.Data[key]
		profile.Data[key] = callback(currentData)
	else
		warn("[DataManager] Attempted to UPDATE data for " .. player.Name .. " but profile is nil.")
	end
end

return DataManager
