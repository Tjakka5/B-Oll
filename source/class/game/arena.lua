local util = require 'util'

local Arena = util.class()

function Arena:new(world)
	self.body = love.physics.newBody(world)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newChainShape(true, 50, 50, 750, 50, 750, 550, 50, 550)
	)
end

function Arena:draw()
	love.graphics.push 'all'
	love.graphics.setLineWidth(4)
	love.graphics.line(self.fixture:getShape():getPoints())
	love.graphics.pop()
end

return Arena
