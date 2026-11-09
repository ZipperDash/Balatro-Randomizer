BR.Planets = BR.Planets or {}

function BR.Planets:apply_extra_upgrade(card)
    if not card or not card.config or not card.config.center then return end
    local center = card.config.center
    if center.set ~= "Planet" then return end
    if not BR.State.initialized or not BR.State.config or not BR.State.config.planets then return end
    local config = BR.State.config.planets[center.key]
    if not config then return end
    local total_level = tonumber(config.upgrade_level) or 1
    local extra_levels = total_level - 1
    if extra_levels <= 0 then return end
    local hand_type = config.hand_type or card.ability.consumeable and card.ability.consumeable.hand_type
    if not hand_type or not G or not G.GAME or not G.GAME.hands or not G.GAME.hands[hand_type] then return end
    if SMODS.upgrade_poker_hands then
        SMODS.upgrade_poker_hands({
            hands = hand_type,
            level_up = extra_levels,
            from = card
        })
    elseif level_up_hand then
        level_up_hand(card, hand_type, false, extra_levels)
    end
end

local previous_calculate = BR.mod.calculate

function BR.mod.calculate(self, context)
    if previous_calculate then
        local result = previous_calculate(self, context)
        if result ~= nil then return result end
    end
    if context and context.using_consumeable and context.consumeable then
        local card = context.consumeable
        if card.config and card.config.center and card.config.center.set == "Planet" then
            BR.Planets:apply_extra_upgrade(card)
        end
    end
end
