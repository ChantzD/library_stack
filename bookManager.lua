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

	return self
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
		love.graphics.setColor(1, 1, 1)
		love.graphics.polygon("fill", book.body:getWorldPoints(book.shape:getPoints()))
	end
end

function BookManager:spawnBook()
	local x = love.math.random(50, 600)
	local y = -50
	local size_x = love.math.random(50, 130)
	local size_y = love.math.random(10, 40)

	local book = {}
	book.body = love.physics.newBody(self.world, x, y, "dynamic")
	book.shape = love.physics.newRectangleShape(size_x, size_y)
	book.fixture = love.physics.newFixture(book.body, book.shape)
	book.fixture:setFriction(10)
	book.fixture:setDensity(0.2)
	book.fixture:setUserData("book")

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
