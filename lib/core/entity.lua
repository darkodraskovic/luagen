local Class = require 'lib.hump.class'

local Spatial = require 'lib.core.spatial'
local Signaler = require 'lib.core.signaler'

local Entity = Class{__includes = {Spatial, Signaler}}

function Entity:init()
    Spatial.init(self)
    Signaler.init(self)
    self.components = {}
    self.properties = {} -- user defined properties
end

function Entity:enter()
    self:updateTransform()
    if self.collider then self.collider:update() end
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

function Entity:addComponent(type, opt)
    local c = type()
    c.entity = self
    self.components[c.type] = c
    if c.add then c:add(opt) end
    return c
end

function Entity:removeComponent(c)
    if c.remove then c:remove() end
    self.components[c.type] = nil
end

-- update & draw

function Entity:update(dt)
    if not self.exists then return end
    Spatial.update(self, dt)
end

function Entity:draw()
    if not self.visible then return end
    Spatial.draw(self)
end

-- remove & module

function Entity:remove()
    for _, c in pairs(self.components) do self:removeComponent(c) end
    Spatial.remove(self)
    Signaler.remove(self)
    if self.bbox then self.scene.spaceHash:remove(self.bbox) end
end

return Entity
