Map = Object:extend()

function Map:new(x, y, blockSize, arrayMap)
    self.x = x
    self.y = y
    self.blockSize = blockSize
    self.arrayMap = arrayMap
end

function Map:update(dt)

end

function Map:draw()

    local xOffset = 0
    local yOffset = 0

    for currentY = 1, self.y + 1 do
        for currentX = 1, self.x do
            if self.arrayMap[(currentY - 1) * self.x + currentX] == 1 then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0, 0, 0)        
            end

            xOffset = (currentX - 1) * self.blockSize
            yOffset = (currentY - 1) * self.blockSize

            love.graphics.rectangle("fill", xOffset, yOffset, self.blockSize, self.blockSize)

            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("line", xOffset, yOffset, self.blockSize, self.blockSize)
        end
    end
end