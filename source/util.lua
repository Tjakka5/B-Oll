local util = {}

function util.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function util.length(x, y)
	return math.sqrt(x * x + y * y)
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

return util
