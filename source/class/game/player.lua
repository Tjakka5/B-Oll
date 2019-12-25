local flux = require 'lib.flux'
local input = require 'input'
local Object = require 'lib.classic'
local timer = require 'lib.timer'
local Trail = require 'class.game.trail'
local util = require 'util'

local Player = Object:extend()

Player.dashing = false
Player.dashTimer = nil

Player.radius = 16
Player.restitution = 1
Player.movementSpeed = 7000
Player.linearDamping = 15

Player.dashPower = 900
Player.dashTime = 0.7
Player.dashControlMultipler = 0.2

function Player:new(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
	self.body:setBullet(true)
	self.body:setLinearDamping(self.linearDamping)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
	)
	self.fixture:setUserData(self)
	self.fixture:setRestitution(self.restitution)
	self.trail = Trail(x, y)
end

function Player:tryDash(targetX, targetY)
	-- TODO: Check if player can dash
	self:dash(targetX, targetY)
end

function Player:dash(targetX, targetY)
	if self.dashing then
		self:endDash()
	end

	local deltaX, deltaY = targetX - self.body:getX(), targetY - self.body:getY()
	deltaX, deltaY = util.trim(deltaX, deltaY, self.dashPower)

	self.dashing = true

	self.body:setLinearVelocity(0, 0)

	self.body:setLinearDamping(0)
	self.body:applyLinearImpulse(deltaX, deltaY)

	self.dashTimer = timer.during(self.dashTime, function(dt, timeLeft)
		local progress = 1 - timeLeft / self.dashTime

		local linearDamping = flux.easing["quadout"](progress) * self.linearDamping

		self.body:setLinearDamping(linearDamping)
	end, function()
		self:endDash()
	end)
end

function Player:endDash()
	if self.dashTimer then
		timer.cancel(self.dashTimer)
		self.dashTimer = nil
	end

	self.dashing = false

	self.body:setLinearDamping(self.linearDamping)
end

function Player:update(dt)
	local inputX, inputY = input:get 'move'

	local movementSpeed = self.movementSpeed
	if self.dashing then
		local progress = self.dashTimer.time / self.dashTime
		local dashControlMultipler = flux.easing["quadout"](progress)

		movementSpeed = movementSpeed * dashControlMultipler
	end

	self.body:applyForce(inputX * movementSpeed, inputY * movementSpeed)

	if input:pressed('dash') then
		local targetX, targetY = love.mouse.getPosition()
		self:tryDash(targetX, targetY)
	end

	self.trail:update(dt, self.body:getPosition())
end

function Player:draw()
	love.graphics.push 'all'
	self.trail:draw(self.fixture:getShape():getRadius())
	love.graphics.setColor(153/255, 203/255, 219/255)
	love.graphics.circle('fill', self.body:getX(), self.body:getY(),
		self.fixture:getShape():getRadius() * .75)
	love.graphics.pop()
end

return Player
