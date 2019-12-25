local baton = require 'lib.baton'

return baton.new {
	controls = {
		left = {'sc:left', 'sc:a', 'axis:leftx-', 'button:dpleft'},
		right = {'sc:right', 'sc:d', 'axis:leftx+', 'button:dpright'},
		up = {'sc:up', 'sc:w', 'axis:lefty-', 'button:dpup'},
		down = {'sc:down', 'sc:s', 'axis:lefty+', 'button:dpdown'},
		dash = {'mouse:1'},
	},
	pairs = {
		move = {'left', 'right', 'up', 'down'}
	},
	joystick = love.joystick.getJoysticks()[1],
	deadzone = 1/5,
}
