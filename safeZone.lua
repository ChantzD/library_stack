-- safeZone.lua - Area where books are counted for score
local SafeZone = {}
local SafeZone_mt = { __index = SafeZone }

function SafeZone.create(world)
	local self = {}
	setmetatable(self, SafeZone_mt)

	-- Create physical body
	self.body = love.physics.newBody(world, 0, 650 / 2, "static")
	self.shape = love.physics.newRectangleShape(50, 650)
	self.fixture = love.physics.newFixture(self.body, self.shape, 0)
	self.fixture:setSensor(true)
	self.fixture:setUserData("safeZone")

	return self
end

function SafeZone:draw()
	love.graphics.setColor(0, 1, 0, 0.3)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return SafeZone
