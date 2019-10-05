Signal = require 'lib.hump.signal'
Spatial = require 'lib.spatial'
Signaler = require 'lib.signaler'

Entity = Class{__includes = {Spatial, Signaler}}

function Entity:init()
    Spatial.init(self)
    Signaler.init(self)
    
    self.name = ""
    self.components = {}
end

-- bbox

function Entity:updateBbox()
    self.bbox:moveTo(self:center());
    self.bbox:setRotation(self:rotation())
end

function Entity:onScreen()
    if not self.bbox then return end
    self:updateBbox()
    return self.bbox:collidesWith(self.scene.camera.bbox)
end

-- components

function Entity:addComponent(type_)
    local c = type_()
    table.insert(self.components, c)
    c.entity = self
    return c
end

function Entity:removeComponent(c)
    if c.remove then c:remove() end
    for i,v in ipairs(self.components) do
        if c == v then
            table.remove(self.components, i)
            break
        end
    end
end

function Entity:removeComponents()
    for _, c in pairs(self.components) do
        if c.remove then c:remove() end
    end
    self.components = {}
end

-- update

function Entity:update(dt)
    if not self.exists then return end
    
    for i,e in ipairs(self.children) do
        e:update(dt)
    end
end

-- draw

function Entity:draw()
    if not self.visible then return end
    
    self:updateTransform()
    for i,e in ipairs(self.children) do
        e:draw()
    end
end

-- remove

function Entity:removeDeferred()
    self.scene:removeEntity(self)
end

function Entity:remove()
    Spatial.remove(self)
    Signaler.remove(self)
    
    if self.bbox then self.scene.spaceHash:remove(self.bbox) end
        
    self:removeComponents()
end

return Entity
