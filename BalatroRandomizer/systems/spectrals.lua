BR.Spectrals = BR.Spectrals or {}

local SELECT_TAROTS = {
    c_magician = true,
    c_empress = true,
    c_hierophant = true,
    c_lovers = true,
    c_chariot = true,
    c_justice = true,
    c_strength = true,
    c_hanged_man = true,
    c_devil = true,
    c_tower = true,
    c_star = true,
    c_moon = true,
    c_sun = true,
    c_world = true
}

local CREATE_CARDS = {
    c_familiar = true,
    c_grim = true,
    c_incantation = true
}

local SELECT_CARDS = {
    c_talisman = true,
    c_aura = true,
    c_deja_vu = true,
    c_trance = true,
    c_medium = true
}

local SELECT_TARGETS = {}
for key in pairs(SELECT_CARDS) do SELECT_TARGETS[key] = true end
for key in pairs(SELECT_TAROTS) do SELECT_TARGETS[key] = true end

local CRYPTID = "c_cryptid"
local IMMOLATE = "c_immolate"

local SELECT_SEALS = {
    c_talisman = "Gold",
    c_deja_vu = "Red",
    c_trance = "Blue",
    c_medium = "Purple"
}

local function clone_value(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = clone_value(child)
    end
    return result
end

local function get_select_config(key)
    if not BR.State.initialized or not BR.State.config or not BR.State.config.consumables then return nil end
    return BR.State.config.consumables[key]
end

local function get_select_limit(key, card)
    local config = get_select_config(key)
    if config and config.select_cards ~= nil then
        return tonumber(config.select_cards) or 1
    end
    if card and card.ability and card.ability.consumeable and card.ability.consumeable.max_highlighted then
        return tonumber(card.ability.consumeable.max_highlighted) or 1
    end
    if G and G.P_CENTERS and G.P_CENTERS[key] and G.P_CENTERS[key].config then
        return tonumber(G.P_CENTERS[key].config.max_highlighted) or 1
    end
    return 1
end

function BR.Spectrals:apply_card_ability(card)
    if not card or not card.config or not card.config.center or not card.ability then return end
    local center = card.config.center
    if not SELECT_TARGETS[center.key] then return end
    local config = get_select_config(center.key)
    if not config or config.select_cards == nil then return end
    local limit = tonumber(config.select_cards) or 1
    card.ability.max_highlighted = limit
    card.ability.consumeable = card.ability.consumeable or center.config or {}
    card.ability.consumeable.max_highlighted = limit
    card.ability.consumeable.mod_num = math.min(5, limit)
end

local function save_original(self, center)
    self.original = self.original or {}
    if self.original[center.key] then return end
    local config = center.config or {}
    self.original[center.key] = {
        extra = clone_value(config.extra),
        extra_exists = config.extra ~= nil,
        max_highlighted = clone_value(config.max_highlighted),
        max_highlighted_exists = config.max_highlighted ~= nil
    }
end

function BR.Spectrals:install_select_hooks()
    if not G or not G.P_CENTERS then return end
    for _, set_name in ipairs({"Spectral", "Tarot"}) do
        local pool = G.P_CENTER_POOLS and G.P_CENTER_POOLS[set_name]
        if pool then
            for _, center in ipairs(pool) do
                if center and SELECT_TARGETS[center.key] then
                    local config = get_select_config(center.key)
                    if config and config.select_cards ~= nil and center.config then
                        save_original(self, center)
                        center.config.max_highlighted = config.select_cards
                    end
                    if not center.brnd_select_hook_installed then
                        local original_set_ability = center.set_ability
                        local original_loc_vars = center.loc_vars
                        center.brnd_select_hook_installed = true
                        center.brnd_original_set_ability = original_set_ability
                        center.brnd_original_loc_vars = original_loc_vars
                        center.set_ability = function(self, card, initial, delay_sprites)
                            if original_set_ability then
                                original_set_ability(self, card, initial, delay_sprites)
                            end
                            BR.Spectrals:apply_card_ability(card)
                        end

                        if set_name == "Spectral" and SMODS and SMODS.Consumable
                            and SMODS.Consumable.take_ownership and not center.brnd_spectral_loc_ownership then
                            local spectral_key = center.key
                            SMODS.Consumable:take_ownership(spectral_key, {
                                loc_vars = function(self, info_queue, card)
                                    return {
                                        vars = {
                                            (card and card.ability and card.ability.max_highlighted)
                                                or get_select_limit(spectral_key, card)
                                                or 1
                                        }
                                    }
                                end
                            }, true)
                            center.brnd_spectral_loc_ownership = true
                        end
                    end
                end
            end
        end
    end
end

local function set_or_remove(config, key, value, exists)
    if exists then
        config[key] = clone_value(value)
    else
        config[key] = nil
    end
end

function BR.Spectrals:restore_centers()
    if not self.original then return end
    if not G or not G.P_CENTER_POOLS then return end
    for _, set_name in ipairs({"Spectral", "Tarot"}) do
        local pool = G.P_CENTER_POOLS[set_name]
        if pool then
            for _, center in ipairs(pool) do
                local original = center and center.key and self.original[center.key]
                if original and center.config then
                    set_or_remove(center.config, "extra", original.extra, original.extra_exists)
                    set_or_remove(center.config, "max_highlighted", original.max_highlighted, original.max_highlighted_exists)
                end
            end
        end
    end
    self.original = nil
end

function BR.Spectrals:generate_config(rng)
    local create_min, create_max = BR.Config:get_range("spectrals.create_cards", 1, 5, 1, 1000000)
    local cryptid_min, cryptid_max = BR.Config:get_range("spectrals.cryptid_copies", 1, 5, 1, 1000000)
    local immolate_min, immolate_max = BR.Config:get_range("spectrals.immolate_destroy", 1, 10, 1, 1000000)
    local create_enabled = BR.Config:is_enabled("spectrals.create_cards.enabled", false)
    local cryptid_enabled = BR.Config:is_enabled("spectrals.cryptid_copies.enabled", false)
    local immolate_enabled = BR.Config:is_enabled("spectrals.immolate_destroy.enabled", false)
    local result = {}

    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Spectral then
        return result
    end

    for _, center in ipairs(G.P_CENTER_POOLS.Spectral) do
        if center and center.key and center.config and (CREATE_CARDS[center.key] or center.key == CRYPTID or center.key == IMMOLATE) then
            save_original(self, center)
            local entry = {}

            if CREATE_CARDS[center.key] and create_enabled then
                entry.create_cards = rng:fork("spectrals.create_cards." .. center.key):int(create_min, create_max)
                center.config.extra = entry.create_cards
            end

            if center.key == CRYPTID and cryptid_enabled then
                entry.cryptid_copies = rng:fork("spectrals.cryptid_copies." .. center.key):int(cryptid_min, cryptid_max)
                center.config.extra = entry.cryptid_copies
            end

            if center.key == IMMOLATE and immolate_enabled then
                entry.immolate_destroy = rng:fork("spectrals.immolate_destroy." .. center.key):int(immolate_min, immolate_max)
                local extra = type(center.config.extra) == "table" and center.config.extra or {}
                extra = clone_value(extra)
                extra.destroy = entry.immolate_destroy
                center.config.extra = extra
            end

            if next(entry) ~= nil then
                result[center.key] = entry
            end
        end
    end

    return result
end

function BR.Spectrals:log_config()
    if not BR.Config:is_enabled("debug.enabled", false) then return end
    if not BR.State.config or not BR.State.config.spectrals then return end
    local keys = {}
    for key in pairs(BR.State.config.spectrals) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    BR.Log:info(string.format("Spectral configuration generated: %d", #keys))
    for _, key in ipairs(keys) do
        local cfg = BR.State.config.spectrals[key]
        local fields = {}
        if cfg.create_cards ~= nil then fields[#fields + 1] = "create=" .. tostring(cfg.create_cards) end
        if cfg.cryptid_copies ~= nil then fields[#fields + 1] = "copies=" .. tostring(cfg.cryptid_copies) end
        if cfg.immolate_destroy ~= nil then fields[#fields + 1] = "destroy=" .. tostring(cfg.immolate_destroy) end
        BR.Log:info(string.format("Spectral config | %s | %s", key, table.concat(fields, " | ")))
    end
end

local function get_selected_cards()
    local selected = {}
    if not G or not G.hand or not G.hand.highlighted then return selected end
    for _, selected_card in ipairs(G.hand.highlighted) do
        if selected_card and not selected_card.REMOVED then
            selected[#selected + 1] = selected_card
        end
    end
    return selected
end

local function use_select_spectral(card)
    local targets = get_selected_cards()
    if #targets == 0 then return false end
    local key = card.config and card.config.center and card.config.center.key
    if not SELECT_CARDS[key] then return false end

    G.E_MANAGER:add_event(Event({func = function()
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)
        return true
    end }))

    if key == "c_aura" then
        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                if target and not target.REMOVED and not target.edition then
                    target:set_edition(poll_edition('aura', nil, true, true), true)
                end
                return true
            end }))
        end
    else
        local seal = SELECT_SEALS[key]
        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                if target and not target.REMOVED then
                    target:set_seal(seal, nil, true)
                end
                return true
            end }))
        end
    end

    delay(0.5)
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
        G.hand:unhighlight_all()
        return true
    end }))
    return true
