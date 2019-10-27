local polygon = require 'lib.HC.polygon'
local shapes = require 'lib.HC.shapes'
local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local resourceManager = require 'lib.core.resource-manager'
local Sprite = require 'lib.core.sprite'
local Color = require 'lib.util.color'

local Tiled = {}

-- POLYGON

function Tiled.flattenVertices(vertices)
    local verts = {}
    for i,v in ipairs(vertices) do
        table.insert(verts, v.x)
        table.insert(verts, v.y)
    end
    return verts
end

function Tiled.transformPolygon(o)
    local verts = Tiled.flattenVertices(o.polygon)
    local x1,y1 = polygon(unpack(verts)):bbox()
    local dx,dy = 0,0
    if x1 < 0 then
        for i=1,#verts,2 do verts[i] = verts[i]-x1 end
        dx = x1
    end
    if y1 < 0 then
        for i=2,#verts,2 do verts[i] = verts[i]-y1 end
        dy = y1
    end
    return verts, dx, dy
end

-- SHAPE

function Tiled.getShape(o)
    local shape
    if o.shape == 'rectangle' then
        shape = shapes.newPolygonShape(
            0,0, o.width,0,
            o.width, o.height, 0, o.height)
    elseif o.shape == 'ellipse' then
        shape = shapes.newCircleShape(0,0,o.width/2)
    elseif o.shape == 'polygon' then
        local verts = o.vertices or Tiled.transformPolygon(o)
        shape = shapes.newPolygonShape(unpack(verts))
    end
    return shape
end

-- DRAW

function Tiled._drawObject(o, ...)
    local fill, line = o.properties.fill, o.properties.line
    if fill then
        love.graphics.setColor(unpack(Color.hex2rgb(fill, true)))
        love.graphics[o.shape]('fill',...)
    end
    if line then
        love.graphics.setColor(unpack(Color.hex2rgb(line, true)))
        love.graphics[o.shape]('line',...)
    end
end

function Tiled.drawObject(o, pos)
    love.graphics.push()
    local x,y
    if pos then x,y = pos:unpack() else x,y = 0,0 end
    love.graphics.translate(x, y)
    
    for k,v in pairs(o.properties) do
        if love.graphics['set' .. k] then love.graphics['set' .. k](v) end
    end

    if o.shape == 'rectangle' then
        Tiled._drawObject(o, 0, 0, o.width, o.height)
    elseif o.shape == 'ellipse' then
        local radiusx, radiusy = o.width/2, o.height/2
        love.graphics.push()
        love.graphics.translate(radiusx, radiusy)
        Tiled._drawObject(o, 0, 0, radiusx, radiusy)
        love.graphics.pop()
    elseif o.shape == 'polygon' then
        local vertices = o.vertices or Tiled.transformPolygon(o)
        Tiled._drawObject(o, unpack(vertices))
    end

    love.graphics.pop()
end

function Tiled.getImage(o)
    local w,h
    if o.shape == 'polygon' then
        o.vertices = o.vertices or Tiled.transformPolygon(o)
        local poly = polygon(unpack(o.vertices))
        local x1,y1,x2,y2 = poly:bbox()
        w,h = x2-x1, y2-y1
    else
        w,h = o.width, o.height
    end
    local lw = o.properties['LineWidth'] or 0
    local canvas = love.graphics.newCanvas(w+lw, h+lw)
    love.graphics.clear()
    
    love.graphics.push()
    if lw then love.graphics.translate(lw/2, lw/2) end
    love.graphics.setCanvas(canvas)
    Tiled.drawObject(o)
    love.graphics.pop()
    
    love.graphics.reset()
    return canvas
end

-- ENTITIES

function Tiled.parseMap(map, scene, root)
    root = root or scene.root
    for i,layerData in ipairs(map.layers) do
        local layer = scene:addEntity()
        layer.name = layerData.name
        layer.visible = layerData.visible
        layer.alpha = layerData.opacity
        layer.offset = vector(layerData.offsetx, layerData.offsety)
        root:addChild(layer)
        for k,v in pairs(layerData.properties) do layer[k] = v end
        if Tiled[layerData.type] then
            Tiled[layerData.type](layerData, layer, scene)
        end
    end    
end

function Tiled.imagelayer(layerData, layer, scene)
    local s = scene:addEntity(Sprite)
    local img = resourceManager:getImage(layerData.image)
    s:setImage(img)
    layer:addChild(s)
end

function Tiled.objectgroup(layerData, layer, scene)
    local edir = layerData.properties.edir or 'entity'
    local cdir = layerData.properties.cdir or 'component'
    
    for i,o in ipairs(layerData.objects) do
        local o = Class.clone(o)
        if o.shape == 'polygon' then
            local dx, dy
            o.vertices, dx, dy = Tiled.transformPolygon(o)
            o.x = o.x + dx; o.y = o.y + dy
        end
        
        local e = scene:addEntity(require(edir .. '.' .. o.type:lower()), o)
        e.pos = vector(o.x, o.y)
        layer:addChild(e)

        for component in string.gmatch(o.properties.components or "", "[^,]+") do
            e:addComponent(require(cdir .. '.' .. component:lower()))
        end
        
        if string.len(o.name) > 0 then e.name = o.name end
        for k,v in pairs(o.properties) do e.properties[k] = v end
        if e.properties['<>'] then
            _e = e
            assert(loadstring(o.properties['<>']))()
            _e = nil
        end
        
        if e.tiled then e:tiled(o) end
    end    
end

return Tiled
