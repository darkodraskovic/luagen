local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Spatial = Class{}

function Spatial:init()
    self.transform = love.math.newTransform()
    self.pos = vector(0,0)
    self.rot = 0
    self.scale = vector(1,1)
    self.size = vector(0,0)
    self.anchor = vector(0,0)
    
    self.parent = nil
    self.children = {}
end

-- transform

function Spatial:updateTransform()
    self.transform:setTransformation(
        self.pos.x, self.pos.y, self.rot, self.scale.x, self.scale.y,
        self.anchor.x * self.size.x, self.anchor.y * self.size.y)
    if self.parent then
        self.transform = self.parent.transform * self.transform
    end
end

function Spatial:updateTransformRecursive()
    self:updateTransform()
    for i,c in ipairs(self.children) do c:updateTransformRecursive() end
end

-- globals

function Spatial:position()
    local mat  = {self.transform:getMatrix()}
    return mat[4], mat[8]
end

function Spatial:rotation()
    local mat  = {self.transform:getMatrix()}
    return math.atan2(mat[5], mat[1])
end

function Spatial:center()
    return self.transform:transformPoint(self.size.x/2, self.size.y/2)
end

-- children

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
            break
        end
    end
end

function Spatial:removeChildren()
    for i,c in ipairs(self.children) do c.parent = nil end
    self.children = {}
end

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

-- update

function Spatial:update(dt)
    for i,c in ipairs(self.children) do c:update(dt) end
end

function Spatial:draw()
    for i,c in ipairs(self.children) do c:draw() end
end


-- remove

function Spatial:remove()
    local parent = self.parent
    if self.parent then self.parent:removeChild(self) end
    for i,c in ipairs({unpack(self.children)}) do
        self:removeChildren() -- children don't call self.parent:removeChild(self)
        c:remove() -- tree traversal
    end
end

return Spatial
