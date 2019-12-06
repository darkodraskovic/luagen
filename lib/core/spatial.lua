local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Signaler = require 'lib.core.signaler'

local Spatial = Class{
    __includes = Signaler,
    _transform = love.math.newTransform(),
}

function Spatial:init()
    Signaler.init(self)
    self.transform = love.math.newTransform()
    
    self.pos = vector(0,0)
    self.rot = 0
    self.scl = vector(1,1)
    self.offset = vector(0,0)
    
    self.parent = nil
    self.children = {}
    
    self._exists =  false
    self.visible =  true
end

-- transform matrix

function Spatial:updateTransform()
    Spatial._transform:setTransformation(
        self.pos.x, self.pos.y, self.rot, self.scl.x, self.scl.y,
        self.offset.x, self.offset.y)
    self.transform:setMatrix(self.parent.transform:getMatrix()):apply(Spatial._transform)
end

function Spatial:updateTransformRecursive()
    for i,c in ipairs(self.children) do
        c:updateTransform()
        c:updateTransformRecursive()
    end
end

-- transform point

function Spatial:position()
    local _,_,_,x, _,_,_,y  = self.transform:getMatrix()
    return x, y
end

function Spatial:rotation()
    local x,_,_,_,y  = self.transform:getMatrix()
    return math.atan2(y, x)
end

function Spatial:scale()
    local x1,y1,_,_,x2,y2  = self.transform:getMatrix()
    return vector(x1,y1):len(), vector(x2,y2):len()
end

function Spatial:toLocal(x, y)
    return self.transform:inverseTransformPoint(x,y)
end

function Spatial:toGlobal(x, y)
    return self.transform:transformPoint(x,y)
end

-- add & remove children

function Spatial:addChild(c)
    if c.parent then c.parent:removeChild(c) end
    c.parent = self    
    table.insert(self.children, c)
end

function Spatial:removeChild(c)
    for i,v in ipairs(self.children) do
        if c == v then
            table.remove(self.children, i)
            c.parent = nil
            return
        end
    end
end

-- get & find children

function Spatial:_getChildren(children)
    if #self.children < 1 then return end
    for i, c in ipairs(self.children) do
        table.insert(children, c)
        c:_getChildren(children)
    end
end

function Spatial:getChildren()
    local children = {}
    self:_getChildren(children)
    return children
end

function Spatial:findChild(k,v)
    for i,c in ipairs(self:getChildren()) do
        if c[k] == v then return c end
    end
end

function Spatial:getChildIndex(child)
    for i,v in ipairs(self.children) do
        if v == child then return i end
    end
end

-- update & draw

function Spatial:_update(dt)
    self.signals:emit('pre-update', dt)
    self:update(dt)
    self.signals:emit('post-update', dt)    
end

function Spatial:update(dt)
    for i,c in ipairs(self.children) do
        if c._exists then c:_update(dt) end
    end
end

function Spatial:_draw()
    Spatial._transform:setTransformation(
        self.pos.x, self.pos.y, self.rot, self.scl.x, self.scl.y,
        self.offset.x, self.offset.y)    
    love.graphics.push()
    love.graphics.applyTransform(self._transform)
    self.signals:emit('pre-draw')
    self:draw()
    self.signals:emit('post-draw')
    love.graphics.pop()
end

function Spatial:draw()
    for i,c in ipairs(self.children) do
        if c.visible then c:_draw() end
    end
end

-- remove

function Spatial:remove()
    for i,c in ipairs(self.children) do c:remove() end
    if self.parent then self.parent:removeChild(self) end
    Signaler.remove(self)
end

return Spatial
