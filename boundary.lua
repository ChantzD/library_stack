-- boundary.lua - Area where books are counted for score
local Boundary = {}
local Boundary_mt = { __index = Boundary }

function Boundary.create(world, x, y)
	local self = {}
	setmetatable(self, Boundary_mt)

	-- Create physical body
	self.body = love.physics.newBody(world, x, y, "static")
	self.shape = love.physics.newRectangleShape(10, 650)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData("Boundary")

	return self
end

function Boundary:draw()
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Boundary
