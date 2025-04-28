function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81 * 64, true)

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

	objects.platform = {}
	objects.platform.body = love.physics.newBody(world, 650 / 2, 625, "dynamic")
	objects.platform.shape = love.physics.newRectangleShape(300, 25)
	objects.platform.fixture = love.physics.newFixture(objects.platform.body, objects.platform.shape)

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
end

function love.beginContact(a, b, contact)
	print("HIT")
	if isPlatformOrBook(a) then
		table.insert(safe, b:getBody())
	elseif isPlatformOrBook(b) then
		table.insert(safe, a:getBody())
	elseif a == objects.ground.fixture then
		markForDestruction(b:getBody())
	elseif b == objects.ground.fixture then
		markForDestruction(a:getBody())
	end
end

function love.endContact(a, b, contact)
	print("DESTROY")
	if a == objects.ground.fixture then
		print("DESTROY")
		markForDestruction(b:getBody())
	elseif b == objects.ground.fixture then
		print("DESTROY")
		markForDestruction(a:getBody())
	end
end

function isPlatformOrBook(fixture)
	if fixture == objects.platform.fixture then
		return true
	end

	local userdata = fixture:getUserData()
	if userdata then
		-- It's one of our books
		return true
	end

	return false
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
	book.fixture:setUserData(book)
	table.insert(objects.books, book)
end
