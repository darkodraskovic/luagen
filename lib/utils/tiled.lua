Class = require 'lib.hump.class'
polygon = require 'lib.HC.polygon'

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

-- MAP

function Tiled.parseMap(map, scene)
    for i,layerData in ipairs(map.layers) do
        local l = scene:addEntity()
        l.name = layerData.name
        scene.root:addChild(l)
        for k,v in pairs(layerData.properties) do l[k] = v end
        if layerData.type == 'objectgroup' then
            Tiled.parseObjectgroup(layerData, l, scene)
        end
    end    
end

function Tiled.parseObjectgroup(layerData, layer, scene)
    for i,o in ipairs(layerData.objects) do
        if not _G[o.type] then require('entities.' .. o.type:lower()) end
        local o = Class.clone(o)
        if o.shape == 'polygon' then
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
