-- ground.lua - The ground that destroys books
local Ground = {}
local Ground_mt = { __index = Ground }

function Ground.create(world)
	local self = {}
	setmetatable(self, Ground_mt)

	-- Create physical body
	self.body = love.physics.newBody(world, 650 / 2, 674)
	self.shape = love.physics.newRectangleShape(650, 50)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setFriction(0.1)
	self.fixture:setUserData("ground")

	return self
end

function Ground:draw()
	love.graphics.setColor(0.28, 0.63, 0.05)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Ground
