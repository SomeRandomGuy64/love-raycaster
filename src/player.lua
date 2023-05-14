Player = Entity:extend()
_G.DR = 0.0174535  ---one degree in radians

function Player:new(x, y, playerWidth, playerHeight, level)
    require = "src.map"

    Player.super.new(self, x, y)
    self.playerWidth = playerWidth
    self.playerHeight = playerHeight
    self.level = level

    self.angle = 0

    self.speed = 10

    self.deltaX = math.cos(self.angle) * self.speed
    self.deltaY = math.sin(self.angle) * self.speed

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
    
    
    local lineX = self.x + (self.playerWidth / 2)
    local lineY = self.y + (self.playerHeight / 2)
    
    Player:DrawRays3D(lineX, lineY, self)
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.line(lineX, lineY, lineX + self.deltaX * 5, lineY + self.deltaY * 5)

    love.graphics.rectangle("fill", self.x, self.y, self.playerWidth, self.playerHeight)
end

function Player:DrawRays3D(lineX, lineY, player)
    local ray = 1
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

    local disH
    local horizontalX
    local horizontalY

    local disV
    local verticalX
    local verticalY

    local finalDistance

    local PI2 = math.pi / 2
    local PI3 = (3 * math.pi) / 2

    rayAngle = player.angle - DR * 30

    if rayAngle < 0 then
        rayAngle = rayAngle + 2 * math.pi
    end

    if rayAngle > 2 * math.pi then
        rayAngle = rayAngle - 2 * math.pi
    end

    for rays = 1, 240 do
        ---check horizontal lines---
        depthOfField = 0

        disH = 9999
        horizontalX = lineX
        horizontalY = lineY

        inverseTangent = -1 / math.tan(rayAngle)

        ---looking up---
        if rayAngle > math.pi then
            rayY = math.floor(lineY / 64) * 64 - 0.0001
            rayX = (lineY - rayY) * inverseTangent + lineX
            yOffset = -64
            xOffset = -yOffset * inverseTangent
        end

        ---looking down---
        if rayAngle < math.pi then
            rayY = math.floor(lineY / 64) * 64 + 64
            rayX = (lineY - rayY) * inverseTangent + lineX
            yOffset = 64
            xOffset = -yOffset * inverseTangent
        end

        -- looking straight left or right---
        if rayAngle == 0 or rayAngle == math.pi then
            rayX = lineX
            rayY = lineY
            depthOfField = 8
        end

        while depthOfField < 8 do
            mapX = math.floor(rayX / 64)
            mapY = math.floor(rayY / 64)
            mapPosition = mapY * player.level.x + mapX

            ---hit wall---
            if mapPosition > 0 and mapPosition < player.level.x * player.level.y and player.level.arrayMap[mapPosition + 1] == 1 then
                horizontalX = rayX
                horizontalY = rayY
                disH = Player:Dist(lineX, lineY, horizontalX, horizontalY, rayAngle)
                depthOfField = 8
            else
                rayX = rayX + xOffset
                rayY = rayY + yOffset
                depthOfField = depthOfField + 1
            end
        end

        --love.graphics.setColor(0, 1, 0)
        --love.graphics.setLineWidth(5)
        --love.graphics.line(lineX, lineY, rayX, rayY)
        --love.graphics.setLineWidth(2)

        ---check vertical lines---
        depthOfField = 0

        disV = 9999
        verticalX = lineX
        verticalY = lineY

        negativeTangent = -(math.tan(rayAngle))

        ---looking left---
        if rayAngle > PI2 and rayAngle < PI3 then
            rayX = math.floor(lineX / 64) * 64 - 0.0001
            rayY = (lineX - rayX) * negativeTangent + lineY
            xOffset = -64
            yOffset = -xOffset * negativeTangent
        end

        ---looking right---
        if rayAngle < PI2 or rayAngle > PI3 then
            rayX = math.floor(lineX / 64) * 64 + 64
            rayY = (lineX - rayX) * negativeTangent + lineY
            xOffset = 64
            yOffset = -xOffset * negativeTangent
        end

        -- looking straight up or down---
        if rayAngle == 0 or rayAngle == math.pi then
            rayX = lineX
            rayY = lineY
            depthOfField = 8
        end

        while depthOfField < 8 do
            mapX = math.floor(rayX / 64)
            mapY = math.floor(rayY / 64)
            mapPosition = mapY * player.level.x + mapX

            ---hit wall---
            if mapPosition > 0 and mapPosition < player.level.x * player.level.y and player.level.arrayMap[mapPosition + 1] == 1 then
                verticalX = rayX
                verticalY = rayY
                disV = Player:Dist(lineX, lineY, verticalX, verticalY, rayAngle)
                depthOfField = 8
            else
                rayX = rayX + xOffset
                rayY = rayY + yOffset
                depthOfField = depthOfField + 1
            end
        end

        if disV < disH then
            rayX = verticalX
            rayY = verticalY
            finalDistance = disV
            love.graphics.setColor(0.9, 0, 0)
        end

        if disH < disV then
            rayX = horizontalX
            rayY = horizontalY
            finalDistance = disH
            love.graphics.setColor(0.7, 0, 0)
        end

        ---draw ray---
        love.graphics.line(lineX, lineY, rayX, rayY)

        ---draw 3d scene---
        local lineH
        local lineO
        local cosineAngle

        cosineAngle = player.angle - rayAngle
        if cosineAngle < 0 then
            cosineAngle = cosineAngle + (2 * math.pi)
        end

        if cosineAngle > (2 * math.pi) then
            cosineAngle = cosineAngle - (2 *  math.pi)
        end

        finalDistance = finalDistance * math.cos(cosineAngle)

        lineH = (player.level.blockSize * 320) / finalDistance
        if lineH > 320 then
            lineH = 320
        end
        lineO = 160 - lineH / 2

        love.graphics.setLineWidth(2)
        love.graphics.line(ray * 2 + 510, lineO, ray * 2 + 510, lineH + lineO)
        love.graphics.setLineWidth(1)

        rayAngle = rayAngle + DR/4

        if rayAngle < 0 then
            rayAngle = rayAngle + 2 * math.pi
        end
    
        if rayAngle > 2 * math.pi then
            rayAngle = rayAngle - 2 * math.pi
        end
        ray = ray + 1
    end
end

function Player:Dist(ax, ay, bx, by, angle)
    return (math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay)))
end
