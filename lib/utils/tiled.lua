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
    for i,v in ipairs(map.layers) do
        local l = scene:addEntity()
        l.name = v.name
        scene.root:addChild(l)
        Tiled.setProperties(v,l)
        if v.type == 'objectgroup' then
            Tiled.parseObjectgroup(v, l, scene)
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
        e.signals:emit('tiled', o)
        Tiled.setProperties(o,e)
    end    
end

function Tiled.setProperties(o, e)
    _tiled_e = e
    local expr = ''
    for k,v in pairs(o.properties) do
        expr = expr .. '_tiled_e.' .. k .. '=' .. v .. ';'
    end
    assert(loadstring(expr))()
    _tiled_e = nil
end

return Tiled
