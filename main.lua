_G.love = require "love"

function love.load()
    Object = require "src.libraries.classic"
    require "src.entity"
    require "src.map"
    require "src.player"

    dungeonMusic = love.audio.newSource('src/music/dungeon.mp3', 'stream')
    dungeonMusic:play()

    local map1Array = {
        3,4,3,3,1,8,2,2,
        1,0,0,0,0,0,2,2,
        1,0,0,0,0,0,0,7,
        1,0,2,2,0,0,0,1,
        1,0,0,0,0,0,0,1,
        1,0,3,0,3,0,0,1,
        1,0,0,0,7,0,0,1,
        1,1,1,1,1,1,1,1
    }
    local floor1Array = {
        2,2,2,2,2,2,2,2,
        2,2,2,2,5,2,2,2,
        2,2,3,2,2,2,5,2,
        2,6,5,2,3,2,5,2,
        2,2,5,2,2,6,2,2,
        2,2,3,2,5,2,2,2,
        2,2,6,2,2,6,5,2,
        2,2,2,2,2,2,2,2
    }
    local ceiling1Array = {
        3,3,3,3,3,3,3,3,
        3,8,7,3,3,8,3,3,
        3,8,3,7,3,3,6,3,
        3,8,3,3,5,3,7,3,
        3,6,8,3,3,3,3,3,
        3,3,3,7,3,3,6,3,
        3,3,5,3,3,7,6,3,
        3,3,3,3,3,3,3,3
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
    map1:draw()
    player1:draw()
end

