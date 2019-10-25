local lu = require 'luaunit.luaunit'
local love = require 'love_mocks'
local Class = require 'lib.hump.class'
local Scene = require 'lib.scene'
local Spatial = require 'lib.spatial'
local Entity = require 'lib.entity'

unpack = unpack or table.unpack

-----------
-- SCENE --
-----------

-- entities

local pows = 3

function addEntities(numEntities)
    local scene = Scene()

    for i=1,numEntities do
        local e = scene:addEntity(Entity)
        scene.root:addChild(e)
    end
    scene:update()
    
    return #scene.root.children
end

function removeEntities(numEntities)
    local scene = Scene()
    
    addEntities(numEntities)
    for i,e in ipairs(scene.root.children) do
        scene:removeEntity(e)
    end
    scene:update()

    return #scene.root.children
end

-- TESTS

TestScene = {}

-- entities

function TestScene:testAddEntities()
    lu.assertEquals(addEntities(0), 0)
    for i=1,pows do
        lu.assertEquals(addEntities(10^i), 10^i)
    end
end

function TestScene:testRemoveEntities()
    lu.assertEquals(removeEntities(0), 0)
    for i=1,pows do
        lu.assertEquals(removeEntities(10^i), 0)
    end
end

-------------
-- SPATIAL --
-------------

function addChildren(numChildren)
    local s = Spatial()

    for i=1, numChildren  do
        s:addChild(Spatial())
    end

    return #s.children
end

function _addChildrenRecursive(parent, numSteps, numChildren)
    if numSteps < 1 then return end
    numSteps = numSteps - 1
    
    for i=1,numChildren do
        local c = Spatial()
        parent:addChild(c)
        _addChildrenRecursive(c, numSteps, numChildren)
    end
end

function addChildrenRecursive(numSteps, numChildren)
    local s = Spatial()
    _addChildrenRecursive(s, numSteps, numChildren)
    
    local sum = 0
    for i=1, numSteps do
        sum = sum + numChildren^i
    end
    
    return sum == #s:getChildren()
end

function removeChild(numIter)
    local s = Spatial()
    
    for i=1, numIter do
        local c = Spatial()
        s:addChild(c)
        s:removeChild(c)
    end
    
    return #s.children
end

function removeChildren(numChildrenToAdd, numChildrenToRemove)
    local s = Spatial()

    for i=1, numChildrenToAdd do
        s:addChild(Spatial())
    end

    for i=1, numChildrenToRemove do
        local j = math.random(1, #s.children)
        s:removeChild(s.children[j])
    end

    return numChildrenToAdd-numChildrenToRemove == #s.children
end

function spatialRemove(numSteps, numChildren)
    local s = Spatial()
    _addChildrenRecursive(s, numSteps, numChildren)

    s:remove()

    return #s:getChildren()
end

-- TESTS

TestSpatial = {}

function TestSpatial:setUp()
    self.recursionCases = {
        {0,0}, {0,1}, {0,2},
        {1,0}, {1,1}, {1,2},
        {1,5}, {2,4}, {5,3},
        {10,2},
    }
end

function TestSpatial:testAddChildren()
    lu.assertEquals(addChildren(0), 0)
    for i=1,pows do
        lu.assertEquals(addChildren(10^i), 10^i)
    end
end

function TestSpatial:testAddChildrenRecursive()
    for k,v in ipairs(self.recursionCases) do
        lu.assertEquals(addChildrenRecursive(unpack(v)), true)
    end
end

function TestSpatial:testRemoveChild()
    lu.assertEquals(removeChild(0), 0)
    for i=1,pows do
        lu.assertEquals(removeChild(10^i), 0)
    end
end

function TestSpatial:testRemoveChildren()
    local upperL = 20
    for i=1, upperL do
        lu.assertEquals(removeChildren(upperL,i), true)
    end
end

function TestSpatial:testSpatialRemove()
    for k,v in ipairs(self.recursionCases) do
        lu.assertEquals(spatialRemove(unpack(v)), 0)
    end
end

-----------
-- ETITY --
-----------

function removeComponents(numComponentsToAdd, numComponentsToRemove)
    local e = Entity()
    local C = Class()

    for i=1, numComponentsToAdd do
        e:addComponent(C)
    end

    for i=1, numComponentsToRemove do
        local j = math.random(1, #e.components)
        e:removeComponent(e.components[j])
    end

    return numComponentsToAdd-numComponentsToRemove == #e.components
end

-- TESTS

TestEntity = {}

-- function TestSpatial:setUp()
-- end

function TestEntity:testRemoveComponents()
    local upperL = 20
    for i=1, upperL do
        lu.assertEquals(removeComponents(upperL,i), true)
    end
end

-------------
-- LUAUNIT --
-------------

os.exit(lu.LuaUnit.run('--pattern', '.*'))
