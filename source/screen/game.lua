local constant = require 'constant'
local flux = require 'lib.flux'
local Object = require 'lib.classic'
local timer = require 'lib.timer'

local Arena = require 'class.game.arena'
local Ball = require 'class.game.ball'
local Glow = require 'shaders.glow'
local Player = require 'class.game.player'

local util = require 'util'

local Game = Object:extend()

function Game:enter()
	self.world = love.physics.newWorld(0, 0, false)
	self.world:setCallbacks(
		util.bind(self, "beginContact"),
		util.bind(self, "endContact"),
		util.bind(self, "preSolve"),
		util.bind(self, "postSolve")
	)

	self.entities = {
		Arena(self.world),
		Player(self.world, 300, constant.screenHeight / 2),
		Ball(self.world, constant.screenWidth / 2, constant.screenHeight / 2),
	}

	self.glow = Glow()
end

function Game:update(dt)
	flux.update(dt)
	timer.update(dt)

	self.world:update(dt)
	for _, entity in ipairs(self.entities) do
		if entity.update then entity:update(dt) end
	end
end

function Game:render()
	self.glow:beginRender()
	for _, entity in ipairs(self.entities) do
		if entity.draw then entity:draw() end
	end
	self.glow:endRender()
end

function Game:draw()
	self.glow:draw()
end

function Game:beginContact(a, b, coll)
	local userData_A = a:getUserData()
	local userData_B = a:getUserData()

	if userData_A and userData_A.beginContact then
		userData_A:beginContact(userData_B, coll)
	end

	if userData_B and userData_B.beginContact then
		userData_B:beginContact(userData_A, coll)
	end
end

function Game:endContact(a, b, coll)
end

function Game:preSolve(a, b, coll)
end

function Game:postSolve(a, b, coll, normalimpulse, tangentimpulse)
end



return Game
