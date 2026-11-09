BR.Consumables = BR.Consumables or {}

local function get_pool()
    if not G or not G.P_CENTER_POOLS then return {} end
    local result = {}
    local seen = {}
    for _, set_name in ipairs({"Tarot", "Planet", "Spectral"}) do
        local pool = G.P_CENTER_POOLS[set_name]
        if pool then
            for _, center in ipairs(pool) do
                if center and center.key and not seen[center.key] then
                    seen[center.key] = true
                    result[#result + 1] = center
                end
            end
        end
    end
    return result
end

function BR.Consumables:get_config(card)
    if not BR.State.initialized or not BR.State.config or not BR.State.config.consumables then return nil end
    if not card or not card.config or not card.config.center then return nil end
    return BR.State.config.consumables[card.config.center.key]
end

function BR.Consumables:apply_shop_card(card)
    local consumable_config = self:get_config(card)
    if not consumable_config then return end

    if BR.Spectrals and BR.Spectrals.apply_card_ability then
        BR.Spectrals:apply_card_ability(card)
    end

    if consumable_config.buy_cost ~= nil then
        card.base_cost = consumable_config.buy_cost
    end

    if consumable_config.sell_value ~= nil and card.ability then
        local extra_value = tonumber(card.ability.extra_value) or 0
        local current_sell = math.max(1, math.floor(card.cost / 2)) + extra_value
        card.ability.extra_value = extra_value + consumable_config.sell_value - current_sell
    end

    card:set_cost()
end

function BR.Consumables:modify_weights(context)
    if not BR.State.initialized or not BR.State.config or not BR.Config:is_enabled("consumables.spawn_weight.enabled", false) then return end
    if not context or not context.pool or type(context.pool) ~= "table" then return end

    local pool_log = {}

    for _, entry in ipairs(context.pool) do
        if type(entry) == "table" and entry.key then
            local center = G and G.P_CENTERS and G.P_CENTERS[entry.key]
            if center and (center.set == "Tarot" or center.set == "Planet" or center.set == "Spectral") then
                local consumable_config = BR.State.config.consumables[entry.key]
                if consumable_config and consumable_config.spawn_weight ~= nil then
                    entry.weight = consumable_config.spawn_weight
                end
                if BR.Config:is_enabled("debug.enabled", false) and BR.Config:is_enabled("debug.log_weight_pools", true) then
                    pool_log[#pool_log + 1] = string.format("%s:%s:%s", center.set, entry.key, tostring(entry.weight))
                end
            end
        end
    end

    if #pool_log > 0 then
        BR.Log:info(string.format("Consumable weight pool: %d candidates | %s", #pool_log, table.concat(pool_log, " | ")))
    end
end

function BR.Consumables:log_generated_weights()
    if not BR.Config:is_enabled("debug.enabled", false) then return end
    if not BR.Config:is_enabled("debug.log_consumable_weights", true) then return end
    if not BR.Config:is_enabled("consumables.spawn_weight.enabled", false) then return end
    if not BR.State.config or not BR.State.config.consumables then return end

    local weights = {}
    for key, config in pairs(BR.State.config.consumables) do
        if config.spawn_weight ~= nil then
            weights[#weights + 1] = {key = key, weight = config.spawn_weight}
        end
    end
    table.sort(weights, function(a, b) return a.key < b.key end)
    BR.Log:info(string.format("Consumable weights generated: %d", #weights))
    for _, entry in ipairs(weights) do
        local center = G and G.P_CENTERS and G.P_CENTERS[entry.key]
        local set_name = center and center.set or "unknown"
        BR.Log:info(string.format("Consumable weight | %s | %s | %d", set_name, entry.key, entry.weight))
    end
end

local previous_calculate = BR.mod.calculate
function BR.mod.calculate(self, context)
    if previous_calculate then
        local result = previous_calculate(self, context)
        if result ~= nil then return result end
    end

    if context and context.modify_shop_card and context.card and context.card.config and context.card.config.center then
        local set_name = context.card.config.center.set
        if set_name == "Tarot" or set_name == "Planet" or set_name == "Spectral" then
            BR.Consumables:apply_shop_card(context.card)
        end
    end

    if context and context.modify_weights then
        BR.Consumables:modify_weights(context)
    end
end
