local HC = require 'lib.HC'
local Class = require 'lib.hump.class'
local Timer = require 'lib.hump.timer'

local Camera = require 'lib.hump.camera'
local Spatial = require 'lib.core.spatial'
local Entity = require 'lib.core.entity'

local Scene = Class{__includes = Spatial}

function Scene:init()
    Spatial.init(self)
    
    self.collider = HC.new(150)
    self.timer = Timer.new()
    self.camera = Camera()
    
    self._entitiesToAdd = {}
    self._entitiesToRemove = {}
    
    self.properties = {}
end

-- entities

function Scene:addEntity(type, opt)
    type = type or Entity
    local e = type()
    e.scene = self
    table.insert(self._entitiesToAdd, e)
    e:add(opt) -- e is aware of scene now
    return e
end

function Scene:_addEntities()
    for i, e in ipairs(self._entitiesToAdd) do
        e._exists = true
        e:enter()
    end
    self._entitiesToAdd = {}
end

function Scene:removeEntity(e)
    e._exists = false
    table.insert(self._entitiesToRemove, e)
end

function Scene:_removeEntities()
    for i, e in ipairs(self._entitiesToRemove) do e:remove() end
    self._entitiesToRemove = {}
end

-- callbacks

function Scene:update(dt)
    self.timer:update(dt)
    self:_addEntities()
    Spatial.update(self, dt)
    self:emit('update-physics', dt)
    self:setTransform()
    self:updateTransformRecursive()
    self:emit('update-collider', dt)
    self:emit('collide', dt)
    self:_removeEntities()
end

function Scene:draw()
    self.camera:attach()
    Spatial.draw(self)
    self.camera:detach()
end

-- remove

function Scene:remove()
    for i, e in ipairs(self._entitiesToRemove) do e:remove() end
    self._entitiesToRemove = {}    

    for i, e in ipairs(self._entitiesToAdd) do e:remove() end
    self._entitiesToAdd = {}
    
    Spatial.remove(self)
    
    self.collider:resetHash()
    self.timer:clear()
end

return Scene
