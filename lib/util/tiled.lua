local polygon = require 'lib.HC.polygon'
local shapes = require 'lib.HC.shapes'
local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local hex2rgb = function(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255, tonumber("0x"..hex:sub(7,8))/255, tonumber("0x"..hex:sub(1,2))/255
end

local Tiled = {}

-- POLYGON

function Tiled.processVertices(vertices)
    local vs = {}

    --flatten vertices
    for i,v in ipairs(vertices) do table.insert(vs, v.x); table.insert(vs, v.y) end

    -- move vertices to 1st quadrant    
    local dx,dy,x1,y1 = 0,0,polygon(unpack(vs)):bbox()
    if x1 < 0 then
        for i=1,#vs,2 do vs[i] = vs[i]-x1 end
        dx = x1
    end
    if y1 < 0 then
        for i=2,#vs,2 do vs[i] = vs[i]-y1 end
        dy = y1
    end
    
    return vs, dx, dy -- negative offset or zero
end

-- SHAPE

function Tiled.getShape(o)
    local w, h = o.width, o.height
    local shape, offset
    if o.shape == 'rectangle' then
        shape = shapes.newPolygonShape(0,0, w,0, w,h, 0,h)
        offset = vector(shape:center())
    elseif o.shape == 'ellipse' then
        shape = shapes.newCircleShape(0,0,w/2) 
        offset = vector(w/2, w/2)
    elseif o.shape == 'polygon' then
        shape = shapes.newPolygonShape(unpack(o.properties.vertices))
        offset = vector(shape:center())
    end
    return shape, offset
end

-- DRAW

function Tiled._drawObject(o, ...)
    local fill, line = o.properties.fill, o.properties.line
    if fill then
        love.graphics.setColor(hex2rgb(fill))
        love.graphics[o.shape]('fill',...)
    end
    if line then
        love.graphics.setColor(hex2rgb(line))
        love.graphics[o.shape]('line',...)
    end
end

function Tiled.drawObject(o, transform)
    love.graphics.push()
    if transform then love.graphics.applyTransform(transform) end
    
    for k,v in pairs(o.properties) do
        if love.graphics['set' .. k] then love.graphics['set' .. k](v) end
    end
    
    if o.shape == 'rectangle' then
        Tiled._drawObject(o, 0, 0, o.width, o.height)
    elseif o.shape == 'ellipse' then
        local radiusx, radiusy = o.width/2, o.height/2
        love.graphics.translate(radiusx, radiusy)
        Tiled._drawObject(o, 0, 0, radiusx, radiusy)
    elseif o.shape == 'polygon' then
        Tiled._drawObject(o, unpack(o.properties.vertices))
    end

    love.graphics.pop()
end

-- MAP

function Tiled.parseMap(map, scene, root)
    root = root or scene.root
    for i,layerData in ipairs(map.layers) do
        local layer = scene:addEntity()
        layer.name = layerData.name
        layer.visible = layerData.visible
        root:addChild(layer)
        for k,v in pairs(layerData.properties) do layer.properties[k] = v end
        if Tiled[layerData.type] then
            Tiled[layerData.type](layerData, layer, scene)
        end
    end    
end

function Tiled.objectgroup(layerData, layer, scene)
    local edir = layerData.properties.edir or 'entity'
    local cdir = layerData.properties.cdir or 'component'
    
    for i,o in ipairs(layerData.objects) do
        local o = Class.clone(o)
        if o.shape == 'polygon' then
            local dx, dy
            o.properties.vertices, dx, dy = Tiled.processVertices(o.polygon)
            o.x = o.x + dx; o.y = o.y + dy
        end
        
        local e = scene:addEntity(require(edir .. '.' .. o.type:lower()), o)
        e.pos = vector(o.x, o.y)
        layer:addChild(e)

        for component in string.gmatch(o.properties.components or "", "[^,]+") do
            e:addComponent(require(cdir .. '.' .. component:lower()), o.properties)
        end

        for k,v in pairs(o.properties) do e.properties[k] = v end
        if e.properties['{}'] then
            _e = e
            assert(loadstring(o.properties['{}']))()
            _e = nil
        end
        
        if e.tiled then e:tiled(o) end
    end    
end

return Tiled
