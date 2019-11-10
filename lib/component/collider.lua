local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'
local shapes = require 'lib.HC.shapes'

local Collider = Class{ type = 'collider' }

-- utils

function Collider:mouseover()
    return self.shape:contains(self.entity.scene.camera:mousePosition())
end

-- init

function Collider:init()
    self.offset = vector(0,0)
    self.layer, self.mask = 'a', 'a'
end

function Collider:add(opt)    
    local e = self.entity
    e.collider = self
    
    self.shape = opt.shape; opt.shape.collider = self
    e.scene.collider:register(self.shape)
    
    self.static = opt.static
    self.offset = opt.offset or self.offset

    if opt.updates ~= false then
        e:register(e.scene.signals, 'update-collider', function() self:update() end)
    end
    if opt.collides ~= false then
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
    local e, s = self.entity, self.shape
    s:moveTo(e:toGlobal(self.offset:unpack()))
    s:setRotation(e:rotation())
end

-- debug

function Collider:draw(color, lineWidth)
    r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(color or {0, 1, 0, 1})
    love.graphics.setLineWidth(lineWidth or 1)
    self.shape:draw('line')
    love.graphics.setColor(r,g,b,a)
end

-- remove

function Collider:remove()
    self.entity.scene.collider:remove(self.shape)
    self.entity.collider = nil
end

return Collider
