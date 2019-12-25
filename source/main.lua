local game = require 'screen.game'
local input = require 'input'
local screenManager = require 'screen-manager'

function love.load()
	screenManager:hook()
	screenManager:enter(game)
end

function love.update(dt)
	input:update()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end
