local constant = require 'constant'

local mouseManager = {}

function mouseManager:getMousePosition()
	local x, y = love.mouse.getPosition()
	x = x * constant.screenWidth / love.graphics.getWidth()
	y = y * constant.screenHeight / love.graphics.getHeight()
	return x, y
end

return mouseManager
