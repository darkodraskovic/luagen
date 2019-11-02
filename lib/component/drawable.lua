local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Drawable = Class{ type = 'drawable' }

function Drawable:add(opt)
    local e = self.entity
    e.drawable = self
    e:register('draw-component', function() self:draw() end)
    self:setDrawable(opt.drawable)
end

function Drawable:setDrawable(drawable)
    self._drawable = drawable
    self.entity.size = vector(drawable:getWidth(), drawable:getHeight())
end

function Drawable:draw()
    love.graphics.draw(self._drawable, self.entity.transform)
end

return Drawable
