-- Game configuration
function love.conf(t)
	t.title = "Book Catcher"
	t.version = "11.5"
	t.window.width = 650
	t.window.height = 650

	-- For speed
	t.modules.joystick = false
	t.modules.thread = false
	t.modules.video = false
end
