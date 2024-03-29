local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Pickable = require 'lib.component.pickable'

local Draggable = Class{ type = 'draggable', }

function Draggable:add(opt)
    local e = self.entity
    if not e.components['pickable'] then e:addComponent(Pickable) end
    e:register('pre-update', function() self:update() end)
    e:register(e.signals, 'mousepressed', function(...) self:mousepressed(...) end)
    e:register(e.scene.signals, 'mousereleased', function(...) self:mousereleased(...) end)
    
    self.limit = opt and opt.limit
    self.button = (opt and opt.button) or 1
end

function Draggable:mousepressed(e, x, y, button)
    if button == self.button then self.dragged = vector(x,y) - vector(e:toGlobal(e.offset:unpack())) end
end

function Draggable:mousereleased(x, y, button)
    if button == self.button then self.dragged = nil end
end

function Draggable:update()
    if not self.dragged then return end

    local e = self.entity
    local x, y = e.scene.camera:mousePosition()
    local globalPos = vector(x,y) - self.dragged
    local lx, ly = e.parent:toLocal((globalPos):unpack())
    
    local lim = self.limit
    if lim then
        e.pos.x = math.max(lim.x[1], math.min(lim.x[2], lx))
        e.pos.y = math.max(lim.y[1], math.min(lim.y[2], ly))
    else
        e.pos.x, e.pos.y = lx, ly
    end
end

return Draggable
