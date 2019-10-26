local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'
local shapes = require 'lib.HC.shapes'

local Collider = Class{
    type = 'collider',
}

-- utils

function Collider.setOffset(vertices)
    local poly = shapes.newPolygonShape(unpack(vertices))
    local x1,y1,x2,y2 = poly:bbox()
    local bx,by = (x2-x1)/2, (y2-y1)/2
    local cx,cy = poly:center()
    return vector(cx-bx,cy-by)
end

function Collider:mouseover(x, y)
    return self.shape:contains(self.entity.scene.viewport:mousePosition())
end

-- init

function Collider:init()
    self.layer = 'a'
    self.mask = 'a'
end

function Collider:add(shape, register, opts)
    local e = self.entity
    if self.shape then
        if self.shape == shape then return end
        e.scene.collider:remove(self.shape)
    end
    self.shape = shape
    shape.collider = self
    if register then e.scene.collider:register(shape) end

    if opts then
        if opts.offset then
            if opts.offset.x and opts.offset.y then self.offset = opts.offset
            else self.offset = Collider.setOffset(opts.offset)
            end
        end
        if opts.collides then
            e:registerSignal(e.scene.signals, 'collide', function () self:collide() end)
        end
        self.static = opts.static
        if opts.updates then
            e:registerSignal(e.scene.signals, 'update-collider', function() self:update() end)
        end
    end
end

-- collide & update

function Collider:collide()
    local candidates = self.entity.scene.collider:neighbors(self.shape)
    for other in pairs(candidates) do
        local e2 = other.collider.entity
        if e2.exists and e2.parent and self.mask:find(other.collider.layer) then
            local collides, dx, dy = self.shape:collidesWith(other)
            if collides and not (dx == 0 and dy == 0) then
                local e1 = self.entity
                e1.signals:emit('collide', e1, e2, vector(dx, dy))
            end
        end
    end
end

function Collider:update()
    self.shape:moveTo(self.entity:center())
    if self.offset then
        self.offset:rotateInplace(self.entity.rot - self.shape:rotation())
        self.shape:move(self.offset:unpack())
    end
    self.shape:setRotation(self.entity:rotation())
end

function Collider:setScale(s)
    self.shape:scale(s)
end

-- remove

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
