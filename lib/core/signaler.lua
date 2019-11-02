local Class = require 'lib.hump.class'
local Signal = require 'lib.hump.signal'

local Signaler = Class{}

function Signaler:init()
    self.signals = Signal.new()
    self.observers = {}
end

-- signals

function Signaler:register(reg, sig, f)
    if type(reg) == 'string' then f = sig; sig = reg; reg = self.signals end
    self.observers[reg] = self.observers[reg] or {}
    self.observers[reg][sig] =  self.observers[reg][sig] or {}
    table.insert(self.observers[reg][sig], f)
    return reg:register(sig, f)
end

function Signaler:unregister(handle)
    for reg, sigs in pairs(self.observers) do
        for sig, fs in pairs(sigs) do
            for i, f in ipairs(fs) do
                if handle == f then
                    reg:remove(sig, handle)
                    table.remove(self.observers[reg][sig], i)
                    break
                end
            end
        end
    end
end

function Signaler:emit(reg, sig, f, ...)
    if type(reg) == 'string' then f = sig; sig = reg; reg = self.signals end
    reg:emit(sig, f, ...)
end

-- remove

function Signaler:remove()
    for reg, sigs in pairs(self.observers) do
        for sig, fs in pairs(sigs) do
            for _, f in ipairs(fs) do
                reg:remove(sig, f)
            end
        end
    end
    self.signals:clearPattern('.*')
end

return Signaler
