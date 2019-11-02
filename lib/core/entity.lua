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
    self.signals:emit('update-component', dt)
    Spatial.update(self, dt)
end

function Entity:draw()
    if not self.visible then return end
    self:emit('draw-component', dt)
    Spatial.draw(self)
end

-- remove & module

function Entity:remove()
    for _, c in pairs(self.components) do self:removeComponent(c) end
    Spatial.remove(self)
    Signaler.remove(self)
end

return Entity
