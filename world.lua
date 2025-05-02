-- world.lua - Manages the physics world
local GameWorld = {}

function GameWorld.create(gravityX, gravityY)
	local world = love.physics.newWorld(gravityX, gravityY, true)

	-- Set collision callbacks
	world:setCallbacks(beginContact, endContact, nil, nil)

	return world
end

return GameWorld
