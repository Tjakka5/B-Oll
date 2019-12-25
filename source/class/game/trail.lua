local Object = require 'lib.classic'
local util = require 'util'

local Trail = Object:extend()

Trail.numberOfPoints = 20
Trail.lerpSpeed = 60

local trailShader = love.graphics.newShader("shaders/trail.glsl")

function Trail:new(x, y)
	self.trailPoints = {}
	for i = 1, self.numberOfPoints do
		table.insert(self.trailPoints, {
			x = x,
			y = y,
			radius = util.lerp(1, 0, (i - 1) / (self.numberOfPoints - 1)),
		})
	end
end

function Trail:update(dt, x, y)
	for i = #self.trailPoints, 2, -1 do
		local current = self.trailPoints[i]
		local next = self.trailPoints[i - 1]
		current.x = util.lerp(current.x, next.x, self.lerpSpeed * dt)
		current.y = util.lerp(current.y, next.y, self.lerpSpeed * dt)
	end
	self.trailPoints[1].x, self.trailPoints[1].y = x, y
end

function Trail:draw(radius)
	love.graphics.push 'all'
	love.graphics.setShader(trailShader)
	if trailShader:hasUniform('origin') then
		trailShader:send('origin', {self.trailPoints[1].x, self.trailPoints[1].y})
	end
	for i, point in ipairs(self.trailPoints) do
		local next = self.trailPoints[i + 1]
		-- draw circles for each trail point
		love.graphics.circle('fill', point.x, point.y, radius * point.radius)
		-- draw polygons connecting each circle at the sides
		if i < #self.trailPoints then
			local angle = util.angle(point.x, point.y, next.x, next.y)
			local x1 = point.x + radius * point.radius * math.cos(angle + math.pi/2)
			local y1 = point.y + radius * point.radius * math.sin(angle + math.pi/2)
			local x2 = point.x + radius * point.radius * math.cos(angle - math.pi/2)
			local y2 = point.y + radius * point.radius * math.sin(angle - math.pi/2)
			local x3 = next.x + radius * next.radius * math.cos(angle - math.pi/2)
			local y3 = next.y + radius * next.radius * math.sin(angle - math.pi/2)
			local x4 = next.x + radius * next.radius * math.cos(angle + math.pi/2)
			local y4 = next.y + radius * next.radius * math.sin(angle + math.pi/2)
			love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4)
		end
	end
	love.graphics.pop()
end

return Trail
