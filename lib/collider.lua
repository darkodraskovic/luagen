Class = require 'lib.hump.class'
vector = require 'lib.hump.vector'
shapes = require 'lib.HC.shapes'

Collider = Class{}

function Collider.setOffset(vertices)
    local poly = shapes.newPolygonShape(unpack(vertices))
    local x1,y1,x2,y2 = poly:bbox()
    local bx,by = (x2-x1)/2, (y2-y1)/2
    local cx,cy = poly:center()
    return vector(cx-bx,cy-by)
end

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

function Collider:setCollide(collide, cbk)
    local e = self.entity
    if (collide) then
        self.collisionSig = e:registerSignal(
            e.signals, 'collision', e.cbk or e['onCollision'])
        self.collideSig = e:registerSignal(
            e.scene.signals, 'collide', function () self:collide() end)
    else
        e:removeSignal(self.collisionSig)
        e:removeSignal(self.collideSig)
    end
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
    if self.offset then
        self.offset:rotateInplace(self.entity.rot - self.shape:rotation())
        self.shape:move(self.offset:unpack())
    end
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
