local Object = require 'lib.classic'
local Trail = require 'class.game.trail'

local Ball = Object:extend()

Ball.radius = 48
Ball.restitution = 1
Ball.linearDamping = 4

function Ball:new(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.body:setBullet(true)
	self.body:setLinearDamping(self.linearDamping)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
    )
    self.fixture:setUserData(self)
	self.fixture:setRestitution(self.restitution)
	self.body:setMass(self.body:getMass() * .5)
	self.trail = Trail(x, y)
end

function Ball:update(dt)
	self.trail:update(dt, self.body:getPosition())
end

function Ball:draw()
	love.graphics.push 'all'
	self.trail:draw(self.fixture:getShape():getRadius())
	love.graphics.setColor(153/255, 203/255, 219/255)
	love.graphics.circle('fill', self.body:getX(), self.body:getY(),
		self.fixture:getShape():getRadius() * .75)
	love.graphics.pop()
end

return Ball
