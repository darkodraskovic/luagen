local Class = require 'lib.hump.class'
local vector = require 'lib.hump.vector'

local Physics = Class{
    type = 'physics',
}

function Physics:init()
    self.mass = 1
    self.vel = vector(0,0)
    self.maxVel = 1000
    self.minVel = 10
    self.acc = vector(0,0)
    self.grav = vector(0,0)
    self.frict = 0
    self.drag = 0
    self.dragFactor = 10e-3
    self.elastic = 1
end

function Physics:add(collides)
    local e = self.entity
    e:registerSignal(e.scene.signals, 'update-physics', function(dt) self:update(dt) end)
    if collides then e:registerSignal(e.signals, 'collide', Physics.collide) end
end

function Physics.collide(entity, other, delta)
    local phy1, phy2 = entity.physics, other.physics
    if phy1.dynamic and phy2 and phy2.dynamic then
        local sepInv = 1 / (phy1.mass + phy2.mass)
        entity.pos = entity.pos + delta * (phy2.mass * sepInv)
        other.pos = other.pos - delta * (phy1.mass * sepInv)
        Physics.resolveImpulse(phy1, phy2, delta)
    elseif other.collider.static then
        entity.pos = entity.pos + delta
        phy1:bounce(delta)
    end
end

function Physics.resolveImpulse(phy1, phy2, delta)
    local massInv1 = 1 / phy1.mass
    local massInv2 = 1 / phy2.mass
    local relVel = phy2.vel - phy1.vel
    local normal = -delta:normalized()
    local contactVel = relVel * normal
    if contactVel >= 0 then return end
    local e = math.min(phy1.elastic, phy2.elastic)
    local j = -(1 + e) * contactVel
    j = j / (massInv1 + massInv2)
    local impulse = j * normal
    phy1.vel = phy1.vel - impulse * massInv1
    phy2.vel = phy2.vel + impulse * massInv2
end

function Physics:bounce(delta)
    self.vel = -self.vel:mirrorOn(delta) * self.elastic
end

function Physics:applyForce(force)
    self.acc = self.acc + force / self.mass
end

function Physics:update(dt)
    self:applyForce(self.grav)

    local velNI = -self.vel:normalized()
    local friction = velNI * self.frict
    self:applyForce(friction)

    local dragMag = self.vel:len2() * self.dragFactor * self.drag
    local drag = velNI * dragMag
    self:applyForce(drag)

    self.vel = self.vel + self.acc
    self.vel:trimInplace(self.maxVel)
    if self.vel:len2() < self.minVel^2 and self.acc:len2() < 1 then
        self.vel = vector(0,0)
    end

    self.entity.pos = self.entity.pos + self.vel * dt

    self.acc.x, self.acc.y = 0, 0
end

return Physics
