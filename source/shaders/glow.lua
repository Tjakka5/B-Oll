local Object = require 'lib.classic'

local Glow = Object:extend()

Glow.defaultIterations = 32
Glow.defaultStrength = 2

function Glow:new(iterations, strength)
	self.iterations = iterations or self.defaultIterations
	self.strength = strength or self.defaultStrength
	self.unblurredCanvas = love.graphics.newCanvas()
	self.horizontalBlurCanvas = love.graphics.newCanvas()
	self.bothBlurCanvas = love.graphics.newCanvas()
	self.horizontalBlurShader = love.graphics.newShader 'shaders/blur.glsl'
	self.horizontalBlurShader:send('textureWidth', love.graphics.getWidth())
	self.horizontalBlurShader:send('textureHeight', love.graphics.getHeight())
	self.verticalBlurShader = love.graphics.newShader 'shaders/blur.glsl'
	self.verticalBlurShader:send('vertical', true)
	self.verticalBlurShader:send('textureWidth', love.graphics.getWidth())
	self.verticalBlurShader:send('textureHeight', love.graphics.getHeight())
end

function Glow:beginDraw()
	love.graphics.push 'all'
	love.graphics.setCanvas(self.unblurredCanvas)
	love.graphics.clear()
end

function Glow:endDraw()
	for i = 1, self.iterations do
		love.graphics.setCanvas(self.horizontalBlurCanvas)
		if i == 1 then love.graphics.clear() end
		love.graphics.setShader(self.horizontalBlurShader)
		love.graphics.draw(i == 1 and self.unblurredCanvas or self.bothBlurCanvas)
		love.graphics.setCanvas(self.bothBlurCanvas)
		if i == 1 then love.graphics.clear() end
		love.graphics.setShader(self.verticalBlurShader)
		love.graphics.draw(self.horizontalBlurCanvas)
	end
	love.graphics.setCanvas()
	love.graphics.setShader()
	love.graphics.draw(self.unblurredCanvas)
	love.graphics.setBlendMode 'add'
	for _ = 1, self.strength do
		love.graphics.draw(self.bothBlurCanvas)
	end
	love.graphics.pop()
end

return Glow
