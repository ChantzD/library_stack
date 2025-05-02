-- scoreManager.lua - Manages game score
local ScoreManager = {}
local ScoreManager_mt = { __index = ScoreManager }

function ScoreManager.create()
	local self = {}
	setmetatable(self, ScoreManager_mt)

	self.score = 0

	return self
end

function ScoreManager:addScore(amount)
	self.score = self.score + amount
end

function ScoreManager:draw()
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.print("Score: " .. self.score, 10, 10)
end

return ScoreManager
