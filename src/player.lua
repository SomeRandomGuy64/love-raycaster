Player = Entity:extend()

function Player:new(x, y, playerWidth, playerHeight)
    Player.super.new(self, x, y)
    self.playerWidth = playerWidth
    self.playerHeight = playerHeight

    self.angle = 100

    self.speed = 10

    self.deltaX = math.cos(self.angle) * self.speed
    self.deltaY = math.cos(self.angle) * self.speed
end

function Player:update(dt)
    Player.super.update(self, dt)

    ---controls---
    if love.keyboard.isDown("w") then
        self.x = self.x + (self.deltaX * dt * self.speed)
        self.y = self.y + (self.deltaY * dt * self.speed)
    end

    if love.keyboard.isDown("s") then
        self.x = self.x - (self.deltaX * dt * self.speed)
        self.y = self.y - (self.deltaY * dt * self.speed)
    end

    if love.keyboard.isDown("a") then
        self.angle = self.angle - (2 * dt)
        if self.angle < 0 then
            self.angle = self.angle + (2 * math.pi)
        end
        self.deltaX = math.cos(self.angle) * self.speed
        self.deltaY = math.sin(self.angle) * self.speed
    end

    if love.keyboard.isDown("d") then
        self.angle = self.angle + (2 * dt)
        if self.angle > 2 * math.pi then
            self.angle = self.angle - (2 * math.pi)
        end
        self.deltaX = math.cos(self.angle) * self.speed
        self.deltaY = math.sin(self.angle) * self.speed
    end
end

function Player:draw()
    Player.super.draw(self)
    love.graphics.setColor(1, 1, 0)

    love.graphics.rectangle("fill", self.x, self.y, self.playerWidth, self.playerHeight)

    local lineX = self.x + (self.playerWidth / 2)
    local lineY = self.y + (self.playerHeight / 2)

    love.graphics.line(lineX, lineY, lineX + self.deltaX * 5, lineY + self.deltaY * 5)
end