local input = require 'input'
local Object = require 'lib.classic'
local util = require 'util'
local timer = require 'lib.timer'
local flux = require 'lib.flux'

local trailShader = love.graphics.newShader("shaders/trail.glsl")

local Player = Object:extend()

Player.dashing = false
Player.dashTimer = nil

Player.radius = 24
Player.restitution = 1
Player.movementSpeed = 7000
Player.linearDamping = 15

Player.numberOfTrailPoints = 20
Player.trailLerpSpeed = 60

Player.dashPower = 900
Player.dashTime = 0.7
Player.dashControlMultipler = 0.2

function Player:initializeBody(world, x, y)
	self.body = love.physics.newBody(world, x, y, 'dynamic')
	self.body:setBullet(true)
	self.body:setLinearDamping(self.linearDamping)
	self.body:setFixedRotation(true)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newPolygonShape(
			self.radius, 0,
			-self.radius/2, -self.radius,
			-self.radius, 0,
			-self.radius/2, self.radius
		)
	)
	self.fixture:setUserData(self)
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
	if util.length2(self.body:getLinearVelocity()) > 0 then
		self.body:setAngle(util.lerpAngle(
			self.body:getAngle(),
			util.angle(self.body:getLinearVelocity()) + math.pi,
			10 * dt
		))
	end
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

	local radius = self.radius
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
	love.graphics.translate(self.body:getPosition())
	love.graphics.rotate(self.body:getAngle())
	love.graphics.polygon('fill', self.fixture:getShape():getPoints())
	love.graphics.pop()
end

return Player
