local HC = require 'lib.HC'
local Class = require 'lib.hump.class'
local Signal = require 'lib.hump.signal'
local Timer = require 'lib.hump.timer'

local Camera = require 'lib.hump.camera'
local Spatial = require 'lib.core.spatial'
local Entity = require 'lib.core.entity'
local Signaler = require 'lib.core.signaler'

local Scene = Class{__includes = Signaler}

function Scene:init()
    Signaler.init(self)
    
    self.collider = HC.new(150)
    self.timer = Timer.new()
    self.camera = Camera()
    
    self.root = Spatial()
    self.root._exists, self.root.visible = true, true
    self._entitiesToAdd = {}
    self._entitiesToRemove = {}
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

-- update

function Scene:update(dt)
    self.timer:update(dt)
    self:_addEntities()
    self.root:update(dt)
    self:emit('update-physics', dt)
    self.root:updateTransformRecursive()
    self:emit('update-collider', dt)
    self:emit('collide', dt)
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

    self.collider:resetHash()

    self.timer:clear()
    Signaler.remove(self)    
end

return Scene
