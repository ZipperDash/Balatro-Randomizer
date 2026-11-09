return {
    economy = {
        starting_money = {
            enabled = true,
            min = 1,
            max = 10
        },
        blind_reward = {
            enabled = false,
            min = 1,
            max = 8
        },
        money_accumulation = {
            enabled = true
        }
    },
    shop = {
        reroll_cost = {
            enabled = false,
            min = 1,
            max = 10
        },
        disable = {
            enabled = false
        },
        boss_only = {
            enabled = false
        }
    },
    blinds = {
        chips_multiplier = {
            enabled = false,
            values = {0.5, 1.0, 1.5, 2.0}
        },
        boss_order = {
            enabled = false,
            allow_showdown = false
        }
    },
    boosters = {
        buy_cost = {
            enabled = false,
            min = 4,
            max = 8
        }
    },
    player_resources = {
        hands = {
            enabled = false,
            values = {-1, 0, 1}
        },
        discards = {
            enabled = false,
            values = {-1, 0, 1}
        },
        hand_size = {
            enabled = false,
            values = {-1, 0, 1}
        }
    },
    vouchers = {
        buy_cost = {
            enabled = false,
            min = 5,
            max = 15
        },
        order = {
            enabled = false
        }
    },
    playing_cards = {
        rank_randomization = {
            enabled = false
        },
        suit_randomization = {
            enabled = false
        },
        first_hand_only = {
            enabled = false
        }
    },
    jokers = {
        activation_skip = {
            enabled = false
        },
        activation_repeat = {
            enabled = false
        },
        buy_cost = {
            enabled = false,
            min = 1,
            max = 10
        },
        sell_value = {
            enabled = false,
            min = 1,
            max = 10
        },
        spawn_weight = {
            enabled = false,
            min = 1,
            max = 10
        }
    },
    planets = {
        hand_type = {
            enabled = false
        },
        upgrade_level = {
            enabled = false,
            min = 1,
            max = 5
        }
    },
    consumables = {
        buy_cost = {
            enabled = false,
            min = 1,
            max = 5
        },
        sell_value = {
            enabled = false,
            min = 1,
            max = 5
        },
        spawn_weight = {
            enabled = false,
            min = 1,
            max = 5
        },
        select_cards = {
            enabled = false,
            min = 1,
            max = 5
        }
    },
    spectrals = {
        create_cards = {
            enabled = false,
            min = 1,
            max = 5
        },
        cryptid_copies = {
            enabled = false,
            min = 1,
            max = 5
        },
        immolate_destroy = {
            enabled = false,
            min = 1,
            max = 10
        }
    },
    debug = {
        enabled = false,
        log_seed = false,
        log_joker_weights = false,
        log_consumable_weights = false,
        log_weight_pools = false
    }
}
