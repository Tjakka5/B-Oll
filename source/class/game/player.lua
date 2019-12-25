local input = require 'input'
local Object = require 'lib.classic'

local Player = Object:extend()

Player.radius = 16
Player.restitution = 2
Player.movementSpeed = 1500
Player.linearDamping = 5

function Player:new(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
	self.body:setLinearDamping(self.linearDamping)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
	)
	self.fixture:setRestitution(self.restitution)
end

function Player:update(dt)
	local inputX, inputY = input:get 'move'
	self.body:applyForce(inputX * self.movementSpeed, inputY * self.movementSpeed)
end

function Player:draw()
	love.graphics.push 'all'
	love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.fixture:getShape():getRadius())
	love.graphics.pop()
end

return Player
