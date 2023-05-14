Player = Entity:extend()

function Player:new(x, y, playerWidth, playerHeight, level)
    require = "src.map"

    Player.super.new(self, x, y)
    self.playerWidth = playerWidth
    self.playerHeight = playerHeight
    self.level = level

    self.angle = 100

    self.speed = 10

    self.deltaX = math.cos(self.angle) * self.speed
    self.deltaY = math.cos(self.angle) * self.speed

    self.controlFlag = true
end

function Player:update(dt)
    Player.super.update(self, dt)

    Player:QuickPress(self, dt)
    self.controlFlag = false

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

--- theres something really weird about the rays which stops after a and d are pressed, this is to fix that but i'm not sure how to actually, properly fix it so this is the best I could come up with

function Player:QuickPress(player, dt)
    player.angle = player.angle - (2 * dt)
    if player.angle < 0 then
        player.angle = player.angle + (2 * math.pi)
    end
    player.deltaX = math.cos(player.angle) * player.speed
    player.deltaY = math.sin(player.angle) * player.speed

    player.angle = player.angle + (2 * dt)
    if player.angle > 2 * math.pi then
        player.angle = player.angle - (2 * math.pi)
    end
    player.deltaX = math.cos(player.angle) * player.speed
    player.deltaY = math.sin(player.angle) * player.speed
end

function Player:draw()
    Player.super.draw(self)
    love.graphics.setColor(1, 1, 0)

    love.graphics.rectangle("fill", self.x, self.y, self.playerWidth, self.playerHeight)

    local lineX = self.x + (self.playerWidth / 2)
    local lineY = self.y + (self.playerHeight / 2)

    love.graphics.line(lineX, lineY, lineX + self.deltaX * 5, lineY + self.deltaY * 5)

    Player:DrawRays3D(lineX, lineY, self)
end

function Player:DrawRays3D(lineX, lineY, player)
    local mapX
    local mapY
    local mapPosition
    local depthOfField
    local rayX
    local rayY
    local rayAngle
    local xOffset
    local yOffset
    local inverseTangent
    local negativeTangent

    local PI2 = math.pi / 2
    local PI3 = (3 * math.pi) / 2

    rayAngle = player.angle

    for ray = 1, 1 do
        ---check horizontal lines---
        depthOfField = 0
        inverseTangent = -1 / math.tan(rayAngle)

        ---looking up---
        if rayAngle > math.pi then
            rayY = math.floor(player.y / 64) * 64 - 0.0001
            rayX = (player.y - rayY) * inverseTangent + player.x
            yOffset = -64
            xOffset = -yOffset * inverseTangent
        end

        ---looking down---
        if rayAngle < math.pi then
            rayY = math.floor(player.y / 64) * 64 + 64
            rayX = (player.y - rayY) * inverseTangent + player.x
            yOffset = 64
            xOffset = -yOffset * inverseTangent
        end

        -- looking straight left or right---
        if rayAngle == 0 or rayAngle == math.pi then
            rayX = player.x
            rayY = player.y
            depthOfField = 8
        end

        while depthOfField < 8 do
            mapX = math.floor(rayX / 64)
            mapY = math.floor(rayY / 64)
            mapPosition = mapY * player.level.x + mapX

            ---hit wall---
            if mapPosition < player.level.x * player.level.y and player.level.arrayMap[mapPosition + 1] == 1 then
                depthOfField = 8
            else
                rayX = rayX + xOffset
                rayY = rayY + yOffset
                depthOfField = depthOfField + 1
            end
        end

        ---draw ray---
        love.graphics.setColor(0, 1, 0)
        love.graphics.line(lineX, lineY, rayX, rayY)

        ---check vertical lines---
        depthOfField = 0
        negativeTangent = -(math.tan(rayAngle))

        ---looking left---
        if rayAngle > PI2 and rayAngle < PI3 then
            rayX = math.floor(player.x / 64) * 64 - 0.0001
            rayY = (player.x - rayX) * negativeTangent + player.y
            xOffset = -64
            yOffset = -xOffset * negativeTangent
        end

        ---looking right---
        if rayAngle < PI2 or rayAngle > PI3 then
            rayX = math.floor(player.x / 64) * 64 + 64
            rayY = (player.x - rayX) * negativeTangent + player.y
            xOffset = 64
            yOffset = -xOffset * negativeTangent
        end

        -- looking straight up or down---
        if rayAngle == 0 or rayAngle == math.pi then
            rayX = player.x
            rayY = player.y
            depthOfField = 8
        end

        while depthOfField < 8 do
            mapX = math.floor(rayX / 64)
            mapY = math.floor(rayY / 64)
            mapPosition = mapY * player.level.x + mapX

            ---hit wall---
            if mapPosition < player.level.x * player.level.y and player.level.arrayMap[mapPosition + 1] == 1 then
                depthOfField = 8
            else
                rayX = rayX + xOffset
                rayY = rayY + yOffset
                depthOfField = depthOfField + 1
            end
        end

        ---draw ray---
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(lineX, lineY, rayX, rayY)
    end
end
