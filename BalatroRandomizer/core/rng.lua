BR.RNG = BR.RNG or {}
BR.RNG.__index = BR.RNG

local MODULUS = 2147483647
local MULTIPLIER = 16807
local HASH_OFFSET = 2166136261
local HASH_PRIME = 16777619

function BR.RNG:new(seed)
    seed = math.floor(tonumber(seed) or 1) % MODULUS
    if seed <= 0 then seed = 1 end
    return setmetatable({ state = seed }, self)
end

function BR.RNG:next()
    self.state = (self.state * MULTIPLIER) % MODULUS
    return self.state / MODULUS
end

function BR.RNG:int(minimum, maximum)
    minimum = math.floor(minimum)
    maximum = math.floor(maximum)
    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end
    return minimum + math.floor(self:next() * (maximum - minimum + 1))
end

function BR.RNG:pick(values)
    if type(values) ~= "table" or #values == 0 then return nil end
    return values[self:int(1, #values)]
end

function BR.RNG:fork(namespace)
    namespace = tostring(namespace or "")
    local hash = HASH_OFFSET
    for i = 1, #namespace do
        hash = (hash * HASH_PRIME + string.byte(namespace, i)) % MODULUS
    end
    local seed = (self.state + hash) % MODULUS
    if seed <= 0 then seed = 1 end
    return BR.RNG:new(seed)
end
