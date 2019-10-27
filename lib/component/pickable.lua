local Class = require 'lib.hump.class'

local Pickable = Class{ type = 'pickable', }

function Pickable:init()
    self.over, self._wasOver = false, false
end

function Pickable:add()
    local e, s = self.entity, self.entity.scene
    e:registerSignal(s.signals, 'update-pickable', function() self:update() end)
    e:registerSignal(s.signals, 'mousepressed', function(x, y, button) self:mousepressed(x, y, button) end)
    e:registerSignal(s.signals, 'mousereleased', function(x, y, button) self:mousereleased(x, y, button) end)
end

function Pickable:isDown(button, ...)
    return self.over and love.mouse.isDown(button, ...), self.entity.scene.viewport:mousePosition()
end

function Pickable:mousepressed(x, y, button)
    local e = self.entity
    x, y = e.scene.viewport:mousePosition()
    if self.over then e.signals:emit('mousepressed', e, x, y, button) end
end

function Pickable:mousereleased(x, y, button)
    local e = self.entity
    x, y = e.scene.viewport:mousePosition()
    if self.over then e.signals:emit('mousereleased', e, x, y, button) end
end

function Pickable:update()
    local e = self.entity
    if e.collider:mouseover() then
        self.over = true
        if not self._wasOver then
            e.signals:emit('mouseenter', e, e.scene.viewport:mousePosition())
            self._wasOver = true
        end
    else
        self.over = false
        if self._wasOver then
            e.signals:emit('mouseleave', e, e.scene.viewport:mousePosition())
            self._wasOver = false
        end
    end
end

return Pickable
