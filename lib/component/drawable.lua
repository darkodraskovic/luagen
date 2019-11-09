local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Drawable = Class{ type = 'drawable' }

function Drawable:add(opt)
    local e = self.entity
    e:register('draw-component', function() self:draw() end)
    self:setDrawable(opt.drawable)
    self.alpha = 1
end

function Drawable:setDrawable(drawable)
    self._drawable = drawable
    self.entity.size = vector(drawable:getWidth(), drawable:getHeight())
end

function Drawable:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self._drawable, self.entity.transform)
end

return Drawable
