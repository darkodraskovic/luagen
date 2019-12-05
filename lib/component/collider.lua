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

-- update & collide

function Collider:update()
    local e, s = self.entity, self.shape
    s:moveTo(e:toGlobal(self.offset:unpack()))
    s:setRotation(e:rotation())
end

function Collider:collide()
    local e1 = self.entity
    if not e1._exists then return end
    
    local s1 = self.shape
    local candidates = e1.scene.collider:neighbors(s1)
    for s2 in pairs(candidates) do
        local e2 = s2.collider.entity
        if e2._exists and self.mask:find(e2.collider.layer) then
            local collides, dx, dy = s1:collidesWith(s2)
            if collides then e1.signals:emit('collide', e1, e2, vector(dx, dy)) end
        end
    end
end

-- debug

function Collider:draw(color, lineWidth)
    love.graphics.setColor(color or {0, 1, 0, 1})
    love.graphics.setLineWidth(lineWidth or 1)
    love.graphics.push()
    love.graphics.origin()
    self.entity.scene.camera:attach()
    self.shape:draw('line')
    self.entity.scene.camera:detach()
    love.graphics.pop()
end

-- remove

function Collider:remove()
    self.entity.scene.collider:remove(self.shape)
    self.entity.collider = nil
end

return Collider
