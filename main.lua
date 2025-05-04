-- Main entry point file
local GameWorld = require("world")
local BookManager = require("bookManager")
local Platform = require("platform")
local Ground = require("ground")
local SafeZone = require("safeZone")
local ScoreManager = require("scoreManager")
local Boundary = require("boundary")

-- Global game state
local world
local bookManager
local platform
local ground
local safeZone
local scoreManager
local boundaryLeft
local boundaryRight

function love.load()
	-- Initialize physics world
	love.physics.setMeter(64)
	world = GameWorld.create(0, 9.81 * 64)

	-- Initialize game components
	ground = Ground.create(world)
	platform = Platform.create(world)
	safeZone = SafeZone.create(world)
	bookManager = BookManager.create(world)
	scoreManager = ScoreManager.create()
	boundaryLeft = Boundary.create(world, -200, 325)
	boundaryRight = Boundary.create(world, 850, 325)

	-- Set window properties
	love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function love.update(dt)
	world:update(dt)

	-- Update components
	platform:update(dt)
	bookManager:update(dt)

	-- We now handle scoring in the beginContact callback
	-- for more immediate and accurate response
end

function love.draw()
	-- Draw all game components
	ground:draw()
	platform:draw()
	safeZone:draw()
	bookManager:draw()
	scoreManager:draw()
	boundaryLeft:draw()
	boundaryRight:draw()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

-- Physics collision callbacks
function beginContact(a, b, coll)
	local aData = a:getUserData()
	local bData = b:getUserData()

	-- Handle book-platform collision
	if (aData == "book" and bData == "platform") or (bData == "book" and aData == "platform") then
		local bookFixture = aData == "book" and a or b
		bookManager:markBookSaved(bookFixture:getBody())
	end

	-- Handle book-ground collision
	if (aData == "book" and bData == "ground") or (bData == "book" and aData == "ground") then
		local bookFixture = aData == "book" and a or b
		bookManager:markBookForDeletion(bookFixture:getBody())
	end

	-- Handle platform-safezone collision
	if (aData == "platform" and bData == "safeZone") or (bData == "platform" and aData == "safeZone") then
		platform:setInSafeZone(true)

		-- Score and clear books immediately when entering safe zone
		local bookCount = bookManager:countSavedBooks()
		if bookCount > 0 then
			scoreManager:addScore(bookCount)
			bookManager:clearSavedBooks()
		end
	end

	-- Handle book-book collision
	if aData == "book" and bData == "book" then
		bookManager:markBookSaved(a:getBody())
		bookManager:markBookSaved(b:getBody())
	end
end

function endContact(a, b, coll)
	local aData = a:getUserData()
	local bData = b:getUserData()

	-- Handle platform leaving safezone
	if (aData == "platform" and bData == "safeZone") or (bData == "platform" and aData == "safeZone") then
		platform:setInSafeZone(false)
	end
end
