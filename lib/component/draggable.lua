local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Pickable = require 'lib.component.pickable'

local Draggable = Class{ type = 'draggable', }

function Draggable:add(opt)
    local e = self.entity
    if not e.components['pickable'] then e:addComponent(Pickable) end
    e:register('update-component', function() self:update() end)
    e:register(e.signals, 'mousepressed', function(...) self:mousepressed(...) end)
    e:register(e.scene.signals, 'mousereleased', function(...) self:mousereleased(...) end)
    self.limit = opt and opt.limit
end

function Draggable:mousepressed(e, x, y, button)
    self.mousePosDiff = vector(x,y) - vector(e:position())
end

function Draggable:mousereleased(x, y, button)
    self.mousePosDiff = nil
end

function Draggable:update()
    local _, x, y = self.entity.components['pickable']:isDown(1)
    if self.mousePosDiff then
        local e = self.entity
        local globalPos = vector(x,y) - self.mousePosDiff
        local lx, ly = e:toLocal(globalPos:unpack())
        local lim = self.limit
        if lim then
            e.pos.x = math.max(lim.x[1], math.min(lim.x[2], lx))
            e.pos.y = math.max(lim.y[1], math.min(lim.y[2], ly))
        end
    end
end

return Draggable
