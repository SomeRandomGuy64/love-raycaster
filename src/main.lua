_G.love = require "love"

function love.load()
    Object = require "src.libraries.classic"
    require "src.entity"
    require "src.map"
    require "src.player"

    local map1Array = {
        3,3,3,3,1,2,2,2,
        1,0,0,0,0,0,2,2,
        1,0,0,0,0,0,0,2,
        1,0,4,0,0,0,0,1,
        1,0,0,0,0,0,0,1,
        1,0,1,0,1,0,0,1,
        1,0,0,0,1,0,0,1,
        1,1,1,1,1,1,1,1
    }
    local floor1Array = {
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1
    }
    local ceiling1Array = {
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2
    }
    map1 = Map(8, 8, 64, map1Array, floor1Array, ceiling1Array)

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
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 992, 160)
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 0, 160, 992, 160)
    map1:draw()
    player1:draw()
end

