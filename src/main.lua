_G.love = require "love"

function love.load()
    Object = require "src.libraries.classic"
    require "src.entity"
    require "src.player"

    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)

    local p1X = 300
    local p1Y = 300
    local p1Width = 8
    local p1Height = 8
    player1 = Player(p1X, p1Y, p1Width, p1Height)
end

function love.update(dt)
    player1:update(dt)
end

function love.draw()
    player1:draw()
end