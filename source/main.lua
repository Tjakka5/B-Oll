local constant = require 'constant'
local game = require 'screen.game'
local input = require 'input'
local screenManager = require 'screen-manager'

function love.load()
	screenManager:hook {exclude = {'draw'}}
	screenManager:enter(game)
end

function love.update(dt)
	input:update()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	screenManager:emit 'render'
	love.graphics.push 'all'
	love.graphics.scale(math.min(love.graphics.getWidth() / constant.screenWidth,
		love.graphics.getHeight() / constant.screenHeight))
	screenManager:emit 'draw'
	love.graphics.pop()
	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
