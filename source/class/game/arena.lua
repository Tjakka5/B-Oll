local constant = require 'constant'
local Object = require 'lib.classic'

local Arena = Object:extend()

function Arena:new(world)
	self.body = love.physics.newBody(world)
	self.fixture = love.physics.newFixture(
		self.body,
		love.physics.newChainShape(true,
			200, 200,
			constant.screenWidth - 200, 200,
			constant.screenWidth - 200, constant.screenHeight - 200,
			200, constant.screenHeight - 200
		)
	)
	self.fixture:setUserData(self)
end

function Arena:draw()
	love.graphics.push 'all'
	love.graphics.setLineWidth(16)
	love.graphics.line(self.fixture:getShape():getPoints())
	love.graphics.pop()
end

return Arena
