local Class = require 'lib.hump.class'

local Spatial = require 'lib.core.spatial'

local Entity = Class{__includes = Spatial}

function Entity:init()
    Spatial.init(self)

    self.components = {}
    self.properties = {} -- user defined properties
end

function Entity:add(opt)
    if not opt then return end

    if opt.name and string.len(opt.name) > 0 then self.name = opt.name end
    if opt.parent then opt.parent:addChild(self) end
    
    if opt.pos then self.pos = opt.pos:clone() end
    if opt.scl then self.scl = opt.scl:clone() end
    self.rot = opt.rot or self.rot
    if opt.offset then self.offset = opt.offset:clone() end
end

function Entity:enter() -- on scene enter
    if self.parent then self:updateTransform() end
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

function Entity:removeDeffered()
    self.scene:removeEntity(self)
end

function Entity:remove()
    for _, c in pairs(self.components) do self:removeComponent(c) end
    Spatial.remove(self)
end

return Entity
