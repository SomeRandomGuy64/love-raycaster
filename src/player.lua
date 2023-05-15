Player = Entity:extend()
_G.DR = 0.0174535  ---one degree in radians

function Player:new(x, y, playerWidth, playerHeight, level)
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

    if self.controlFlag == true then
        Player:QuickPress(self, dt)
        self.controlFlag = false
    end

    ---collision---
    local xOffset = 0
    local yOffset = 0

    if self.deltaX < 0 then
        xOffset = -20
    else
        xOffset = 20
    end
    
    local gridPositionX = math.floor(self.x / 64)
    local gridPositionPlusXOffset = math.floor((self.x + xOffset) / 64)
    local gridPositionMinusXOffset = math.floor((self.x - xOffset) / 64)  
    
    if self.deltaY < 0 then
        yOffset = -20
    else
        yOffset = 20
    end
    
    local gridPositionY = math.floor(self.y / 64)
    local gridPositionPlusYOffset = math.floor((self.y + yOffset) / 64)
    local gridPositionMinusYOffset = math.floor((self.y - yOffset) / 64)  


    ---controls---
    if love.keyboard.isDown("w") then
        if self.level.arrayMap[math.floor(gridPositionY * self.level.x + gridPositionPlusXOffset) + 1] == 0 then
            self.x = self.x + (self.deltaX * dt * self.speed)
        end
        if self.level.arrayMap[math.floor(gridPositionPlusYOffset * self.level.x + gridPositionX) + 1] == 0 then
            self.y = self.y + (self.deltaY * dt * self.speed)
        end
    end

    if love.keyboard.isDown("s") then
        if self.level.arrayMap[math.floor(gridPositionY * self.level.x + gridPositionMinusXOffset) + 1] == 0 then
            self.x = self.x - (self.deltaX * dt * self.speed)
        end
        if self.level.arrayMap[math.floor(gridPositionMinusYOffset * self.level.x + gridPositionX) + 1] == 0 then
            self.y = self.y - (self.deltaY * dt * self.speed)
        end
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

    local shade

    local disV
    local verticalX
    local verticalY

    local finalDistance

    local allTextures = require("src.textures.allTextures")

    local PI2 = math.pi / 2
    local PI3 = (3 * math.pi) / 2

    rayAngle = player.angle - DR * 30

    if rayAngle < 0 then
        rayAngle = rayAngle + 2 * math.pi
    end

    if rayAngle > 2 * math.pi then
        rayAngle = rayAngle - 2 * math.pi
    end

    for rays = 1, 60 do
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
            shade = 0.7
            rayX = verticalX
            rayY = verticalY
            finalDistance = disV
            love.graphics.setColor(0.9, 0, 0)
        end

        if disH < disV then
            shade = 1
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
        ---fix fisheye---
        cosineAngle = player.angle - rayAngle
        if cosineAngle < 0 then
            cosineAngle = cosineAngle + (2 * math.pi)
        end

        if cosineAngle > (2 * math.pi) then
            cosineAngle = cosineAngle - (2 *  math.pi)
        end

        finalDistance = finalDistance * math.cos(cosineAngle)

        lineH = (player.level.blockSize * 320) / finalDistance

        local textureYStep = (32/lineH)
        local textureYOffset = 0

        if lineH > 320 then
            textureYOffset = (lineH - 320)/2
            lineH = 320
        end
        lineO = 160 - lineH / 2

        local textureY = textureYOffset * textureYStep
        local textureX
        
        if shade == 0.7 then
            textureX = math.floor(math.floor(rayY / 2) % 32)
            if rayAngle > 90 * DR and rayAngle < 270 * DR then
                textureX = 31 - textureX
            end
        else
            textureX = math.floor(math.floor(rayX / 2) % 32)
            if rayAngle > 0 and rayAngle < 180 * DR then
                textureX = 31 - textureX
            end
        end


        for pixelY=1,lineH do
            local index = (math.floor(textureY) * 32) + 1 + textureX
            local c = allTextures[index] * shade
            love.graphics.setPointSize(8)
            love.graphics.setColor(c, c, c)
            love.graphics.points(ray * 8 + 510, pixelY + lineO)
            textureY = textureY + textureYStep
        end


        rayAngle = rayAngle + DR

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
