local constant = require 'constant'
local Object = require 'lib.classic'
local util = require 'util'

local Grid = Object:extend()

Grid.columns = 32
Grid.rows = 16
Grid.entityAttraction = 200000
Grid.anchorAttraction = 2

function Grid:new(entities)
	self.entities = entities
	self.points = {}
	for column = 0, self.columns do
		self.points[column] = {}
		for row = 0, self.rows do
			local x = constant.screenWidth / self.columns * column
			local y = constant.screenHeight / self.rows * row
			self.points[column][row] = {
				anchorX = x,
				anchorY = y,
				x = x,
				y = y,
			}
		end
	end
end

function Grid:update(dt)
	for column = 1, self.columns - 1 do
		for row = 1, self.rows - 1 do
			local point = self.points[column][row]
			if point.fixed then goto pointIsFixed end
			for _, entity in ipairs(self.entities) do
				if not entity.body then goto entityIsNotPhysical end
				local entityX, entityY = entity.body:getPosition()
				local entityMass = entity.body:getMass()
				local distance = util.distanceSquared(point.anchorX, point.anchorY, entityX, entityY)
				local entityLerpAmount = util.clamp(self.entityAttraction * entityMass / math.max(distance, 1) * dt, 0, 1)
				point.x = util.lerp(point.x, entityX, entityLerpAmount)
				point.y = util.lerp(point.y, entityY, entityLerpAmount)
				local anchorLerpAmount = util.clamp(self.anchorAttraction * dt, 0, 1)
				point.x = util.lerp(point.x, point.anchorX, anchorLerpAmount)
				point.y = util.lerp(point.y, point.anchorY, anchorLerpAmount)
				::entityIsNotPhysical::
			end
			::pointIsFixed::
		end
	end
end

function Grid:draw()
	love.graphics.push 'all'
	love.graphics.setColor(1, 1, 1, 1/3)
	for column = 0, self.columns do
		for row = 0, self.rows do
			love.graphics.circle('fill', self.points[column][row].x, self.points[column][row].y, 8)
			if column < self.columns then
				love.graphics.line(
					self.points[column][row].x, self.points[column][row].y,
					self.points[column + 1][row].x, self.points[column + 1][row].y
				)
			end
			if row < self.rows then
				love.graphics.line(
					self.points[column][row].x, self.points[column][row].y,
					self.points[column][row + 1].x, self.points[column][row + 1].y
				)
			end
		end
	end
	love.graphics.pop()
end

return Grid
