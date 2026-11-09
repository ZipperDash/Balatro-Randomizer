BR.PlayingCards = BR.PlayingCards or {}

local RANKS = {
    "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"
}

local SUITS = {
    "Diamonds", "Clubs", "Hearts", "Spades"
}

function BR.PlayingCards:is_rank_randomization_enabled()
    return BR.Config:is_enabled("playing_cards.rank_randomization.enabled", false)
end

function BR.PlayingCards:is_suit_randomization_enabled()
    return BR.Config:is_enabled("playing_cards.suit_randomization.enabled", false)
end

function BR.PlayingCards:is_first_hand_only_enabled()
    return BR.Config:is_enabled("playing_cards.first_hand_only.enabled", false)
end

function BR.PlayingCards:get_rank_code(card)
    if not card or not card.base then return nil end
    return (card.base.value == "10" and "T") or
        (card.base.value == "Jack" and "J") or
        (card.base.value == "Queen" and "Q") or
        (card.base.value == "King" and "K") or
        (card.base.value == "Ace" and "A") or
        card.base.value
end

function BR.PlayingCards:get_suit_code(suit)
    if suit == "Diamonds" then return "D" end
    if suit == "Clubs" then return "C" end
    if suit == "Hearts" then return "H" end
    if suit == "Spades" then return "S" end
    return nil
end

function BR.PlayingCards:make_rng(path)
    local seed = math.floor(tonumber(BR.State.seed) or 1) % 2147483647
    if seed <= 0 then seed = 1 end

    for index = 1, #path do
        seed = (seed + string.byte(path, index) * 104729 + index * 1009) % 2147483647
        seed = (seed * 48271 + 17) % 2147483647
        seed = (seed + math.floor(seed / 32768) * 8191) % 2147483647
    end

    seed = (seed * 16807 + 23) % 2147483647
    seed = (seed + math.floor(seed / 4096) * 65537) % 2147483647
    if seed <= 0 then seed = 1 end
    return BR.RNG:new(seed)
end

function BR.PlayingCards:pick_card_values(card, hand_id, card_index)
    local rank_code = self:get_rank_code(card)
    local suit_code = self:get_suit_code(card.base.suit)
    if not rank_code or not suit_code then return nil, nil end

    if self:is_rank_randomization_enabled() then
        local rank_rng = self:make_rng(string.format("playing_cards.rank.hand.%d.card.%d", hand_id, card_index))
        rank_code = rank_rng:pick(RANKS)
    end

    if self:is_suit_randomization_enabled() then
        local suit_rng = self:make_rng(string.format("playing_cards.suit.hand.%d.card.%d", hand_id, card_index))
        suit_code = self:get_suit_code(suit_rng:pick(SUITS))
    end

    return rank_code, suit_code
end

function BR.PlayingCards:randomize_card(card, hand_id, card_index)
    if not BR.State.initialized or not BR.State.rng then return false end
    if not card or not card.base then return false end
    if not card.playing_card or card.area ~= G.play then return false end

    local rank_code, suit_code = self:pick_card_values(card, hand_id, card_index)
    if not rank_code or not suit_code then return false end

    local new_card = G.P_CARDS[suit_code .. "_" .. rank_code]
    if not new_card then return false end

    card:set_base(new_card)
    return true
end

local previous_draw_from_play_to_discard = G.FUNCS.draw_from_play_to_discard

G.FUNCS.draw_from_play_to_discard = function(e)
    local randomize_rank = BR.PlayingCards:is_rank_randomization_enabled()
    local randomize_suit = BR.PlayingCards:is_suit_randomization_enabled()

    if not randomize_rank and not randomize_suit then
        return previous_draw_from_play_to_discard(e)
    end

    if not G or not G.GAME or not G.GAME.current_round or not BR.State.initialized or not BR.State.rng or not SMODS or not SMODS.last_hand or not SMODS.last_hand.scoring_hand then
        return previous_draw_from_play_to_discard(e)
    end

    local current_round = G.GAME.round or 0
    local saved_round = G.GAME.br_randomizer_playing_card_round
    if saved_round ~= current_round then
        saved_round = current_round
        G.GAME.br_randomizer_playing_card_round = current_round
        G.GAME.br_randomizer_playing_card_round_hand_counter = 0
    end
    BR.State.playing_card_round = saved_round

    local hand_index = math.floor(tonumber(G.GAME.br_randomizer_playing_card_round_hand_counter) or 0) + 1
    G.GAME.br_randomizer_playing_card_round_hand_counter = hand_index
    BR.State.playing_card_round_hand_counter = hand_index

    local hand_id = math.floor(tonumber(G.GAME.br_randomizer_playing_card_hand_counter) or 0) + 1
    G.GAME.br_randomizer_playing_card_hand_counter = hand_id
    BR.State.playing_card_hand_counter = hand_id

    if BR.PlayingCards:is_first_hand_only_enabled() and hand_index ~= 1 then
        return previous_draw_from_play_to_discard(e)
    end

    local scoring_hand = SMODS.last_hand.scoring_hand
    local playable = {}
    for index, card in ipairs(scoring_hand) do
        if card and card.base and card.playing_card and card.area == G.play and not card.shattered and not card.destroyed then
            playable[#playable + 1] = {card = card, index = index}
        end
    end

    if #playable == 0 then
        return previous_draw_from_play_to_discard(e)
    end

    for position, entry in ipairs(playable) do
        local card = entry.card
        local percent = 1.15 - (position - 0.999) / (#playable - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = position == 1 and 0.05 or 0.08,
            func = function()
                if card and card.base and card.playing_card and card.area == G.play and not card.shattered and not card.destroyed then
                    local changed = BR.PlayingCards:randomize_card(card, hand_id, entry.index)
                    if changed then
                        card:juice_up(0.5, 0.5)
                    end
                end
                return true
            end
        }))
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 1.0,
        func = function()
            previous_draw_from_play_to_discard(e)
            return true
        end
    }))
end
