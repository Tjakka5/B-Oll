local Arena = require 'class.game.arena'
local Player = require 'class.game.player'
local util = require 'util'

local Game = util.class()

function Game:enter()
	self.world = love.physics.newWorld(0, 0, false)
	self.entities = {
		Arena(self.world),
		Player(self.world, 150, 300),
	}
end

function Game:update(dt)
	self.world:update(dt)
	for _, entity in ipairs(self.entities) do
		if entity.update then entity:update(dt) end
	end
end

function Game:draw()
	for _, entity in ipairs(self.entities) do
		if entity.draw then entity:draw() end
	end
end

return Game
