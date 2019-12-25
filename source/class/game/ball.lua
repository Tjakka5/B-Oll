local Object = require 'lib.classic'
local util = require 'util'

local trailShader = love.graphics.newShader("shaders/trail.glsl")

local Ball = Object:extend()

Ball.radius = 12
Ball.restitution = 1
Ball.linearDamping = 4

Ball.numberOfTrailPoints = 20
Ball.trailLerpSpeed = 60

function Ball:initializeBody(world, x, y)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.body:setBullet(true)
	self.body:setLinearDamping(self.linearDamping)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
    )
    self.fixture:setUserData(self)
	self.fixture:setRestitution(self.restitution)
end

function Ball:initializeTrail()
	self.trailPoints = {}
	for i = 1, self.numberOfTrailPoints do
		table.insert(self.trailPoints, {
			x = self.body:getX(),
			y = self.body:getY(),
			radius = util.lerp(1, 0, (i - 1) / (self.numberOfTrailPoints - 1)),
		})
	end
end

function Ball:new(world, x, y)
	self:initializeBody(world, x, y)
	self:initializeTrail()
end

function Ball:updateTrail(dt)
	for i = #self.trailPoints, 2, -1 do
		local current = self.trailPoints[i]
		local next = self.trailPoints[i - 1]
		current.x = util.lerp(current.x, next.x, self.trailLerpSpeed * dt)
		current.y = util.lerp(current.y, next.y, self.trailLerpSpeed * dt)
	end
	self.trailPoints[1].x, self.trailPoints[1].y = self.body:getPosition()
end

function Ball:update(dt)
	self:updateTrail(dt)
end

function Ball:drawTrail()
	love.graphics.push 'all'

	love.graphics.setShader(trailShader)

	if trailShader:hasUniform("player_coords") then
		trailShader:send("player_coords", {self.body:getX(), self.body:getY()})
	end

	local radius = self.fixture:getShape():getRadius()
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

function Ball:draw()
	love.graphics.push 'all'
	self:drawTrail()
	love.graphics.setColor(153/255, 203/255, 219/255)
	love.graphics.circle('fill', self.body:getX(), self.body:getY(),
		self.fixture:getShape():getRadius() * .75)
	love.graphics.pop()
end

return Ball
