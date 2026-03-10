local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules:WaitForChild("CombatConfig"))

local assetsToLoad = {}

for animName, animId in pairs(Config.PlayerAnimations) do
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	anim.Name = animName
	table.insert(assetsToLoad, anim)
end

for animName, animId in pairs(Config.StandAnimations) do
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	anim.Name = animName
	table.insert(assetsToLoad, anim)
end

for soundName, soundId in pairs(Config.Sounds) do
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Name = soundName
	table.insert(assetsToLoad, sound)
end

local assetsFolder = ReplicatedStorage:WaitForChild("Assets")
local vfxFolder = assetsFolder:WaitForChild("VFX", 5)

if vfxFolder then
	for _, descendant in ipairs(vfxFolder:GetDescendants()) do
		if
			descendant:IsA("ParticleEmitter")
			or descendant:IsA("Sound")
			or descendant:IsA("Texture")
			or descendant:IsA("Decal")
		then
			table.insert(assetsToLoad, descendant)
		end
	end
else
	warn("[AssetLoader] VFX folder not found in ReplicatedStorage.Assets!")
end

print("[AssetLoader] Starting to preload " .. #assetsToLoad .. " combat assets...")

local success, errorMessage = pcall(function()
	ContentProvider:PreloadAsync(assetsToLoad)
end)

if success then
	print("[AssetLoader] Successfully preloaded all combat assets!")
else
	warn("[AssetLoader] Failed to preload some assets: " .. tostring(errorMessage))
end
