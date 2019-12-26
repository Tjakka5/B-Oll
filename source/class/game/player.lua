local flux = require 'lib.flux'
local input = require 'input'
local mouseManager = require 'mouse-manager'
local Object = require 'lib.classic'
local Trail = require 'class.game.trail'
local util = require 'util'

local Player = Object:extend()

Player.dashing = false
Player.dashTimer = nil

Player.radius = 64
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
	local deltaX, deltaY = targetX - self.body:getX(), targetY - self.body:getY()
	deltaX, deltaY = util.trim(deltaX, deltaY, self.dashPower)
	self.body:setLinearVelocity(0, 0)
	self.body:setLinearDamping(0)
	self.body:applyLinearImpulse(deltaX, deltaY)
	self.dashTimer = self.dashTime
end

function Player:update(dt)
	local movementSpeed = self.movementSpeed

	-- update dash timer
	if self.dashTimer then
		self.dashTimer = self.dashTimer - dt
		if self.dashTimer <= 0 then
			-- end the dash and reset movement parameters
			self.dashTimer = false
			self.body:setLinearDamping(self.linearDamping)
		else
			-- while dashing, set some movement parameters
			local progress = 1 - self.dashTimer / self.dashTime
			local linearDamping = flux.easing.quadout(progress) * self.linearDamping
			self.body:setLinearDamping(linearDamping)
			local dashControlMultipler = flux.easing.quadout(progress)
			movementSpeed = movementSpeed * dashControlMultipler
		end
	end

	-- movement
	local inputX, inputY = input:get 'move'
	self.body:applyForce(inputX * movementSpeed, inputY * movementSpeed)

	-- start dashes
	if input:pressed('dash') then
		local targetX, targetY = mouseManager:getMousePosition()
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
