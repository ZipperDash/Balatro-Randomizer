BR.Config = BR.Config or {}

local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = clone(child)
    end
    return result
end

local function hash_string(value)
    local hash = 7
    for i = 1, #value do
        hash = (hash * 31 + string.byte(value, i)) % 2147483647
    end
    return tostring(hash)
end

local function serialize(value)
    local value_type = type(value)
    if value_type == "boolean" then return value and "true" or "false" end
    if value_type == "number" then return string.format("%.17g", value) end
    if value_type == "string" then return string.format("%q", value) end
    if value_type ~= "table" then return value_type end

    local keys = {}
    for key in pairs(value) do
        if key ~= "__defaults_hash" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)

    local parts = { "{" }
    for _, key in ipairs(keys) do
        parts[#parts + 1] = serialize(key)
        parts[#parts + 1] = "="
        parts[#parts + 1] = serialize(value[key])
        parts[#parts + 1] = ";"
    end
    parts[#parts + 1] = "}"
    return table.concat(parts)
end

function BR.Config:load_defaults()
    return assert(SMODS.load_file("core/defaults.lua"))()
end

function BR.Config:sync_defaults()
    if not BR.mod then return end
    local defaults = self:load_defaults()
    local defaults_hash = hash_string(serialize(defaults))
    local config = BR.mod.config

    if type(config) ~= "table" or config.__defaults_hash ~= defaults_hash then
        local fresh = clone(defaults)
        if type(config) == "table" then
            local function merge_missing(dst, src)
                for key, value in pairs(src) do
                    if key ~= "__defaults_hash" then
                        if dst[key] == nil then
                            dst[key] = clone(value)
                        elseif type(value) == "table" and type(dst[key]) == "table" then
                            merge_missing(dst[key], value)
                        end
                    end
                end
            end
            merge_missing(fresh, config)

            local function overlay(dst, src)
                for key, value in pairs(src) do
                    if key ~= "__defaults_hash" then
                        if type(value) == "table" and type(dst[key]) == "table" then
                            overlay(dst[key], value)
                        else
                            dst[key] = clone(value)
                        end
                    end
                end
            end
            overlay(fresh, config)

            if type(config.spectrals) == "table" and config.spectrals.select_cards ~= nil then
                if type(config.consumables) ~= "table" then config.consumables = {} end
                if config.consumables.select_cards == nil then
                    config.consumables.select_cards = clone(config.spectrals.select_cards)
                end
                fresh.spectrals.select_cards = nil
            end
        end

        fresh.__defaults_hash = defaults_hash
        BR.mod.config = fresh
        config = fresh
    end

    if type(config) ~= "table" then
        config = clone(defaults)
    end
    if type(config.blinds) ~= "table" then config.blinds = clone(defaults.blinds) end
    if type(config.blinds.boss_order) ~= "table" then
        config.blinds.boss_order = clone(defaults.blinds.boss_order)
    else
        if type(config.blinds.boss_order.enabled) ~= "boolean" then
            config.blinds.boss_order.enabled = defaults.blinds.boss_order.enabled
        end
        if type(config.blinds.boss_order.allow_showdown) ~= "boolean" then
            config.blinds.boss_order.allow_showdown = defaults.blinds.boss_order.allow_showdown
        end
    end
    BR.mod.config = config

    self.defaults = defaults
    self.defaults_hash = defaults_hash
    self.current = config
end

function BR.Config:get(path, default)
    local current = self.current or (BR.mod and BR.mod.config)
    for key in string.gmatch(path, "[^.]+") do
        if type(current) ~= "table" then return default end
        current = current[key]
    end
    if current == nil then return default end
    return current
end

function BR.Config:get_number(path, default, minimum, maximum)
    local value = tonumber(self:get(path, default))
    if value == nil then value = default end
    value = math.floor(value)
    if minimum ~= nil and value < minimum then value = minimum end
    if maximum ~= nil and value > maximum then value = maximum end
    return value
end

function BR.Config:is_enabled(path, default)
    local value = self:get(path, default)
    return value == true
end

function BR.Config:get_range(path, default_min, default_max, minimum, maximum)
    local min_value = self:get_number(path .. ".min", default_min, minimum, maximum)
    local max_value = self:get_number(path .. ".max", default_max, minimum, maximum)
    if max_value < min_value then
        min_value, max_value = max_value, min_value
    end
    return min_value, max_value
end
