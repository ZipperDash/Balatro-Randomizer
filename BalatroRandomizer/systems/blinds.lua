BR.Blinds = BR.Blinds or {}

function BR.Blinds:get_multiplier_for_key(blind_key, ante)
    local config = BR.State.config and BR.State.config.blinds and BR.State.config.blinds.chips_multiplier
    if not config or not config.enabled or not BR.State.rng then return nil end
    if type(config.values) ~= "table" or #config.values == 0 then return nil end
    blind_key = blind_key or "unknown"
    ante = ante or 0
    local namespace = string.format("blinds.chips_multiplier.%s.ante_%s", tostring(blind_key), tostring(ante))
    return BR.State.rng:fork(namespace):pick(config.values)
end

function BR.Blinds:get_multiplier(blind, center)
    local blind_key = (center and center.key)
        or (blind and blind.config and blind.config.blind and blind.config.blind.key)
        or (blind and blind.key)
        or (blind and blind.name)
        or "unknown"
    local ante = G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0
    return self:get_multiplier_for_key(blind_key, ante)
end

function BR.Blinds:apply_chips_multiplier(blind, center)
    if not blind or not blind.chips or not BR.State.initialized then return end
    local multiplier = self:get_multiplier(blind, center)
    if not multiplier then return end
    local original = blind.chips
    local randomized = original * multiplier
    blind.chips = randomized
    blind.chip_text = number_format(blind.chips)
    if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info(string.format("Blind chips | %s | key=%s | ante=%s | vanilla=%s | multiplier=%.2f | randomized=%s",
            tostring(blind.name or "unknown"),
            tostring((center and center.key) or (blind.config and blind.config.blind and blind.config.blind.key) or (blind and (blind.key or blind.name)) or "unknown"),
            tostring(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or "unknown"),
            tostring(original),
            multiplier,
            tostring(blind.chips)))
    end
end

function BR.Blinds:install_ui_hook()
    if self.ui_installed then return true end
    if type(create_UIBox_blind_choice) ~= "function" then return false end
    local original_create_UIBox_blind_choice = create_UIBox_blind_choice
    create_UIBox_blind_choice = function(blind_type, ...)
        local args = {...}
        local config = BR.State.config and BR.State.config.blinds and BR.State.config.blinds.chips_multiplier
        if not config or not config.enabled or not BR.State.initialized then
            return original_create_UIBox_blind_choice(blind_type, unpack(args))
        end
        local choices = G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_choices
        local key = choices and choices[blind_type]
        local pool = G and G.P_BLINDS
        local center = key and pool and pool[key]
        local ante = G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0
        local multiplier = key and self:get_multiplier_for_key(key, ante) or nil
        if not center or not multiplier or _G.type(center.mult) ~= "number" then
            return original_create_UIBox_blind_choice(blind_type, unpack(args))
        end
        local original_mult = center.mult
        center.mult = original_mult * multiplier
        local ok, result = xpcall(function()
            return original_create_UIBox_blind_choice(blind_type, unpack(args))
        end, debug.traceback)
        center.mult = original_mult
        if not ok then error(result) end
        if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
            BR.Log:info(string.format("Blind UI | %s | key=%s | ante=%s | multiplier=%.2f", tostring(blind_type), tostring(key), tostring(ante), multiplier))
        end
        return result
    end
    self.ui_installed = true
    if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info("Blind selection UI hook installed")
    end
    return true
end

function BR.Blinds:get_boss_order_config()
    local live = BR.mod and BR.mod.config
    local live_boss_order = live and live.blinds and live.blinds.boss_order
    if type(live_boss_order) == "table" and live_boss_order.enabled == true then
        return live_boss_order
    end

    local snapshot = BR.State and BR.State.config
    local snapshot_boss_order = snapshot and snapshot.blinds and snapshot.blinds.boss_order
    if type(snapshot_boss_order) == "table" and snapshot_boss_order.enabled == true then
        return snapshot_boss_order
    end

    return nil
end

function BR.Blinds:is_showdown_ante()
    local ante = G and G.GAME and G.GAME.round_resets and tonumber(G.GAME.round_resets.ante) or 0
    local win_ante = G and G.GAME and tonumber(G.GAME.win_ante) or 8
    return win_ante > 0 and ante > 0 and (ante % win_ante == 0) and ante >= 2
end

local function get_boss_spec(center)
    if type(center) ~= "table" then return nil end
    if type(center.boss) == "table" then return center.boss end
    if center.boss == true then
        if type(center.config) == "table" and type(center.config.boss) == "table" then
            return center.config.boss
        end
        return {}
    end
    return nil
end

local function is_boss_center(center)
    return get_boss_spec(center) ~= nil
end

local function boss_used_count(key)
    local used = G and G.GAME and G.GAME.bosses_used
    if type(used) ~= "table" then return 0 end
    if type(used.boss) == "table" then
        return tonumber(used.boss[key]) or 0
    end
    return tonumber(used[key]) or 0
