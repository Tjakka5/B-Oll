local util = {}

function util.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function util.lerp(a, b, amount)
	return a + (b - a) * amount
end

return util
