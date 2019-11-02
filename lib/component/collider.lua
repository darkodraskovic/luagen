local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'
local shapes = require 'lib.HC.shapes'

local Collider = Class{ type = 'collider' }

-- utils

function Collider.setOffset(vertices)
    local poly = shapes.newPolygonShape(unpack(vertices))
    local x1,y1,x2,y2 = poly:bbox()
    local bx,by = (x2-x1)/2, (y2-y1)/2
    local cx,cy = poly:center()
    return vector(cx-bx,cy-by)
end

function Collider:mouseover(x, y)
    return self.shape:contains(self.entity.scene.camera:mousePosition())
end

-- init

function Collider:init()
    self.layer = 'a'; self.mask = 'a'
end

function Collider:add(opt)
    local e = self.entity
    e.collider = self
    
    if not opt then return end
    
    self.shape = opt.shape; opt.shape.collider = self
    if opt.register then e.scene.collider:register(self.shape) end
    self.static = opt.static
    
    local offset = opt.offset
    if offset then
        if offset.x and offset.y then self.offset = offset
        else self.offset = Collider.setOffset(offset)
        end
    end
    if opt.updates then
        e:register(e.scene.signals, 'update-collider', function() self:update() end)
    end
    if opt.collides then
        e:register(e.scene.signals, 'collide', function () self:collide() end)
    end        
end

-- collide & update

function Collider:collide()
    local e1 = self.entity
    local candidates = e1.scene.collider:neighbors(self.shape)
    for other in pairs(candidates) do
        local e2 = other.collider.entity
        if e2.exists and e2.parent and self.mask:find(other.collider.layer) then
            local collides, dx, dy = self.shape:collidesWith(other)
            if collides and not (dx == 0 and dy == 0) then
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

-- debug

function Collider:draw()
    r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(0, 1, 0, 0.5)
    self.shape:draw('line')
    love.graphics.setColor(r,g,b,a)
end

-- remove

function Collider:remove()
    self.entity.scene.collider:remove(self.shape)
    self.entity.collider = nil
end

return Collider
