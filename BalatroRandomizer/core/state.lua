BR.State = BR.State or {}

function BR.State:generate_blind_config()
    local values = BR.Config:get("blinds.chips_multiplier.values", {0.5, 1.0, 1.5, 2.0})
    local cleaned = {}
    if type(values) == "table" then
        for _, value in ipairs(values) do
            value = tonumber(value)
            if value and value > 0 then
                cleaned[#cleaned + 1] = value
            end
        end
    end
    if #cleaned == 0 then
        cleaned = {0.5, 1.0, 1.5, 2.0}
    end
    return {
        chips_multiplier = {
            enabled = BR.Config:is_enabled("blinds.chips_multiplier.enabled", false),
            values = cleaned
        },
        boss_order = {
            enabled = BR.Config:is_enabled("blinds.boss_order.enabled", false),
            allow_showdown = BR.Config:is_enabled("blinds.boss_order.allow_showdown", false)
        }
    }
end


function BR.State:generate_player_resources_config()
    local defaults = {-1, 0, 1}
    local result = {}
    local settings = {
        {key = "hands", path = "player_resources.hands"},
        {key = "discards", path = "player_resources.discards"},
        {key = "hand_size", path = "player_resources.hand_size"}
    }
    for _, setting in ipairs(settings) do
        local values = BR.Config:get(setting.path .. ".values", defaults)
        local cleaned = {}
        if type(values) == "table" then
            for _, value in ipairs(values) do
                value = tonumber(value)
                if value then
                    cleaned[#cleaned + 1] = math.floor(value)
                end
            end
        end
        if #cleaned == 0 then
            cleaned = {unpack(defaults)}
        end
        result[setting.key] = {
            enabled = BR.Config:is_enabled(setting.path .. ".enabled", false),
            values = cleaned
        }
    end
    return result
end

function BR.State:generate_seed()
    local run_seed = nil
    if G and G.GAME then
        run_seed = G.GAME.seed
        if run_seed == nil and G.GAME.pseudorandom then
            run_seed = G.GAME.pseudorandom.seed
        end
    end

    run_seed = tostring(run_seed or "")
    if run_seed == "" then
        return 1
    end

    local hash = 5381
    local material = "BalatroRandomizer:" .. run_seed
    for index = 1, #material do
        hash = (hash * 33 + string.byte(material, index)) % 2147483647
    end

    local seed = hash % 2147483647
    if seed <= 0 then seed = 1 end
    return seed
end

function BR.State:generate_joker_config()
    local buy_min, buy_max = BR.Config:get_range("jokers.buy_cost", 1, 20, 1, 1000000)
    local sell_min, sell_max = BR.Config:get_range("jokers.sell_value", 1, 25, 1, 1000000)
    local weight_min, weight_max = BR.Config:get_range("jokers.spawn_weight", 1, 20, 1, 1000000)
    local buy_enabled = BR.Config:is_enabled("jokers.buy_cost.enabled", false)
    local sell_enabled = BR.Config:is_enabled("jokers.sell_value.enabled", false)
    local weight_enabled = BR.Config:is_enabled("jokers.spawn_weight.enabled", false)
    local result = {}

    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Joker then
        return result
    end

    for _, center in ipairs(G.P_CENTER_POOLS.Joker) do
        if center and center.key then
            local joker = {}
            if buy_enabled then
                joker.buy_cost = self.rng:fork("jokers.buy_cost." .. center.key):int(buy_min, buy_max)
            end
            if sell_enabled then
                joker.sell_value = self.rng:fork("jokers.sell_value." .. center.key):int(sell_min, sell_max)
            end
            if weight_enabled then
                joker.spawn_weight = self.rng:fork("jokers.spawn_weight." .. center.key):int(weight_min, weight_max)
            end
            result[center.key] = joker
        end
    end

    return result
end


function BR.State:generate_booster_config()
    local minimum, maximum = BR.Config:get_range("boosters.buy_cost", 1, 30, 1, 1000000)
    local enabled = BR.Config:is_enabled("boosters.buy_cost.enabled", false)
    local result = {}

    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Booster then
        return result
    end

    if not enabled then
        return result
    end

    for _, center in ipairs(G.P_CENTER_POOLS.Booster) do
        if center and center.key then
            result[center.key] = {
                buy_cost = self.rng:fork("boosters.buy_cost." .. center.key):int(minimum, maximum)
            }
        end
    end

    return result
end

function BR.State:generate_voucher_config()
    local minimum, maximum = BR.Config:get_range("vouchers.buy_cost", 1, 50, 1, 1000000)
    local enabled = BR.Config:is_enabled("vouchers.buy_cost.enabled", false)
    local result = {}

    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Voucher then
        return result
    end

    if not enabled then
        return result
    end

    for _, center in ipairs(G.P_CENTER_POOLS.Voucher) do
        if center and center.key then
            result[center.key] = {
                buy_cost = self.rng:fork("vouchers.buy_cost." .. center.key):int(minimum, maximum)
            }
        end
    end

    return result
end

function BR.State:generate_consumable_config()
    local buy_min, buy_max = BR.Config:get_range("consumables.buy_cost", 1, 20, 1, 1000000)
    local sell_min, sell_max = BR.Config:get_range("consumables.sell_value", 1, 10, 1, 1000000)
    local weight_min, weight_max = BR.Config:get_range("consumables.spawn_weight", 1, 20, 1, 1000000)
    local select_min, select_max = BR.Config:get_range("consumables.select_cards", 1, 5, 1, 5)
    local buy_enabled = BR.Config:is_enabled("consumables.buy_cost.enabled", false)
    local sell_enabled = BR.Config:is_enabled("consumables.sell_value.enabled", false)
    local weight_enabled = BR.Config:is_enabled("consumables.spawn_weight.enabled", false)
    local select_enabled = BR.Config:is_enabled("consumables.select_cards.enabled", false)
    local result = {}

    if not G or not G.P_CENTER_POOLS then
        return result
    end

    local seen = {}
    for _, set_name in ipairs({"Tarot", "Planet", "Spectral"}) do
        local pool = G.P_CENTER_POOLS[set_name]
        if pool then
            for _, center in ipairs(pool) do
                if center and center.key and not seen[center.key] then
                    seen[center.key] = true
                    local consumable = {}
                    if buy_enabled then
                        consumable.buy_cost = self.rng:fork("consumables.buy_cost." .. center.key):int(buy_min, buy_max)
                    end
                    if sell_enabled then
                        consumable.sell_value = self.rng:fork("consumables.sell_value." .. center.key):int(sell_min, sell_max)
                    end
                    if weight_enabled then
                        consumable.spawn_weight = self.rng:fork("consumables.spawn_weight." .. center.key):int(weight_min, weight_max)
                    end
                    if select_enabled and BR.Spectrals and BR.Spectrals.is_select_target and BR.Spectrals:is_select_target(center.key) then
                        consumable.select_cards = self.rng:fork("consumables.select_cards." .. center.key):int(select_min, select_max)
                    end
                    result[center.key] = consumable
                end
            end
        end
    end

    return result
end


function BR.State:restore_planet_centers()
    if not self.original_planet_hand_types then return end
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Planet then return end
    for _, center in ipairs(G.P_CENTER_POOLS.Planet) do
        if center and center.key and self.original_planet_hand_types[center.key] ~= nil and center.config then
            center.config.hand_type = self.original_planet_hand_types[center.key]
        end
    end
    self.original_planet_hand_types = nil
end

function BR.State:generate_planet_config()
    local hand_enabled = BR.Config:is_enabled("planets.hand_type.enabled", false)
    local level_min, level_max = BR.Config:get_range("planets.upgrade_level", 1, 5, 1, 1000000)
    local level_enabled = BR.Config:is_enabled("planets.upgrade_level.enabled", false)
    local result = {}
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Planet then return result end
    local hand_types = {
        "High Card", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush",
        "Full House", "Four of a Kind", "Straight Flush", "Five of a Kind",
        "Flush House", "Flush Five"
    }
    local planet_centers = {}
    for _, center in ipairs(G.P_CENTER_POOLS.Planet) do
        if center and center.key and center.config then
            planet_centers[#planet_centers + 1] = center
        end
    end
    table.sort(planet_centers, function(a, b) return tostring(a.key) < tostring(b.key) end)

    local shuffled_hands = {}
    for index, hand_type in ipairs(hand_types) do
        shuffled_hands[index] = hand_type
    end
    if hand_enabled then
        local shuffle_rng = self.rng:fork("planets.hand_type.assignment")
        for index = #shuffled_hands, 2, -1 do
            local swap_index = shuffle_rng:int(1, index)
            shuffled_hands[index], shuffled_hands[swap_index] = shuffled_hands[swap_index], shuffled_hands[index]
        end
    end

    for index, center in ipairs(planet_centers) do
        local original = center.config.hand_type
        if original ~= nil and not self.original_planet_hand_types then self.original_planet_hand_types = {} end
        if original ~= nil and self.original_planet_hand_types[center.key] == nil then
            self.original_planet_hand_types[center.key] = original
        end
        local entry = {}
        if hand_enabled then
            entry.hand_type = shuffled_hands[((index - 1) % #shuffled_hands) + 1]
            center.config.hand_type = entry.hand_type
        else
            entry.hand_type = original
        end
        if level_enabled then
            entry.upgrade_level = self.rng:fork("planets.upgrade_level." .. center.key):int(level_min, level_max)
        else
            entry.upgrade_level = 1
        end
        result[center.key] = entry
    end
    return result
end

function BR.State:generate_config()
    local money_min, money_max = BR.Config:get_range("economy.starting_money", 1, 20, 0, 1000000)
    local starting_money = BR.Config:is_enabled("economy.starting_money.enabled", true)
        and self.rng:fork("economy.starting_money"):int(money_min, money_max)
        or nil
    local money_accumulation = BR.Config:is_enabled("economy.money_accumulation.enabled", true)

    local reroll_min, reroll_max = BR.Config:get_range("shop.reroll_cost", 1, 10, 0, 1000000)
    local reroll_cost = BR.Config:is_enabled("shop.reroll_cost.enabled", false)
        and self.rng:fork("shop.reroll_cost"):int(reroll_min, reroll_max)
        or nil

    self.joker_activation_counter = 0
    self.playing_card_hand_counter = 0
    self.playing_card_round = nil
    self.playing_card_round_hand_counter = 0
    return {
        economy = {
            starting_money = starting_money,
            money_accumulation = money_accumulation
        },
        shop = {
            reroll_cost = reroll_cost,
            disable = {
                enabled = BR.Config:is_enabled("shop.disable.enabled", false)
            },
            boss_only = {
                enabled = BR.Config:is_enabled("shop.boss_only.enabled", false)
            }
        },
        blinds = self:generate_blind_config(),
        boosters = self:generate_booster_config(),
        jokers = self:generate_joker_config(),
        joker_activation = {
            skip_enabled = BR.Config:is_enabled("jokers.activation_skip.enabled", false),
            repeat_enabled = BR.Config:is_enabled("jokers.activation_repeat.enabled", false)
        },
        vouchers = self:generate_voucher_config(),
        consumables = self:generate_consumable_config(),
        planets = self:generate_planet_config(),
        spectrals = BR.Spectrals:generate_config(self.rng),
        player_resources = self:generate_player_resources_config(),
        voucher_order = BR.Config:is_enabled("vouchers.order.enabled", false)
    }
end

function BR.State:new_run(run_start)
    self.player_resources_applied = false
    self:restore_planet_centers()
    BR.Spectrals:restore_centers()
    local seed = self:generate_seed()
    self.seed = seed
    self.rng = BR.RNG:new(seed)
    self.config = self:generate_config()
    BR.Boosters:apply_center_costs()
    BR.Spectrals:install_select_hooks()
    BR.Spectrals:install_card_hooks()
    self.run_start = run_start
    self.initialized = true

    if G and G.GAME then
        G.GAME.br_randomizer_seed = seed
        G.GAME.br_randomizer_config = self.config
        G.GAME.br_randomizer_joker_activation_counter = 0
        G.GAME.br_randomizer_playing_card_hand_counter = 0
        G.GAME.br_randomizer_playing_card_round = nil
        G.GAME.br_randomizer_playing_card_round_hand_counter = 0
        G.GAME.br_randomizer_boss_order_counter = 0
    end

    local starting_money = self.config.economy.starting_money
    local reroll_cost = self.config.shop.reroll_cost
    local money_text = starting_money and string.format("%d", starting_money) or "vanilla"
    local reroll_text = reroll_cost and string.format("%d", reroll_cost) or "vanilla"
    if BR.Config:is_enabled("debug.enabled", false) and BR.Config:is_enabled("debug.log_seed", true) then
        BR.Log:info(string.format("Initialized | Seed: %d | Starting money: %s | Reroll cost: %s", seed, money_text, reroll_text))
    end

    BR.Jokers:log_generated_weights()
    if BR.Config:is_enabled("debug.enabled", false) and BR.Config:is_enabled("vouchers.buy_cost.enabled", false) and BR.State.config.vouchers then
        local keys = {}
        for key in pairs(BR.State.config.vouchers) do keys[#keys + 1] = key end
        table.sort(keys)
        BR.Log:info(string.format("Voucher costs generated: %d", #keys))
        for _, key in ipairs(keys) do
            BR.Log:info(string.format("Voucher cost | %s | %d", key, BR.State.config.vouchers[key].buy_cost))
        end
    end
    if BR.Config:is_enabled("debug.enabled", false) and BR.Config:is_enabled("boosters.buy_cost.enabled", false) and BR.State.config.boosters then
        local keys = {}
        for key in pairs(BR.State.config.boosters) do keys[#keys + 1] = key end
        table.sort(keys)
        BR.Log:info(string.format("Booster costs generated: %d", #keys))
        for _, key in ipairs(keys) do
            BR.Log:info(string.format("Booster cost | %s | %d", key, BR.State.config.boosters[key].buy_cost))
        end
        BR.Log:info("Booster center costs applied")
    end
    if BR.Config:is_enabled("debug.enabled", false) and BR.Config:is_enabled("consumables.buy_cost.enabled", false) and BR.State.config.consumables then
        local keys = {}
        for key in pairs(BR.State.config.consumables) do keys[#keys + 1] = key end
        table.sort(keys)
        BR.Log:info(string.format("Consumable costs generated: %d", #keys))
        for _, key in ipairs(keys) do
            local config = BR.State.config.consumables[key]
            if config.buy_cost ~= nil then BR.Log:info(string.format("Consumable buy cost | %s | %d", key, config.buy_cost)) end
            if config.sell_value ~= nil then BR.Log:info(string.format("Consumable sell value | %s | %d", key, config.sell_value)) end
        end
    end
    BR.Consumables:log_generated_weights()
    if BR.Config:is_enabled("debug.enabled", false) and (BR.Config:is_enabled("planets.hand_type.enabled", false) or BR.Config:is_enabled("planets.upgrade_level.enabled", false)) and BR.State.config.planets then
        local keys = {}
        for key in pairs(BR.State.config.planets) do keys[#keys + 1] = key end
        table.sort(keys)
        BR.Log:info(string.format("Planet configuration generated: %d", #keys))
        for _, key in ipairs(keys) do
            local cfg = BR.State.config.planets[key]
            BR.Log:info(string.format("Planet config | %s | hand=%s | level=%d", key, tostring(cfg.hand_type), tonumber(cfg.upgrade_level) or 1))
        end
    end
    BR.Spectrals:log_config()
end

function BR.State:restore_saved_run()
    if not G or not G.GAME then return false end

    local saved_seed = tonumber(G.GAME.br_randomizer_seed)
    local saved_config = G.GAME.br_randomizer_config
    if not saved_seed or type(saved_config) ~= "table" then
        return false
    end

    self.seed = saved_seed
    self.rng = BR.RNG:new(saved_seed)
    self.config = saved_config

    self.joker_activation_counter = math.max(0, math.floor(tonumber(G.GAME.br_randomizer_joker_activation_counter) or 0))
    self.playing_card_hand_counter = math.max(0, math.floor(tonumber(G.GAME.br_randomizer_playing_card_hand_counter) or 0))
    self.playing_card_round = G.GAME.br_randomizer_playing_card_round
    self.playing_card_round_hand_counter = math.max(0, math.floor(tonumber(G.GAME.br_randomizer_playing_card_round_hand_counter) or 0))
    self.player_resources_applied = true
    self.initialized = true

    if BR.Boosters and BR.Boosters.apply_center_costs then
        BR.Boosters:apply_center_costs()
    end
    if BR.Vouchers and BR.Vouchers.apply_center_costs then
        BR.Vouchers:apply_center_costs()
    end
    if BR.Vouchers and BR.Vouchers.apply_order_mode then
        BR.Vouchers:apply_order_mode()
    end
    if BR.Spectrals and BR.Spectrals.install_select_hooks then
        BR.Spectrals:install_select_hooks()
    end
    if BR.Spectrals and BR.Spectrals.install_card_hooks then
        BR.Spectrals:install_card_hooks()
    end

    return true
end

function BR.State:reset(run_start)
    if run_start then
        self:new_run(true)
        return
    end

    self:restore_saved_run()
end
