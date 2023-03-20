--[[
		This module handles all the assets to be used in a procedural generation game
]]

local Registry = {}
Registry.__index = Registry

local AssetObjects = game:GetService("ServerStorage").Assets

function Registry.Setup()
	local self = setmetatable({}, Registry)

	self._assets = {}				-- The main table containing all assets
	self._difficulties = {}			-- The table containing indexable difficulties
	self._tags = {}					-- The table containing all tags, similarly to CollectionService
	
	self:Add(1, "Start", 0, 0, 0, false, {})
	self:Add(2, "Flat", 1, 2, 0, false, {})
	self:Add(3, "Gap1", 1, 1, 0, false, {})
	self:Add(4, "Bridge", 1, 1, 0, true, {})
	self:Add(5, "Tall", 1, 1, 2, false, {})
	
	-- Debug assets
	
	self:Add(-1, "Debug1", 1, 1, 0, false, {"Debug";})
	self:Add(-2, "Debug2", 1, 1, 1, false, {"Debug";})

	return self
end

function Registry:Add(ID : number, name : string, difficulty : number, probability : number, heightIncrement : number, canGenerate : boolean, tags : {})
	self._assets[ID] = {name = name; probability = probability; heightIncrement = heightIncrement; canGenerate = canGenerate; object = AssetObjects[name]; starts = AssetObjects[name].Technical.Starts:GetChildren(); exits = AssetObjects[name].Technical.Exits:GetChildren()}
	self._difficulties[difficulty] = self._difficulties[difficulty] or {}
	
	for i = 1, probability do
		self._difficulties[difficulty][#self._difficulties[difficulty] + 1] = self._assets[ID]

		for _, tag in ipairs(tags) do
			self._tags[tag] = self._tags[tag] or {}		
			self._tags[tag][#self._tags[tag] + 1] = self._assets[ID]
		end
	end
end

function Registry:Get(ID : number?)
	return ID and self._assets[ID] or self._assets
end

function Registry:GetDifficulty(difficulty : number)
	return self._difficulties[difficulty]
end

function Registry:GetTag(tag : string)
	return self._tags[tag]
end

return Registry
