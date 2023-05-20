Map = Object:extend()

function Map:new(x, y, blockSize, arrayMap, arrayFloor, arrayCeiling)
    self.x = x
    self.y = y
    self.blockSize = blockSize
    self.arrayMap = arrayMap
    self.arrayFloor = arrayFloor
    self.arrayCeiling = arrayCeiling
end

function Map:update(dt)

end

function Map:draw()
    
end