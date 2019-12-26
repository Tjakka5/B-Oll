local constant = require 'constant'
local Object = require 'lib.classic'

local Glow = Object:extend()

Glow.defaultIterations = 16
Glow.defaultStrength = 4
Glow.defaultSpread = 8

function Glow:initializeCanvases()
	self.unblurredCanvas = love.graphics.newCanvas()
	self.horizontalBlurCanvas = love.graphics.newCanvas()
	self.bothBlurCanvas = love.graphics.newCanvas()
end

function Glow:initializeShaders(spread)
	self.horizontalBlurShader = love.graphics.newShader 'shaders/blur.glsl'
	self.horizontalBlurShader:send('textureWidth', constant.screenWidth)
	self.horizontalBlurShader:send('textureHeight', constant.screenHeight)
	self.horizontalBlurShader:send('spread', spread or self.defaultSpread)
	self.verticalBlurShader = love.graphics.newShader 'shaders/blur.glsl'
	self.verticalBlurShader:send('vertical', true)
	self.verticalBlurShader:send('textureWidth', constant.screenWidth)
	self.verticalBlurShader:send('textureHeight', constant.screenHeight)
	self.verticalBlurShader:send('spread', spread or self.defaultSpread)
end

function Glow:new(iterations, strength, spread)
	self.iterations = iterations or self.defaultIterations
	self.strength = strength or self.defaultStrength
	self:initializeCanvases()
	self:initializeShaders(spread)
end

function Glow:beginRender()
	love.graphics.push 'all'
	love.graphics.setCanvas(self.unblurredCanvas)
	love.graphics.clear()
end

function Glow:endRender()
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
	love.graphics.pop()
end

function Glow:draw()
	love.graphics.push 'all'
	love.graphics.draw(self.unblurredCanvas)
	love.graphics.setBlendMode 'add'
	for _ = 1, self.strength do
		love.graphics.draw(self.bothBlurCanvas)
	end
	love.graphics.pop()
end

return Glow
