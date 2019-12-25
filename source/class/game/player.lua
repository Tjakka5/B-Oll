local Object = require 'lib.classic'

local Player = Object:extend()

Player.radius = 16

function Player:new(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
	)
end

function Player:draw()
	love.graphics.push 'all'
	love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.fixture:getShape():getRadius())
	love.graphics.pop()
end

return Player
