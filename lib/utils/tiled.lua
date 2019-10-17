local Class = require 'lib.hump.class'
local polygon = require 'lib.HC.polygon'
local shapes = require 'lib.HC.shapes'
local Sprite = require 'lib.sprite'
local resourceManager = require 'lib.resource-manager'

local Tiled = {}

-- HELPERS

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

-- MAP

function Tiled.parseMap(map, scene)
    for i,layerData in ipairs(map.layers) do
        local layer = scene:addEntity()
        layer.name = layerData.name
        layer.visible = layerData.visible
        layer.alpha = layerData.opacity
        layer.offset = vector(layerData.offsetx, layerData.offsety)
        scene.root:addChild(layer)
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
    for i,o in ipairs(layerData.objects) do
        if not _G[o.type] then require('entities.' .. o.type:lower()) end
        local o = Class.clone(o)
        if o.shape == 'polygon' then
            local dx, dy
            o.vertices, dx, dy = Tiled.transformPolygon(o)
            o.x = o.x + dx; o.y = o.y + dy
        end
        local e = scene:addEntity(_G[o.type], o)
        e.pos = vector(o.x, o.y)
        layer:addChild(e)
        e.name = o.name
        for k,v in pairs(o.properties) do e[k] = v end
        e.signals:emit('tiled', o)
    end    
end

return Tiled
