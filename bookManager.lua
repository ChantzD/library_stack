-- bookManager.lua - Manages spawning and tracking books
local BookManager = {}
local BookManager_mt = { __index = BookManager }

local SPAWN_INTERVAL = 2

function BookManager.create(world)
	local self = {}
	setmetatable(self, BookManager_mt)

	self.world = world
	self.books = {}
	self.savedBooks = {}
	self.bodiesToDestroy = {}
	self.timer = 0

	self:loadSprites()

	return self
end

function BookManager:loadSprites()
	-- Load all book sprites
	self.bookSprites = {
		love.graphics.newImage("images/FallingBooksMG/Extra_Small_Book_1_Purple.png"),
		love.graphics.newImage("images/FallingBooksMG/Extra_Small_Book_2_Orange.png"),
		love.graphics.newImage("images/FallingBooksMG/Extra_Small_Book_3_Green.png"),
		love.graphics.newImage("images/FallingBooksMG/Extra_Small_Book_4_Yellow.png"),
		love.graphics.newImage("images/FallingBooksMG/Tiny_Book_1_Green.png"),
		love.graphics.newImage("images/FallingBooksMG/Tiny_Book_2_Red.png"),
		love.graphics.newImage("images/FallingBooksMG/Tiny_Book_3_Blue.png"),
		love.graphics.newImage("images/FallingBooksMG/Tiny_Book_4_Brown.png"),
	}

	-- Check if loading was successful
	if #self.bookSprites == 0 then
		print("Warning: Failed to load any book sprites!")
	else
		print("Successfully loaded " .. #self.bookSprites .. " book sprites")
	end
end

function BookManager:update(dt)
	-- Update book spawn timer
	self.timer = self.timer + dt
	if self.timer >= SPAWN_INTERVAL then
		self:spawnBook()
		self.timer = 0
	end

	-- Clean up books marked for destruction
	self:cleanupBooks()
end

function BookManager:draw()
	-- Draw all active books
	for _, book in ipairs(self.books) do
		if book.sprite then
			love.graphics.setColor(1, 1, 1, 1)
			-- Get position and rotation from physics body
			local x, y = book.body:getPosition()
			local angle = book.body:getAngle()
			-- Draw sprite with proper positioning and rotation
			love.graphics.draw(
				book.sprite,
				x,
				y, -- position
				angle, -- rotation
				1,
				1, -- scale (use original size)
				book.width / 2,
				book.height / 2 -- origin at center
			)
			-- Debug physics outline (uncomment if needed)
			-- love.graphics.setColor(1, 0, 0, 0.5)
			-- love.graphics.polygon("line", book.body:getWorldPoints(book.shape:getPoints()))
		end
	end
end

function BookManager:spawnBook()
	local randomIndex = math.random(1, #self.bookSprites)
	local selectedSprite = self.bookSprites[randomIndex]

	local x = love.math.random(50, 600)
	local y = -50
	local width = selectedSprite:getWidth()
	local height = selectedSprite:getHeight()

	local book = {}
	book.body = love.physics.newBody(self.world, x, y, "dynamic")
	book.shape = love.physics.newRectangleShape(width, height)
	book.fixture = love.physics.newFixture(book.body, book.shape)

	-- Physics properties
	book.fixture:setFriction(10)
	book.fixture:setDensity(0.2)
	book.fixture:setUserData("book")

	book.sprite = selectedSprite
	book.width = width
	book.height = height
	book.type = randomIndex

	table.insert(self.books, book)
end

function BookManager:markBookForDeletion(body)
	if not body:isDestroyed() then
		table.insert(self.bodiesToDestroy, body)
		self:removeBookFromSaved(body)
	end
end

function BookManager:markBookSaved(body)
	-- Check if book is already in saved table
	for _, savedBody in ipairs(self.savedBooks) do
		if savedBody == body then
			return -- Already saved
		end
	end

	if not body:isDestroyed() then
		table.insert(self.savedBooks, body)
	end
end

function BookManager:removeBookFromSaved(body)
	for i = #self.savedBooks, 1, -1 do
		if self.savedBooks[i] == body then
			table.remove(self.savedBooks, i)
			break
		end
	end
end

function BookManager:countSavedBooks()
	return #self.savedBooks
end

function BookManager:clearSavedBooks()
	-- Destroy all saved books
	local savedBodiesCopy = {}
	for _, body in ipairs(self.savedBooks) do
		table.insert(savedBodiesCopy, body)
	end

	-- First mark all for deletion
	for _, body in ipairs(savedBodiesCopy) do
		if not body:isDestroyed() then
			table.insert(self.bodiesToDestroy, body)
		end
	end

	-- Then remove from books table
	for _, body in ipairs(savedBodiesCopy) do
		for i = #self.books, 1, -1 do
			if self.books[i].body == body then
				table.remove(self.books, i)
				break
			end
		end
	end

	self.savedBooks = {}
end

function BookManager:cleanupBooks()
	-- Destroy bodies marked for deletion
	for _, body in ipairs(self.bodiesToDestroy) do
		if not body:isDestroyed() then
			body:destroy()
		end
	end

	-- Clear the destruction queue
	self.bodiesToDestroy = {}

	-- Clean up any references to destroyed bodies in the books table
	for i = #self.books, 1, -1 do
		if self.books[i].body:isDestroyed() then
			table.remove(self.books, i)
		end
	end

	-- Also clean up the saved books list
	for i = #self.savedBooks, 1, -1 do
		if self.savedBooks[i]:isDestroyed() then
			table.remove(self.savedBooks, i)
		end
	end
end

return BookManager
