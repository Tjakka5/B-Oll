local util = {}

function util.clamp(x, min, max)
	return x < min and min or x > max and max or x
end

function util.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function util.lengthSquared(x, y)
	return x * x + y * y
end

function util.length(x, y)
	return math.sqrt(util.lengthSquared(x, y))
end

function util.distanceSquared(x1, y1, x2, y2)
	return util.lengthSquared(x2 - x1, y2 - y1)
end

function util.distance(x1, y1, x2, y2)
	return util.length(x2 - x1, y2 - y1)
end

function util.normalize(x, y)
	local magnitude = util.length(x, y)
	if magnitude > 0 then
		return x / magnitude, y / magnitude
	end
	return x, y
end

function util.trim(x, y, length)
	x, y = util.normalize(x, y)
	return x * length, y * length
end

function util.lerp(a, b, amount)
	return a + (b - a) * amount
end

function util.bind(o, fnName)
	return function(...) return o[fnName](o, ...) end
end

return util
