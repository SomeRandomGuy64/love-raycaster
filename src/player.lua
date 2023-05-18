Player = Entity:extend()
---constants, don't change---
_G.DR = 0.0174535 ---one degree in radians
_G.PI2 = math.pi / 2
_G.PI3 = (3 * math.pi) / 2

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

    if love.keyboard.isDown("e") then
        local doorXOffset = 0
        local doorYOffset = 0
        if self.deltaX < 0 then
            doorXOffset = -25
        else
            doorXOffset = 25
        end

        if self.deltaY < 0 then
            doorYOffset = -25
        else
            doorYOffset = 25
        end

        gridPositionX = math.floor(self.x / 64)
        gridPositionMinusXOffset = math.floor((self.x + doorXOffset) / 64)

        gridPositionY = math.floor(self.x / 64)
        gridPositionMinusYOffset = math.floor((self.y + doorYOffset) / 64)

        if self.level.arrayMap[math.floor(gridPositionY * self.level.x + gridPositionMinusXOffset) + 1] == 4 then
            self.level.arrayMap[math.floor(gridPositionY * self.level.x + gridPositionMinusXOffset) + 1] = 0
        end
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
    local mapX, mapY, mapPosition = 0, 0, 0
    local depthOfField = 0
    local rayX, rayY, rayAngle = 0, 0, player.angle - DR * 30
    local xOffset, yOffset = 0, 0
    local inverseTangent, negativeTangent = 0, 0
    local disH, horizontalX, horizontalY = 0, 0, 0
    local disV, verticalX, verticalY = 0, 0, 0
    local shade = 1
    local finalDistance = 1
    local horizontalMapTexture, verticalMapTexture = 0, 0
    local allTextures = require("src.textures.allTextures")

    if rayAngle < 0 then
        rayAngle = rayAngle + 2 * math.pi
    end

    if rayAngle > 2 * math.pi then
        rayAngle = rayAngle - 2 * math.pi
    end

    for rays = 1, 120 do
        ---check horizontal lines---
        depthOfField = 0
        disH = 9999
        horizontalX = lineX
        horizontalY = lineY
        inverseTangent = -1 / math.tan(rayAngle)

        local directionalArguments = {
            rayX = rayX,
            rayY = rayY,
            xOffset = xOffset,
            yOffset = yOffset,
            depthOfField = depthOfField
        }

        ---looking up---
        if rayAngle > math.pi then
            Player:DirectionLook(directionalArguments, lineX, lineY, inverseTangent, -0.0001, -64)
            ---looking down---
        elseif rayAngle < math.pi then
            Player:DirectionLook(directionalArguments, lineX, lineY, inverseTangent, 64, 64)
        end
        Player:DirectionStraight(directionalArguments, lineX, lineY, rayAngle)
        -- looking straight left or right---

        rayX = directionalArguments.rayX
        rayY = directionalArguments.rayY
        xOffset = directionalArguments.xOffset
        yOffset = directionalArguments.yOffset
        depthOfField = directionalArguments.depthOfField

        while depthOfField < 8 do
            mapX = math.floor(rayX / 64)
            mapY = math.floor(rayY / 64)
            mapPosition = mapY * player.level.x + mapX

            ---hit wall---
            if mapPosition > 0 and mapPosition < player.level.x * player.level.y and
                player.level.arrayMap[mapPosition + 1] > 0 then
                horizontalMapTexture = player.level.arrayMap[mapPosition + 1]
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
            if mapPosition > 0 and mapPosition < player.level.x * player.level.y and
                player.level.arrayMap[mapPosition + 1] > 0 then
                verticalMapTexture = player.level.arrayMap[mapPosition + 1]
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
            horizontalMapTexture = verticalMapTexture
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
            cosineAngle = cosineAngle - (2 * math.pi)
        end

        finalDistance = finalDistance * math.cos(cosineAngle)

        lineH = (player.level.blockSize * 320) / finalDistance

        local textureYStep = (32 / lineH)
        local textureYOffset = 0

        if lineH > 320 then
            textureYOffset = (lineH - 320) / 2
            lineH = 320
        end
        lineO = 160 - lineH / 2

        local textureY = (textureYOffset * textureYStep) + ((horizontalMapTexture - 1) * 32)
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

        for pixelY = 1, lineH do
            local index = (math.floor(textureY) * 32) + 1 + textureX
            local c = allTextures[index] * shade
            love.graphics.setPointSize(4)
            if horizontalMapTexture == 1 then
                love.graphics.setColor(c, c/2, c/2)
            end
            if horizontalMapTexture == 2 then
                love.graphics.setColor(c, c, c/2)
            end
            if horizontalMapTexture == 3 then
                love.graphics.setColor(c/2, c/2, c )
            end
            if horizontalMapTexture == 4 then
                love.graphics.setColor(c/2, c, c/2)
            end
            love.graphics.points(rays * 4 + 510, pixelY + lineO)
            textureY = textureY + textureYStep
        end

        rayAngle = rayAngle + DR / 2

        if rayAngle < 0 then
            rayAngle = rayAngle + 2 * math.pi
        end

        if rayAngle > 2 * math.pi then
            rayAngle = rayAngle - 2 * math.pi
        end
    end
end

function Player:Dist(ax, ay, bx, by, angle)
    return (math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay)))
end

function Player:DirectionLook(args, lineX, lineY, inverseTangent, mainOffset, blockSize)
    args.rayY = math.floor(lineY / 64) * 64 + mainOffset
    args.rayX = (lineY - args.rayY) * inverseTangent + lineX
    args.yOffset = blockSize
    args.xOffset = -args.yOffset * inverseTangent
end

function Player:DirectionStraight(args, lineX, lineY, rayAngle)
    if rayAngle == 0 or rayAngle == math.pi then
        args.rayX = lineX
        args.rayY = lineY
        args.depthOfField = 8
    end
end
