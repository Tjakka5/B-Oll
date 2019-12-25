local Object = require 'lib.classic'
local flux = require 'lib.flux'
local timer = require 'lib.timer'
local moonshine = require 'lib.moonshine'

local Arena = require 'class.game.arena'
local Player = require 'class.game.player'
local Ball = require 'class.game.ball'

local util = require 'util'

local Game = Object:extend()

Game.glowShader = moonshine(moonshine.effects.glow)
Game.glowShader.parameters = {
	glow = {
		min_luma = 0,
		strength = 5,
	}
}

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
		Player(self.world, 150, 300),
		Ball(self.world, 350, 300),
	}

	self.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
end

function Game:update(dt)
	flux.update(dt)
	timer.update(dt)

	self.world:update(dt)
	for _, entity in ipairs(self.entities) do
		if entity.update then entity:update(dt) end
	end
end

function Game:draw()
	self.glowShader.draw(function()
		for _, entity in ipairs(self.entities) do
			if entity.draw then entity:draw() end
		end
	end)
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
