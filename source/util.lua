local util = {}

function util.sign(x)
	return x < 0 and -1 or 1
end

function util.angle(x1, y1, x2, y2)
	x2, y2 = x2 or 0, y2 or 0
	return math.atan2(y2 - y1, x2 - x1)
end

function util.length2(x, y)
	return x * x + y * y
end

function util.length(x, y)
	return math.sqrt(util.length2(x, y))
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

function util.lerpAngle(a, b, amount)
	if math.abs(a - b) > math.pi then
		b = b + 2 * math.pi * util.sign(a - b)
	end
	return util.lerp(a, b, amount)
end

function util.bind(o, fnName)
	return function(...) return o[fnName](o, ...) end
end

return util
