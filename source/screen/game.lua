local constant = require 'constant'
local flux = require 'lib.flux'
local Object = require 'lib.classic'
local timer = require 'lib.timer'

local Arena = require 'class.game.arena'
local Ball = require 'class.game.ball'
local Glow = require 'shaders.glow'
local Grid = require 'class.game.grid'
local Player = require 'class.game.player'

local util = require 'util'

local Game = Object:extend()

function Game:enter()
	love.physics.setMeter(240)
	self.world = love.physics.newWorld(0, 0, false)
	self.world:setCallbacks(
		util.bind(self, "beginContact"),
		util.bind(self, "endContact"),
		util.bind(self, "preSolve"),
		util.bind(self, "postSolve")
	)

	self.entities = {}
	table.insert(self.entities, Arena(self.world))
	table.insert(self.entities, Player(self.world, 300, constant.screenHeight / 2))
	table.insert(self.entities, Ball(self.world, constant.screenWidth / 2, constant.screenHeight / 2))
	table.insert(self.entities, Grid(self.entities))

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

function Game:draw()
	self.glow:beginRender()
	love.graphics.push 'all'
	love.graphics.scale(math.min(love.graphics.getWidth() / constant.screenWidth,
		love.graphics.getHeight() / constant.screenHeight))
	for _, entity in ipairs(self.entities) do
		if entity.draw then entity:draw() end
	end
	love.graphics.pop()
	self.glow:endRender()
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
