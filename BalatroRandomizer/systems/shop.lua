BR.Shop = BR.Shop or {}

function BR.Shop:apply_reroll_cost()
    if not BR.State.initialized or not G or not G.GAME then return end
    local reroll_cost = BR.State.config.shop.reroll_cost
    if reroll_cost == nil then return end

    G.GAME.base_reroll_cost = reroll_cost
    if G.GAME.round_resets then
        G.GAME.round_resets.reroll_cost = reroll_cost
    end
    if G.GAME.current_round and G.GAME.current_round.reroll_cost then
        G.GAME.current_round.reroll_cost = reroll_cost
    end
end

local previous_reset_game_globals = BR.State.reset

function BR.State:reset(run_start)
    previous_reset_game_globals(self, run_start)
    if run_start then
        BR.Shop:apply_reroll_cost()
    end
end

function BR.Shop:should_disable_shop()
    if not BR.State.initialized or not BR.State.config or not BR.State.config.shop then
        return false
    end

    local shop = BR.State.config.shop
    if shop.disable and shop.disable.enabled == true then
        return true
    end

    if shop.boss_only and shop.boss_only.enabled == true then
        local last_blind_type = G and G.GAME and G.GAME.br_last_blind_type or nil
        return last_blind_type ~= "Boss"
    end

    return false
end

function BR.Shop:install_disable_hook()
    if self.disable_installed then return true end
    if not Game or type(Game.update_shop) ~= "function" then return false end

    local original_update_shop = Game.update_shop
    function Game:update_shop(dt)
        if BR.Shop:should_disable_shop() then
            G.STATE = G.STATES.BLIND_SELECT
            G.STATE_COMPLETE = false
            if BR.Config:is_enabled("debug.enabled", false) then
                BR.Log:info("Shop disabled | intercepted Game:update_shop before shop creation")
            end
            return
        end
        return original_update_shop(self, dt)
    end

    self.disable_installed = true
    if BR.Log and BR.Log.info and BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info("Shop disable hook installed on Game:update_shop")
    end
    return true
end

BR.Shop:install_disable_hook()
