BR.PlayerResources = BR.PlayerResources or {}

local function choose_modifier(config, namespace, rng)
    if not config or not config.enabled then return 0 end
    local value = rng:fork(namespace):pick(config.values)
    return tonumber(value) or 0
end

function BR.PlayerResources:apply_starting_values()
    if not BR.State.initialized or not BR.State.config or not G or not G.GAME or not G.GAME.starting_params then return end
    if BR.State.player_resources_applied then return end

    local config = BR.State.config.player_resources
    if not config then return end

    local starting = G.GAME.starting_params
    local hands_base = math.floor(tonumber(starting.hands) or 1)
    local discards_base = math.floor(tonumber(starting.discards) or 1)
    local hand_size_base = math.floor(tonumber(starting.hand_size) or 1)

    local hands_modifier = choose_modifier(config.hands, "player_resources.hands", BR.State.rng)
    local discards_modifier = choose_modifier(config.discards, "player_resources.discards", BR.State.rng)
    local hand_size_modifier = choose_modifier(config.hand_size, "player_resources.hand_size", BR.State.rng)

    local hands = math.max(1, hands_base + hands_modifier)
    local discards = math.max(1, discards_base + discards_modifier)
    local hand_size = math.max(1, hand_size_base + hand_size_modifier)

    starting.hands = hands
    starting.discards = discards
    starting.hand_size = hand_size

    G.GAME.round_resets = G.GAME.round_resets or {}
    G.GAME.current_round = G.GAME.current_round or {}
    G.GAME.round_resets.hands = hands
    G.GAME.round_resets.discards = discards
    G.GAME.current_round.hands_left = hands_base
    G.GAME.current_round.discards_left = discards_base

    if hands_modifier ~= 0 then
        ease_hands_played(hands_modifier)
    end
    if discards_modifier ~= 0 then
        ease_discard(discards_modifier)
    end

    if G.hand and G.hand.config then
        G.hand.config.card_limit = hand_size
        G.hand.config.real_card_limit = hand_size
    end

    BR.State.player_resources_applied = true

    if BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info(string.format("Player resources | hands=%d (base=%d, mod=%d) | discards=%d (base=%d, mod=%d) | hand_size=%d (base=%d, mod=%d)", hands, hands_base, hands_modifier, discards, discards_base, discards_modifier, hand_size, hand_size_base, hand_size_modifier))
    end
end

local previous_apply_to_run = Back.apply_to_run
function Back.apply_to_run(self, arg)
    local result = previous_apply_to_run(self, arg)
    if BR.State.initialized and BR.State.config then
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                BR.PlayerResources:apply_starting_values()
                return true
            end
        }))
    end
    return result
end
