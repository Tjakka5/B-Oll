local input = require 'input'
local Object = require 'lib.classic'
local util = require 'util'
local timer = require 'lib.timer'
local flux = require 'lib.flux'

local trailShader = love.graphics.newShader("shaders/trail.glsl")

local Player = Object:extend()

Player.dashing = false
Player.dashTimer = nil

Player.radius = 16
Player.restitution = 2
Player.movementSpeed = 10000
Player.linearDamping = 25

Player.numberOfTrailPoints = 20
Player.trailLerpSpeed = 60

Player.dashPower = 3000
Player.dashTime = 0.2
Player.dashControlMultipler = 0.2

function Player:initializeBody(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
	self.body:setLinearDamping(self.linearDamping)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newCircleShape(self.radius)
	)
	self.fixture:setRestitution(self.restitution)
end

function Player:initializeTrail()
	self.trailPoints = {}
	for i = 1, self.numberOfTrailPoints do
		table.insert(self.trailPoints, {
			x = self.body:getX(),
			y = self.body:getY(),
			radius = util.lerp(1, 0, (i - 1) / (self.numberOfTrailPoints - 1)),
		})
	end
end

function Player:new(world, x, y)
	self:initializeBody(world, x, y)
	self:initializeTrail()
end

function Player:updateTrail(dt)
	for i = #self.trailPoints, 2, -1 do
		local current = self.trailPoints[i]
		local next = self.trailPoints[i - 1]
		current.x = util.lerp(current.x, next.x, self.trailLerpSpeed * dt)
		current.y = util.lerp(current.y, next.y, self.trailLerpSpeed * dt)
	end
	self.trailPoints[1].x, self.trailPoints[1].y = self.body:getPosition()
end

function Player:tryDash(targetX, targetY)
	-- TODO: Check if player can dash
	self:dash(targetX, targetY)
end

function Player:dash(targetX, targetY)
	if self.dashTimer then
		timer.cancel(self.dashTimer)
		self.dashTimer = nil
	end

	local deltaX, deltaY = targetX - self.body:getX(), targetY - self.body:getY()
	deltaX, deltaY = util.trim(deltaX, deltaY, self.dashPower)

	self.dashing = true

	self.body:setLinearVelocity(0, 0)

	self.body:setLinearDamping(0)
	self.body:applyLinearImpulse(deltaX, deltaY)

	self.dashTimer = timer.during(self.dashTime, function(dt, timeLeft)
		local progress = 1 - timeLeft / self.dashTime
		local linearDamping = flux.easing["quartout"](progress) * self.linearDamping

		self.body:setLinearDamping(linearDamping)
	end, function()
		self:endDash()
		self.dashTimer = nil
	end)
end

function Player:endDash()
	self.dashing = false


	self.body:setLinearDamping(self.linearDamping)
end

function Player:update(dt)
	local inputX, inputY = input:get 'move'

	local movementSpeed = self.movementSpeed
	if self.dashing then
		movementSpeed = movementSpeed * self.dashControlMultipler
	end

	self.body:applyForce(inputX * movementSpeed, inputY * movementSpeed)
	self:updateTrail(dt)

	if input:pressed('dash') then
		local targetX, targetY = love.mouse.getPosition()
		self:tryDash(targetX, targetY)
	end
end

function Player:drawTrail()
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

function Player:draw()
	love.graphics.push 'all'
	self:drawTrail()
	love.graphics.setColor(153/255, 203/255, 219/255)
	love.graphics.circle('fill', self.body:getX(), self.body:getY(),
		self.fixture:getShape():getRadius() * .75)
	love.graphics.pop()
end

return Player