end

function BR.Blinds:build_random_boss_pool()
    local config = self:get_boss_order_config()
    if not config or not G or type(G.P_BLINDS) ~= "table" or not G.GAME then return nil end

    local ante = math.max(1, tonumber(G.GAME.round_resets and G.GAME.round_resets.ante) or 1)
    local win_ante = tonumber(G.GAME.win_ante) or 8
    local showdown_ante = self:is_showdown_ante()
    local banned = G.GAME.banned_keys or {}
    local candidates = {}

    for key, center in pairs(G.P_BLINDS) do
        local boss = get_boss_spec(center)
        if boss and not banned[key] then
            local showdown = boss.showdown == true
            local min_ante = tonumber(boss.min) or 1
            local max_ante = tonumber(boss.max)
            local eligible = false

            if showdown_ante then
                eligible = showdown
            elseif showdown then
                eligible = config.allow_showdown == true
            else
                eligible = ante >= min_ante and (max_ante == nil or ante <= max_ante)
            end

            if eligible then
                candidates[key] = boss_used_count(key)
            end
        end
    end

    local min_use = math.huge
    for _, count in pairs(candidates) do
        if count < min_use then min_use = count end
    end
    if min_use == math.huge then return nil end

    local pool = {}
    for key, count in pairs(candidates) do
        if count == min_use then
            pool[#pool + 1] = key
        end
    end
    table.sort(pool, function(a, b) return tostring(a) < tostring(b) end)
    return pool
end

function BR.Blinds:select_random_boss()
    local pool = self:build_random_boss_pool()
    if not pool or #pool == 0 then return nil end

    local rng = BR.State and BR.State.rng
    if rng and type(rng.fork) == "function" then
        local run_seed = tostring(BR.State.seed or "run")
        self.boss_order_seed = run_seed

        local counter
        if G and G.GAME then
            counter = math.floor(tonumber(G.GAME.br_randomizer_boss_order_counter) or 0) + 1
            G.GAME.br_randomizer_boss_order_counter = counter
        else
            counter = (self.boss_order_counter or 0) + 1
        end
        self.boss_order_counter = counter

        local fork = rng:fork(string.format("blinds.boss_order.%s", counter))
        if fork and type(fork.int) == "function" then
            return pool[fork:int(1, #pool)]
        end
    end

    local seed = "boss"
    if type(pseudoseed) == "function" then seed = pseudoseed("boss") end
    if type(pseudorandom_element) == "function" then
        return pseudorandom_element(pool, seed)
    end
    return pool[1]
end

function BR.Blinds:record_boss_use(blind_key)
    if not blind_key or not G or not G.GAME then return end

    local used = G.GAME.bosses_used
    if type(used) ~= "table" then
        G.GAME.bosses_used = {}
        used = G.GAME.bosses_used
    end

    if type(SMODS) == "table" and type(SMODS.add_boss_to_used_table) == "function" then
        local ok = pcall(SMODS.add_boss_to_used_table, blind_key, "boss")
        if ok then return end
    end

    if type(used.boss) == "table" then
        used.boss[blind_key] = (tonumber(used.boss[blind_key]) or 0) + 1
    else
        used[blind_key] = (tonumber(used[blind_key]) or 0) + 1
    end
end

function BR.Blinds:install_boss_order_hook()
    if self.boss_order_global_installed then return true end
    if type(get_new_boss) ~= "function" then return false end

    local original_get_new_boss = get_new_boss
    get_new_boss = function(...)
        local config = BR.Blinds:get_boss_order_config()
        if config then
            local selected = BR.Blinds:select_random_boss()
            if selected then
                BR.Blinds:record_boss_use(selected)
                return selected
            end
        end
        return original_get_new_boss(...)
    end

    self.boss_order_global_installed = true
    self.boss_order_installed = true
    if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info("Boss order hook installed via get_new_boss")
    end
    return true
end

function BR.Blinds:install()
    if not self.installed and type(Blind) == "table" and type(Blind.set_blind) == "function" then
        local original_set_blind = Blind.set_blind
        Blind.set_blind = function(blind, center, reset, silent)
            local current_type = G and G.GAME and G.GAME.blind_on_deck or nil
            local result = original_set_blind(blind, center, reset, silent)
            if not reset then
                if G and G.GAME then
                    G.GAME.br_last_blind_type = current_type
                end
                BR.Blinds:apply_chips_multiplier(blind, center)
            end
            return result
        end
        self.installed = true
        if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
            BR.Log:info("Blind chips hook installed")
        end
    end
    return self.installed == true
end

function BR.Blinds:install_hooks()
    local gameplay = self:install()
    local ui = self:install_ui_hook()
    local boss_order = self:install_boss_order_hook()
    return gameplay or ui or boss_order
end

return BR.Blinds