end

function BR.Spectrals:is_select_target(key)
    return SELECT_TARGETS[key] == true
end

function BR.Spectrals:is_select_card(card)
    local key = card and card.config and card.config.center and card.config.center.key
    if not SELECT_CARDS[key] then return false end
    return get_select_config(key) ~= nil
end

function BR.Spectrals:install_card_hooks()
    if BR.Spectrals.card_hooks_installed then return end
    if not Card or not Card.use_consumeable or not Card.can_use_consumeable then return end

    local original_use = Card.use_consumeable
    local original_can_use = Card.can_use_consumeable

    Card.can_use_consumeable = function(self, any_state, skip_check)
        if BR.Spectrals:is_select_card(self) then
            if self.debuff then return false end
            if not skip_check and ((G.play and #G.play.cards > 0) or (G.CONTROLLER and G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) then
                return false
            end
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT or any_state then
                local count = G.hand and G.hand.highlighted and #G.hand.highlighted or 0
                local limit = get_select_limit(self.config.center.key, self)
                if count >= 1 and count <= limit then
                    if self.config.center.key == "c_aura" then
                        for _, target in ipairs(G.hand.highlighted) do
                            if target.edition then return false end
                        end
                    end
                    return true
                end
            end
            return false
        end
        return original_can_use(self, any_state, skip_check)
    end

    Card.use_consumeable = function(self, area, copier)
        if BR.Spectrals:is_select_card(self) then
            stop_use()
            if not copier then set_consumeable_usage(self) end
            if self.debuff then return nil end
            if use_select_spectral(self) then
                if BR.Config:is_enabled("debug.enabled", false) then
                    BR.Log:info(string.format("Spectral select effect applied | %s | %d targets", self.config.center.key, G.hand and G.hand.highlighted and #G.hand.highlighted or 0))
                end
                return nil
            end
        end
        return original_use(self, area, copier)
    end

    BR.Spectrals.card_hooks_installed = true
    if BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info("Spectral select card hooks installed")
    end
end

BR.Spectrals:install_select_hooks()
BR.Spectrals:install_card_hooks()
