BR.Jokers = BR.Jokers or {}

local function sorted_keys(values)
    local keys = {}
    for key in pairs(values) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    return keys
end

function BR.Jokers:get_config(card)
    if not BR.State.initialized or not BR.State.config or not BR.State.config.jokers then return nil end
    if not card or not card.config or not card.config.center then return nil end
    return BR.State.config.jokers[card.config.center.key]
end

function BR.Jokers:apply_shop_card(card)
    local joker_config = self:get_config(card)
    if not joker_config then return end

    if joker_config.buy_cost ~= nil then
        card.base_cost = tonumber(joker_config.buy_cost) or card.base_cost
    end

    card:set_cost()

    if joker_config.sell_value ~= nil and card.ability then
        local target_sell = math.max(1, math.floor(tonumber(joker_config.sell_value) or 1))
        local base_sell = math.max(1, math.floor(card.cost / 2))
        card.ability.extra_value = target_sell - base_sell
        card.sell_cost = target_sell
    end

    card:set_cost()
    if joker_config.sell_value ~= nil then
        card.sell_cost = math.max(1, math.floor(tonumber(joker_config.sell_value) or 1))
        card.sell_cost_label = card.facing == 'back' and '?' or card.sell_cost
    end
end

function BR.Jokers:log_generated_weights()
    if not BR.Config:is_enabled("debug.enabled", false) then return end
    if not BR.Config:is_enabled("debug.log_joker_weights", true) then return end
    if not BR.Config:is_enabled("jokers.spawn_weight.enabled", false) then return end
    if not BR.State.config or not BR.State.config.jokers then return end

    local weights = {}
    for key, joker_config in pairs(BR.State.config.jokers) do
        if joker_config.spawn_weight ~= nil then
            weights[#weights + 1] = {key = key, weight = joker_config.spawn_weight}
        end
    end
    table.sort(weights, function(a, b) return a.key < b.key end)

    BR.Log:info(string.format("Joker weights generated: %d", #weights))
    for _, entry in ipairs(weights) do
        BR.Log:info(string.format("Joker weight | %s | %d", entry.key, entry.weight))
    end
end

function BR.Jokers:log_weight_pool(pool)
    if not BR.Config:is_enabled("debug.enabled", false) then return end
    if not BR.Config:is_enabled("debug.log_weight_pools", true) then return end
    if type(pool) ~= "table" then return end

    local entries = {}
    for _, entry in ipairs(pool) do
        if type(entry) == "table" and entry.key then
            entries[#entries + 1] = entry
        end
    end

    if #entries == 0 then return end

    BR.Log:info(string.format("Joker weight pool: %d candidates", #entries))
    for _, entry in ipairs(entries) do
        BR.Log:info(string.format("Pool weight | %s | %s", tostring(entry.key), tostring(entry.weight)))
    end
end

function BR.Jokers:modify_weights(context)
    if not BR.State.initialized or not BR.State.config or not BR.Config:is_enabled("jokers.spawn_weight.enabled", false) then return end
    if not context or not context.pool or type(context.pool) ~= "table" then return end

    for _, entry in ipairs(context.pool) do
        if type(entry) == "table" and entry.key then
            local center = G and G.P_CENTERS and G.P_CENTERS[entry.key]
            if center and center.set == "Joker" then
                local joker_config = BR.State.config.jokers[entry.key]
                if joker_config and joker_config.spawn_weight ~= nil then
                    entry.weight = joker_config.spawn_weight
                end
            end
        end
    end

    self:log_weight_pool(context.pool)
end

local previous_calculate = BR.mod.calculate

function BR.mod.calculate(self, context)
    if previous_calculate then
        local result = previous_calculate(self, context)
        if result ~= nil then return result end
    end

    if context and context.modify_shop_card and context.card then
        if context.card.config and context.card.config.center and context.card.config.center.set == "Joker" then
            BR.Jokers:apply_shop_card(context.card)
        end
    end

    if context and context.modify_weights then
        BR.Jokers:modify_weights(context)
    end
end

function BR.Jokers:get_activation_mode(card)
    if not BR.State.initialized or not BR.State.config or not BR.State.config.joker_activation then return "normal" end
    if not card or not card.ability or card.ability.set ~= "Joker" then return "normal" end
    if card.debuff then return "normal" end

    local skip_enabled = BR.State.config.joker_activation.skip_enabled == true
    local repeat_enabled = BR.State.config.joker_activation.repeat_enabled == true
    if not skip_enabled and not repeat_enabled then return "normal" end

    local counter
    if G and G.GAME then
        counter = math.floor(tonumber(G.GAME.br_randomizer_joker_activation_counter) or 0) + 1
        G.GAME.br_randomizer_joker_activation_counter = counter
    else
        counter = (BR.State.joker_activation_counter or 0) + 1
    end
    BR.State.joker_activation_counter = counter

    local key = card.config and card.config.center and card.config.center.key or "unknown"
    local namespace = string.format("jokers.activation.%s.%d", tostring(key), counter)
    local rng = BR.State.rng:fork(namespace)

    local mode
    if skip_enabled and repeat_enabled then
        mode = rng:pick({"skip", "repeat", "normal"})
    elseif skip_enabled then
        mode = rng:pick({"skip", "normal"})
    else
        mode = rng:pick({"repeat", "normal"})
    end

    if BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info(string.format("Joker activation | %s | mode=%s | count=%d", tostring(key), tostring(mode), counter))
    end
    return mode or "normal"
end

local previous_card_calculate_joker = Card.calculate_joker

local function append_effect(first, second)
    if type(first) ~= "table" then return second end
    if type(second) ~= "table" then return first end

    local tail = first
    while type(tail.extra) == "table" do
        tail = tail.extra
    end
    tail.extra = second
    return first
end

function Card:calculate_joker(context)
    if context and context.retrigger_joker then
        return previous_card_calculate_joker(self, context)
    end

    local skip_enabled = BR.State.initialized and BR.State.config and BR.State.config.joker_activation and BR.State.config.joker_activation.skip_enabled == true
    local repeat_enabled = BR.State.initialized and BR.State.config and BR.State.config.joker_activation and BR.State.config.joker_activation.repeat_enabled == true

    if not skip_enabled and not repeat_enabled then
        return previous_card_calculate_joker(self, context)
    end

    local mode = BR.Jokers:get_activation_mode(self)
    if mode == "skip" then
        return nil
    end

    if mode == "repeat" then
        local first_ret, first_trig = previous_card_calculate_joker(self, context)
        local second_ret, second_trig = previous_card_calculate_joker(self, context)

        if first_ret and second_ret then
            first_ret = append_effect(first_ret, second_ret)
        elseif not first_ret then
            first_ret = second_ret
        end

        return first_ret, first_trig or second_trig
    end

    return previous_card_calculate_joker(self, context)
end
