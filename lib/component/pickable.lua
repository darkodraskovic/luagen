local Class = require 'lib.hump.class'

local Pickable = Class{ type = 'pickable', }

function Pickable:add()
    local e, s = self.entity, self.entity.scene
    
    e:register('pre-update', function() self:update() end)
    e:register(s.signals, 'mousepressed', function(x, y, button) self:mousepressed(x, y, button) end)
    e:register(s.signals, 'mousereleased', function(x, y, button) self:mousereleased(x, y, button) end)
end

function Pickable:isDown(button, ...)
    return self.over and love.mouse.isDown(button, ...), self.entity.scene.camera:mousePosition()
end

function Pickable:mousepressed(x, y, button)
    local e = self.entity
    x, y = e.scene.camera:mousePosition()
    if self.over then e.signals:emit('mousepressed', e, x, y, button) end
end

function Pickable:mousereleased(x, y, button)
    local e = self.entity
    x, y = e.scene.camera:mousePosition()
    if self.over then e.signals:emit('mousereleased', e, x, y, button) end
end

function Pickable:update()
    local e = self.entity
    if e.collider:mouseover() then
        self.over = true
        if not self._wasOver then
            e.signals:emit('mouseenter', e, e.scene.camera:mousePosition())
            self._wasOver = true
        end
    else
        self.over = false
        if self._wasOver then
            e.signals:emit('mouseleave', e, e.scene.camera:mousePosition())
            self._wasOver = false
        end
    end
end

return Pickable
