Player = Entity:extend()

function Player:new(x, y, playerWidth, playerHeight)
    Player.super.new(self, x, y)
    self.playerWidth = playerWidth
    self.playerHeight = playerHeight
end

function Player:update(dt)
    Player.super.update(self, dt)
end

function Player:draw()
    Player.super.draw(self)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.playerWidth, self.playerHeight)
end