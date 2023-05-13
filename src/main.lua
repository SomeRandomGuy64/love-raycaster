_G.love = require "love"

function love.load()
    Object = require "src.libraries.classic"
    require "src.entity"
    require "src.player"

    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)

    createPlayer1(300, 300, 8, 8)
end

function love.update(dt)
    -- body
end

function love.draw()
    player1:draw()
end

function createPlayer1(x, y, pWidth, pHeight)
    player1 = Player(x, y, pWidth, pHeight)
end