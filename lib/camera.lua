local camera = require 'lib.hump.camera'

local Camera = Class{}

function Camera:init()
    self.transform = love.math.newTransform()
    self.viewport = camera()
end

-- transform

function Camera:updateTransform()
    local v = self.viewport
    self.transform:setTransformation(v:position(),v.rot, v.scale, v.scale)
end

function Camera:updateBbox()
    self.bbox:moveTo(self.viewport:position())
    self.bbox:setRotation(self.viewport.rot)
end

function Camera:setBbox(spatialHash)
    if self.bbox then spatialHash:remove(self.bbox) end
    local w, h = love.graphics.getDimensions()
    self.bbox = spatialHash:rectangle(-w/2, -h/2, w, h)
end

-- module

return Camera
