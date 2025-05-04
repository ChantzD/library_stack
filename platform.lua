-- platform.lua - Player-controlled platform
local Platform = {}
local Platform_mt = { __index = Platform }

local MOVE_FORCE = 1000

function Platform.create(world)
	local self = {}
	setmetatable(self, Platform_mt)

	-- Create physical body
	self.body = love.physics.newBody(world, 650 / 2, 625, "dynamic")
	self.shape = love.physics.newRectangleShape(200, 25)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData("platform")

	self.inSafeZone = false

	return self
end

function Platform:update(dt)
	-- Handle keyboard input
	if love.keyboard.isDown("right") then
		self.body:applyForce(MOVE_FORCE, 0)
	elseif love.keyboard.isDown("left") then
		self.body:applyForce(-MOVE_FORCE, 0)
	end
end

function Platform:draw()
	love.graphics.setColor(0.28, 0.28, 0.28)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

function Platform:setInSafeZone(status)
	self.inSafeZone = status
end

function Platform:isInSafeZone()
	return self.inSafeZone
end

return Platform
