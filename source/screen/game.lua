local Object = require 'lib.classic'

local game = Object:extend()

function game:draw()
	love.graphics.print 'hi!'
end

return game
