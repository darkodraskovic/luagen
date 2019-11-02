local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Drawable = Class{ type = 'drawable' }

function Drawable:add(opt)
    local e = self.entity
    e.drawable = self
    
    local drawable = opt.drawable
    e:register('draw-component', function() self:draw() end)
    self.drawable = drawable
    e.size = vector(drawable:getWidth(), drawable:getHeight())
    e.bbox = e.scene.spaceHash:rectangle(0, 0, e.size:unpack())
end

function Drawable:draw()
    love.graphics.draw(self.drawable, self.entity.transform)
end

return Drawable
