_G.love = require "love"

function love.load()
    Object = require "src.libraries.classic"
    require "src.entity"
    require "src.map"
    require "src.player"

    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
    local map1Array = {
        1,1,1,1,1,1,1,1,
        1,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,1,
        1,0,0,0,1,0,1,1,
        1,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,1,
        1,0,0,0,1,0,0,1,
        1,1,1,1,1,1,1,1
    }
    map1 = Map(8, 8, 64, map1Array)

    local p1X = 300
    local p1Y = 300
    local p1Width = 8
    local p1Height = 8
    player1 = Player(p1X, p1Y, p1Width, p1Height, map1)

end

function love.update(dt)
    player1:update(dt)
end

function love.draw()
    map1:draw()
    player1:draw()
end

