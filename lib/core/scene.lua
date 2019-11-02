local HC = require 'lib.HC'
local Class = require 'lib.hump.class'
local Signal = require 'lib.hump.signal'
local Timer = require 'lib.hump.timer'

local Camera = require 'lib.hump.camera'
local Entity = require 'lib.core.entity'

local Scene = Class{}

function Scene:init()
    self.signals = Signal.new()
    self.collider = HC.new(150)
    self.timer = Timer.new()
        
    self.root = Entity()
    self.root.exists, self.root.visible = true, true
    
    self._entitiesToAdd = {}
    self._entitiesToRemove = {}

    self.camera = Camera()
end

-- entities

function Scene:addEntity(type, opt)
    type = type or Entity
    local e = (type and type()) or Entity()
    e.scene = self
    table.insert(self._entitiesToAdd, e)
    if e.add then e:add(opt) end
    return e
end

function Scene:_addEntities()
    for i, e in ipairs(self._entitiesToAdd) do
        e.exists, e.visible = true, true
        e:enter()
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
    self.root:update(dt)
    self.signals:emit('update-physics', dt)
    self.root:updateTransformRecursive()
    self.signals:emit('update-collider', dt)
    self.signals:emit('collide', dt)
    self:_removeEntities()
end

-- draw

function Scene:draw()
    self.camera:attach()
    self.root:draw()
    self.camera:detach()
end

-- remove

function Scene:remove()
    self.root:remove()

    self._entitiesToAdd = {}
    self._entitiesToRemove = {}
    
    self.signals:clearPattern('.*')
    self.collider:resetHash()
    self.timer:clear()
end

return Scene
