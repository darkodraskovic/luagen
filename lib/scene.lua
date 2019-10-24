local HC = require 'lib.HC'
local Class = require 'lib.hump.class'
local Signal = require 'lib.hump.signal'
local Camera = require 'lib.camera'
local Entity = require 'lib.entity'
local Timer = require 'lib.hump.timer'

local Scene = Class{}

function Scene:init()
    self.signals = Signal.new()
    self.spaceHash = HC.new(150)    
    self.collider = HC.new(150)
    self.timer = Timer.new()
        
    self.root = Entity()
    self.root.exists, self.root.visible = true, true
    
    self._entitiesToAdd = {}
    self._entitiesToRemove = {}

    self:_addCamera()
end

-- camera

function Scene:_addCamera()
    self.camera = Camera()
    self.viewport = self.camera.viewport
    self.camera.scene = self
    self.camera:setBbox(self.spaceHash)
end

-- entities

function Scene:addEntity(type, ...)
    local e = (type and type()) or Entity()
    e.scene = self
    table.insert(self._entitiesToAdd, e)
    if e.onAdd then e:onAdd(...) end
    return e
end

function Scene:_addEntities()
    for i, e in ipairs(self._entitiesToAdd) do
        e.exists, e.visible = true, true
        e:updateTransform()
    end
    self._entitiesToAdd = {}
end

function Scene:removeEntity(e)
    e.visible, e.exists = false, false
    table.insert(self._entitiesToRemove, e)
end

function Scene:_removeEntities()
    for i, e in ipairs(self._entitiesToRemove) do e:remove() end
    self._entitiesToRemove = {}   
end

-- update

function Scene:update(dt)
    self.timer:update(dt)
    self:_addEntities()
    self.signals:emit('update', dt)
    self.root:update(dt)
    self.root:updateTransformRecursive()
    self.signals:emit('collide', dt)
    self:_removeEntities()
end

-- draw

function Scene:draw()
    self.camera:updateBbox()
    self.viewport:attach()
    self.signals:emit('draw', dt)
    self.root:draw()
    self.viewport:detach()
end

-- remove

function Scene:remove()
    self.root:remove()

    self._entitiesToAdd = {}
    self._entitiesToRemove = {}
    
    self.signals:clearPattern('.*')
    self.spaceHash:resetHash()
    self.collider:resetHash()
    self.timer:clear()
end

return Scene
