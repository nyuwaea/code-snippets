--[[
		Very simple module to avoid DataStore warnings, most likely subject to change
]]

------------► ► ►	 MODULE		◄ ◄ ◄------------

local DataQueuer = {}
DataQueuer.__index = DataQueuer

function DataQueuer.Init(): {}
	local self = setmetatable({}, DataQueuer)
	
	self._queue = {}
	
	coroutine.wrap(function()
		while task.wait(7) do
			self:Process()
		end
	end)()
		
	return self
end

function DataQueuer:Process(): ()
	if self._queue[1] then
		self._queue[1]()
		
		for i = 2, #self._queue do
			self._queue[i - 1] = self._queue[i]
		end
		
		self._queue[#self._queue] = nil
	end
end

function DataQueuer:Queue(func: (...any?) -> (...any?)): ()
	self._queue[#self._queue + 1] = func
end

return DataQueuer.Init()
