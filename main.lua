function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81 * 64, true)
	world:setCallbacks(beginContact, endContact)

	objects = {}
	objects.books = {}
	safe = {}
	bodiesToDestroy = {}
	timer = 0
	spawn_interval = 2
	platform_force = 12345
	score = 0

	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, 650 / 2, 674)
	objects.ground.shape = love.physics.newRectangleShape(650, 50)
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
	objects.ground.fixture:setFriction(0.1)
	objects.ground.fixture:setUserData("ground")

	objects.platform = {}
	objects.platform.body = love.physics.newBody(world, 650 / 2, 625, "dynamic")
	objects.platform.shape = love.physics.newRectangleShape(300, 25)
	objects.platform.fixture = love.physics.newFixture(objects.platform.body, objects.platform.shape)
	objects.platform.fixture:setUserData("platform")

	objects.safeZone = {}
	objects.safeZone.body = love.physics.newBody(world, 0, 650 / 2, "static")
	objects.safeZone.shape = love.physics.newRectangleShape(50, 650)
	objects.safeZone.fixture = love.physics.newFixture(objects.safeZone.body, objects.safeZone.shape, 0)
	objects.safeZone.fixture:setSensor(true)
	objects.safeZone.fixture:setUserData("safeZone")

	love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
	love.window.setMode(650, 650)
end

function love.update(dt)
	world:update(dt)

	timer = timer + dt
	if timer >= spawn_interval then
		SpawnBook()
		timer = 0
	end

	if love.keyboard.isDown("right") then
		objects.platform.body:applyForce(1000, 0)
	elseif love.keyboard.isDown("left") then
		objects.platform.body:applyForce(-1000, 0)
	elseif love.keyboard.isDown("escape") then
		love.event.quit()
	end

	-- Destroy after physics update
	for _, body in ipairs(bodiesToDestroy) do
		if body:isDestroyed() == false then
			body:destroy()
		end
	end
	bodiesToDestroy = {} -- clear list after destruction
end

function love.draw()
	love.graphics.setColor(0.28, 0.63, 0.05)
	love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

	love.graphics.setColor(0.28, 0.28, 0.28)
	love.graphics.polygon("fill", objects.platform.body:getWorldPoints(objects.platform.shape:getPoints()))

	for i = #objects.books, 1, -1 do
		local book = objects.books[i]
		love.graphics.setColor(1, 1, 1)
		love.graphics.polygon("fill", book.body:getWorldPoints(book.shape:getPoints()))
	end

	love.graphics.setColor(0, 1, 0, 0.3)
	love.graphics.polygon("fill", objects.safeZone.body:getWorldPoints(objects.safeZone.shape:getPoints()))
end

function beginContact(a, b, contact)
	local aType = a:getUserData()
	local bType = b:getUserData()

	if aType == "ground" and bType ~= "platform" then
		markForDestruction(b:getBody())
	elseif bType == "ground" and aType ~= "platform" then
		markForDestruction(a:getBody())
	elseif aType == "platform" and bType == "safeZone" then
		print("SAFE!")
		returnBooks()
	elseif bType == "platform" and aType == "safeZone" then
		print("SAFE!")
		returnBooks()
	end
end

function returnBooks()
	for i, body in ipairs(safe) do
		if body:isDestroyed() == false then
			body:destroy()
		end
	end
end

function endContact(a, b, contact)
	if a == objects.ground.fixture then
		markForDestruction(b:getBody())
	elseif b == objects.ground.fixture then
		markForDestruction(a:getBody())
	end
end

function removeBodyFromSafe(body)
	for i = #safe, 1, -1 do
		if safe[i] == body then
			table.remove(safe, i)
			return
		end
	end
end

function markForDestruction(body)
	if body:isDestroyed() == false then
		table.insert(bodiesToDestroy, body)

		-- Remove from objects.books
		for i = #objects.books, 1, -1 do
			if objects.books[i].body == body then
				table.remove(objects.books, i)
				break
			end
		end
	end
end

-- TODO: Add random spawn location
function SpawnBook()
	local x = love.math.random(50, 600)
	local y = -50
	local size_x = love.math.random(50, 130)
	local size_y = love.math.random(10, 40)
	local book = {}
	book.body = love.physics.newBody(world, x, y, "dynamic")
	book.shape = love.physics.newRectangleShape(size_x, size_y)
	book.fixture = love.physics.newFixture(book.body, book.shape)
	book.fixture:setFriction(10)
	book.fixture:setDensity(0.2)
	book.is_falling = true
	book.fixture:setUserData("book")
	table.insert(objects.books, book)
end
