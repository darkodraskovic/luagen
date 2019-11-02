local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Entity = require 'lib.core.entity'

local Sprite = Class{
    __includes = Entity
}

function Sprite:init()
    Entity.init(self)
end

function Sprite:setImage(img)
    self.img = img
    self.size = vector(img:getWidth(), img:getHeight())
    self.bbox = self.scene.spaceHash:rectangle(0, 0, self.size:unpack())
end

-- draw

function Sprite:draw()
    Entity.draw(self)
    love.graphics.draw(self.img, self.transform)
end

-- module

return Sprite
