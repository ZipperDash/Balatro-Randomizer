BR.Economy = BR.Economy or {}

function BR.Economy:apply_starting_money()
    if not BR.State.initialized or not G or not G.GAME then return end
    local starting_money = BR.State.config.economy.starting_money
    if starting_money == nil then return end
    G.GAME.dollars = starting_money
end

function BR.Economy:apply_money_accumulation()
    if not BR.State.initialized or not G or not G.GAME then return end
    local money_accumulation = BR.State.config.economy.money_accumulation
    if money_accumulation == nil or money_accumulation == true then return end
    local dollars = tonumber(G.GAME.dollars) or 0
    if dollars <= 0 then return end
    ease_dollars(-dollars, true)
    if BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info("Money accumulation disabled | balance reset to 0 at blind start")
    end
end

function BR.Economy:randomize_blind_reward()
    if not BR.State.initialized or not G or not G.GAME or not G.GAME.blind then return end
    if not BR.Config:is_enabled("economy.blind_reward.enabled", false) then return end

    local minimum, maximum = BR.Config:get_range("economy.blind_reward", 0, 10, 0, 1000000)
    local rng = BR.State.rng:fork("economy.blind_reward." .. tostring(G.GAME.round_resets.blind))
    G.GAME.blind.dollars = rng:int(minimum, maximum)
end

local previous_reset_game_globals = BR.State.reset

function BR.State:reset(run_start)
    previous_reset_game_globals(self, run_start)
    if run_start then
        BR.Economy:apply_starting_money()
    end
end

local previous_calculate = BR.mod.calculate

function BR.mod.calculate(self, context)
    if previous_calculate then
        local result = previous_calculate(self, context)
        if result ~= nil then return result end
    end
    if context and context.setting_blind then
        BR.Economy:randomize_blind_reward()
    end
end

local previous_set_blind = Blind.set_blind

function Blind:set_blind(blind, reset, silent)
    local result = previous_set_blind(self, blind, reset, silent)
    if not reset and blind and BR.State.initialized then
        BR.Economy:apply_money_accumulation()
    end
    return result
end
