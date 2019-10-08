Class = require 'lib.hump.class'

Collider = Class{}

function Collider:init()
    self.layer = 'a'
    self.mask = 'a'
end

function Collider:setShape(shape, register)
    if self.shape then
        if self.shape == shape then return end
        self.entity.scene.collider:remove(self.shape)
    end
    self.shape = shape
    shape.collider = self
    if register then self.entity.scene.collider:register(shape) end
end

function Collider:collide()
    local candidates = self.entity.scene.collider:neighbors(self.shape)
    for other in pairs(candidates) do
        local e2 = other.collider.entity
        if not e2.exists or not e2.parent then break end
        if not self.mask:find(other.collider.layer) then break end
        local collides, dx, dy = self.shape:collidesWith(other)
        if collides then
            local e1 = self.entity
            e1.signals:emit('collision', e1, e2, vector(dx, dy))
        end
    end
end

function Collider:updatePos()
    self.entity:updateTransform()
    self.shape:moveTo(self.entity:center())
end

function Collider:update()
    self:updatePos()
    self.shape:setRotation(self.entity:rotation())
end

function Collider:setScale(s)
    self.shape:scale(s)
end

function Collider:remove()
    self.entity.scene.collider:remove(self.shape)
end

function Collider:draw()
    r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(0, 1, 0, 0.5)
    self.shape:draw('line')
    love.graphics.setColor(r,g,b,a)
end

return Collider
