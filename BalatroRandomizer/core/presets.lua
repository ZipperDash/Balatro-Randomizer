BR.Presets = BR.Presets or {}

local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = clone(child)
    end
    return result
end

local function merge(dst, src)
    for key, value in pairs(src or {}) do
        if type(value) == "table" and type(dst[key]) == "table" then
            merge(dst[key], value)
        else
            dst[key] = clone(value)
        end
    end
end

BR.Presets.list = {
    {
        id = "default_values",
        label_key = "br_preset_default_values",
        description_key = "br_preset_default_values_desc",
        overrides = {}
    },
    {
        id = "empty_wallet",
        label_key = "br_preset_empty_wallet",
        description_key = "br_preset_empty_wallet_desc",
        overrides = {
            economy = {
                starting_money = {enabled = true, min = 0, max = 0},
                blind_reward = {enabled = true, min = 4, max = 10},
                money_accumulation = {enabled = false}
            }
        }
    },
    {
        id = "all_on_red",
        label_key = "br_preset_all_on_red",
        description_key = "br_preset_all_on_red_desc",
        overrides = {
            economy = {
                blind_reward = {enabled = true, min = 0, max = 0}
            },
            blinds = {
                boss_order = {enabled = true, allow_showdown = true},
                chips_multiplier = {enabled = true, values = {0.5, 1.0, 1.5, 2.0}}
            },
            player_resources = {
                hands = {enabled = true, values = {-1, 0, 1}},
                discards = {enabled = true, values = {-1, 0, 1}},
                hand_size = {enabled = true, values = {-1, 0, 1}}
            }
        }
    },
    {
        id = "lite_instability",
        label_key = "br_preset_lite_instability",
        description_key = "br_preset_lite_instability_desc",
        overrides = {
            economy = {
                starting_money = {enabled = true, min = 1, max = 6},
                blind_reward = {enabled = true, min = 1, max = 8},
            },
            shop = {
                reroll_cost = {enabled = true, min = 3, max = 7}
            },
            planets = {
                hand_type = {enabled = true}
            },
            playing_cards = {
                rank_randomization = {enabled = true},
                suit_randomization = {enabled = true},
                first_hand_only = {enabled = true}
            }
	}
    },
    {
        id = "joker_lottery",
        label_key = "br_preset_joker_lottery",
        description_key = "br_preset_joker_lottery_desc",
        overrides = {
            jokers = {
                activation_skip = {enabled = true},
                activation_repeat = {enabled = true},
                buy_cost = {enabled = true, min = 1, max = 10},
                sell_value = {enabled = true, min = 1, max = 10}
            }
        }
    },
    {
        id = "parade_of_planets",
        label_key = "br_preset_parade_of_planets",
        description_key = "br_preset_parade_of_planets_desc",
        overrides = {
            planets = {
                hand_type = {enabled = true},
                upgrade_level = {enabled = true, min = 1, max = 5}
            }
	    }
    },
    {
        id = "random_number_generator",
        label_key = "br_preset_random_number_generator",
        description_key = "br_preset_random_number_generator_desc",
        overrides = {
            shop = {
                reroll_cost = {enabled = true, min = 1, max = 10}
            },
            consumables = {
		        buy_cost = {enabled = false, min = 1, max = 5},
        	    sell_value = {enabled = false, min = 1, max = 5},
                select_cards = {enabled = true, min = 1, max = 5}
            },
            planets = {
                hand_type = {enabled = true},
                upgrade_level = {enabled = true, min = 1, max = 3}
            },
            spectrals = {
                create_cards = {enabled = true, min = 1, max = 5},
                cryptid_copies = {enabled = true, min = 1, max = 5},
                immolate_destroy = {enabled = true, min = 1, max = 10}
            },
            jokers = {
                buy_cost = {enabled = true, min = 1, max = 10},
                sell_value = {enabled = true, min = 1, max = 10}
            },
            boosters = {
		        buy_cost = {enabled = true, min = 4, max = 8}
            },
            vouchers = {
		        order = {enabled = true}
            },
            blinds = {
		        boss_order = {enabled = true},
                chips_multiplier = {enabled = true, values = {0.5, 1.0, 1.5, 2.0}}
            }
        }
    },
    {
        id = "increased_difficulty",
        label_key = "br_preset_increased_difficulty",
        description_key = "br_preset_increased_difficulty_desc",
        overrides = {
            economy = {
                starting_money = {enabled = true, min = 0, max = 0},
                blind_reward = {enabled = true, min = 0, max = 6}
            },
            shop = {
                reroll_cost = {enabled = true, min = 1, max = 10},
		        boss_only = {enabled = true}
	        },
            jokers = {
                activation_skip = {enabled = true},
                activation_repeat = {enabled = true},
		        buy_cost = {enabled = true, min = 1, max = 10},
                sell_value = {enabled = true, min = 1, max = 10}
            },
            consumables = {
		        buy_cost = {enabled = false, min = 1, max = 5},
        	    sell_value = {enabled = false, min = 1, max = 5}
            },
            planets = {
                hand_type = {enabled = true}
            },
            boosters = {
        	    buy_cost = {enabled = true, min = 4, max = 8}
	        },
            vouchers = {
                order = {enabled = true}
            },
            playing_cards = {
                rank_randomization = {enabled = true},
                suit_randomization = {enabled = true},
                first_hand_only = {enabled = false}
            },
	        player_resources = {
                hands = {enabled = true, values = {-1, 0, 1}},
                discards = {enabled = true, values = {-1, 0, 1}},
                hand_size = {enabled = true, values = {-1, 0, 1}}
            },
            blinds = {
                boss_order = {enabled = true, allow_showdown = true},
                chips_multiplier = {enabled = true, values = {0.5, 1.0, 1.5, 2.0}}
            }
        }
    },
    {
        id = "how_what_and_why",
        label_key = "br_preset_how_what_and_why",
        description_key = "br_preset_how_what_and_why_desc",
        overrides = {
            economy = {
                starting_money = {enabled = true, min = 0, max = 0},
                blind_reward = {enabled = true, min = 0, max = 0},
                money_accumulation = {enabled = false}
            },
            shop = {
		disable = {enabled = true}
	        },
            jokers = {
                activation_skip = {enabled = true},
                activation_repeat = {enabled = true}
		},
            planets = {
                hand_type = {enabled = true}
            },
            playing_cards = {
                rank_randomization = {enabled = true},
                suit_randomization = {enabled = true},
                first_hand_only = {enabled = false}
            },
	    player_resources = {
                hands = {enabled = true, values = {-1, 0, 1}},
                discards = {enabled = true, values = {-1, 0, 1}},
                hand_size = {enabled = true, values = {-1, 0, 1}}
            },
            blinds = {
                boss_order = {enabled = true, allow_showdown = true},
                chips_multiplier = {enabled = true, values = {0.5, 1.0, 1.5, 2.0}}
            }
        }
    }
}

function BR.Presets:build(preset)
    local defaults = BR.Config and BR.Config.defaults or {}
    local result = clone(defaults)
    merge(result, preset and preset.overrides or {})
    return result
end

function BR.Presets:find(id)
    for _, preset in ipairs(self.list) do
        if preset.id == id then return preset end
    end
end

return BR.Presets