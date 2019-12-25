local util = {}

function util.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function util.lerp(a, b, amount)
	return a + (b - a) * amount
end

function util.class(parent)
	local class = {}
	class.__index = class
	setmetatable(class, {
		__index = parent,
		__call = function(self, ...)
			local instance = setmetatable({}, self)
			if instance.new then instance:new(...) end
			return instance
		end,
	})
	return class
end

return util
