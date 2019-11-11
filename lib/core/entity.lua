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

function Entity:add(opt)
    if not opt then return end

    if opt.name and string.len(opt.name) > 0 then self.name = opt.name end
    self.pos = (opt.pos and opt.pos:clone()) or self.pos
    self.scl = (opt.scl and opt.scl:clone()) or self.scl
    self.rot = opt.rot or self.rot
    self.offset = opt.offset or self.offset
    if opt.parent then opt.parent:addChild(self) end
end

function Entity:enter() -- on scene enter
    self:updateTransform()
    if self.collider then self.collider:update() end
end

-- components

function Entity:addComponent(type, opt)
    local c = type()
    c.entity = self
    self.components[c.type] = c
    if c.add then c:add(opt) end  -- c is aware of entity now
    return c
end

function Entity:removeComponent(c)
    if c.remove then c:remove() end
    self.components[c.type] = nil
end

-- update & draw

function Entity:update(dt)
    self.signals:emit('update-component', dt)
    Spatial.update(self, dt)
end

function Entity:draw()
    self:emit('draw-component', dt)
    Spatial.draw(self)
end

-- remove & module

function Entity:removeDeffered()
    self.scene:removeEntity(self)
end

function Entity:remove()
    for _, c in pairs(self.components) do self:removeComponent(c) end
    Spatial.remove(self)
    Signaler.remove(self)
end

return Entity
