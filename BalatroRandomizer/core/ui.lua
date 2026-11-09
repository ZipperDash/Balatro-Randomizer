BR.UI = BR.UI or {}

local UI = BR.UI

local function loc(key, fallback)
    if key and type(localize) == "function" then
        local value = localize(key)
        if value ~= nil and value ~= key and value ~= "" then
            return value
        end
    end
    return fallback or key or ""
end

local function loc_lines(key, fallback)
    local value = loc(key, fallback)
    if type(value) == "table" then return value end
    return {tostring(value or "")}
end

local function display_label(entry)
    return loc(entry.label_key, entry.label)
end

local UI_ROW_GAP = 0.08

local function make_vertical_gap(width)
    return {
        n = G.UIT.R,
        config = {align = "cl", minw = width, maxw = width, minh = UI_ROW_GAP, maxh = UI_ROW_GAP, padding = 0},
        nodes = {}
    }
end

UI.active_tab = UI.active_tab or "presets"

UI.COLORS = UI.COLORS or {
    panel = HEX("30484D"),
    panel_inner = HEX("263C40"),
    tab = HEX("40565B"),
    tab_active = HEX("FF4A3D"),
    row = HEX("334B50"),
    help = HEX("52686C"),
    text = G.C.UI.TEXT_LIGHT,
    text_dim = HEX("B5C0C2"),
    cycle = G.C.RED,
    preset_active = G.C.BLUE
}

UI.RANGE_MIN = 0
UI.RANGE_MAX = 20

UI.tabs = {
    {
        id = "presets",
        label_key = "br_tab_presets",
        parameters = {},
        placeholder = true
    },
    {
        id = "economy",
        label_key = "br_tab_economy",
        parameters = {
            {key = "starting_money", label_key = "br_param_starting_money", range = {min = 0, max = 20},
                help_key = "br_help_starting_money"},
            {key = "blind_reward", label_key = "br_param_blind_reward", range = {min = 0, max = 20},
                help_key = "br_help_blind_reward"},
            {key = "money_accumulation", label_key = "br_param_money_accumulation",
                help_key = "br_help_money_accumulation"},
        }
    },
    {
        id = "blinds",
        label_key = "br_tab_blinds",
        parameters = {
            {key = "chips_multiplier", label_key = "br_param_chips_multiplier",
                help_key = "br_help_chips_multiplier"},
            {key = "boss_order", ref_value = "enabled", label_key = "br_param_boss_order",
                help_key = "br_help_boss_order"},
            {key = "boss_order", ref_value = "allow_showdown", label_key = "br_param_allow_showdown",
                help_key = "br_help_allow_showdown"},
        }
    },
    {
        id = "shop",
        label_key = "br_tab_shop",
        parameters = {
            {key = "reroll_cost", label_key = "br_param_reroll_cost", range = {min = 0, max = 20},
                help_key = "br_help_reroll_cost"},
            {key = "disable", label_key = "br_param_disable_shop",
                help_key = "br_help_disable_shop"},
            {key = "boss_only", label_key = "br_param_boss_only_shop",
                help_key = "br_help_boss_only_shop"},
        }
    },
    {
        id = "jokers",
        label_key = "br_tab_jokers",
        parameters = {
            {key = "activation_skip", label_key = "br_param_activation_skip",
                help_key = "br_help_activation_skip"},
            {key = "activation_repeat", label_key = "br_param_activation_repeat",
                help_key = "br_help_activation_repeat"},
            {key = "buy_cost", label_key = "br_param_buy_cost", range = {min = 1, max = 20},
                help_key = "br_help_buy_cost"},
            {key = "sell_value", label_key = "br_param_sell_value", range = {min = 1, max = 20},
                help_key = "br_help_sell_value"},
            {key = "spawn_weight", label_key = "br_param_spawn_weight", range = {min = 1, max = 20},
                help_key = "br_help_spawn_weight"},
        }
    },
    {
        id = "consumables",
        label_key = "br_tab_consumables",
        parameters = {
            {key = "buy_cost", label_key = "br_param_buy_cost", range = {min = 1, max = 20},
                help_key = "br_help_buy_cost"},
            {key = "sell_value", label_key = "br_param_sell_value", range = {min = 1, max = 20},
                help_key = "br_help_sell_value"},
            {key = "spawn_weight", label_key = "br_param_spawn_weight", range = {min = 1, max = 20},
                help_key = "br_help_spawn_weight"},
            {key = "select_cards", label_key = "br_param_select_cards", range = {min = 1, max = 5},
                help_key = "br_help_select_cards"},
        }
    },
    {
        id = "planets",
        label_key = "br_tab_planets",
        parameters = {
            {key = "hand_type", label_key = "br_param_hand_type",
                help_key = "br_help_hand_type"},
            {key = "upgrade_level", label_key = "br_param_upgrade_level", range = {min = 1, max = 5},
                help_key = "br_help_upgrade_level"},
        }
    },
    {
        id = "spectrals",
        label_key = "br_tab_spectrals",
        parameters = {
            {key = "create_cards", label_key = "br_param_create_cards", range = {min = 1, max = 5},
                help_key = "br_help_create_cards"},
            {key = "cryptid_copies", label_key = "br_param_cryptid_copies", range = {min = 1, max = 5},
                help_key = "br_help_cryptid_copies"},
            {key = "immolate_destroy", label_key = "br_param_immolate_destroy", range = {min = 1, max = 10},
                help_key = "br_help_immolate_destroy"},
        }
    },
    {
        id = "boosters",
        label_key = "br_tab_booster_packs",
        parameters = {
            {key = "buy_cost", label_key = "br_param_buy_cost", range = {min = 1, max = 20},
                help_key = "br_help_buy_cost"},
        }
    },
    {
        id = "vouchers",
        label_key = "br_tab_vouchers",
        parameters = {
            {key = "buy_cost", label_key = "br_param_buy_cost", range = {min = 1, max = 20},
                help_key = "br_help_buy_cost"},
            {key = "order", label_key = "br_param_order",
                help_key = "br_help_order"},
        }
    },
    {
        id = "playing_cards",
        label_key = "br_tab_playing_cards",
        parameters = {
            {key = "rank_randomization", label_key = "br_param_rank_randomization",
                help_key = "br_help_rank_randomization"},
            {key = "suit_randomization", label_key = "br_param_suit_randomization",
                help_key = "br_help_suit_randomization"},
            {key = "first_hand_only", label_key = "br_param_first_hand_only",
                help_key = "br_help_first_hand_only"},
        }
    },
    {
        id = "player_resources",
        label_key = "br_tab_other",
        parameters = {
            {key = "hands", label_key = "br_param_hands",
                help_key = "br_help_hands"},
            {key = "discards", label_key = "br_param_discards",
                help_key = "br_help_discards"},
            {key = "hand_size", label_key = "br_param_hand_size",
                help_key = "br_help_hand_size"},
        }
    }
}

local function find_tab(tab_id)
    for _, tab in ipairs(UI.tabs) do
        if tab.id == tab_id then return tab end
    end
    return UI.tabs[1]
end

local function save_config()
    if SMODS and SMODS.save_mod_config and BR.mod then
        SMODS.save_mod_config(BR.mod)
    end
end

local function clear_active_preset()
    UI.active_preset = nil
    if BR.mod and BR.mod.config then
        BR.mod.config.__active_preset = nil
    end
end

local function clone_value(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = clone_value(child) end
    return result
end

local function deep_equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key, value in pairs(a) do
        if key ~= "__active_preset" and key ~= "__defaults_hash" then
            if not deep_equal(value, b[key]) then return false end
        end
    end
    for key, value in pairs(b) do
        if key ~= "__active_preset" and key ~= "__defaults_hash" then
            if not deep_equal(value, a[key]) then return false end
        end
    end
    return true
end

local function preset_matches_config(preset)
    if not preset or not BR.mod or type(BR.mod.config) ~= "table" then return false end
    local expected = BR.Presets:build(preset)
    local current = BR.mod.config

    for key in pairs(BR.Config.defaults or {}) do
        if key ~= "debug" and not deep_equal(current[key], expected[key]) then
            return false
        end
    end
    return true
end

local function detect_active_preset()
    if not BR.Presets or not BR.mod or type(BR.mod.config) ~= "table" then return nil end
    local stored = BR.mod.config.__active_preset
    if stored and BR.Presets:find(stored) then
        local preset = BR.Presets:find(stored)
        if preset_matches_config(preset) then return preset.id end
    end
    for _, preset in ipairs(BR.Presets.list) do
        if preset_matches_config(preset) then
            return preset.id
        end
    end
    return nil
end

local function mark_parameter_changed()
    clear_active_preset()

    if BR.Config then BR.Config.current = BR.mod and BR.mod.config or BR.Config.current end
    save_config()
end

local function get_parameter_config(tab, parameter)
    local config = BR.mod and BR.mod.config and BR.mod.config[tab.id]
    if type(config) ~= "table" then config = {} end

    local target = config
    local default_target = BR.Config and BR.Config.defaults and BR.Config.defaults[tab.id]
    local path_parts = {}
    for part in string.gmatch(parameter.key, "[^.]+") do path_parts[#path_parts + 1] = part end
    local leaf_key = path_parts[#path_parts]
    for i = 1, #path_parts - 1 do
        local part = path_parts[i]
        if type(target[part]) ~= "table" then target[part] = {} end
        target = target[part]
        if type(default_target) == "table" then default_target = default_target[part] end
    end

    local value = target[leaf_key]
    if type(value) ~= "table" then value = {} end

    local default_value = type(default_target) == "table" and default_target[leaf_key] or nil
    if type(default_value) == "table" then
        if value.enabled == nil then value.enabled = default_value.enabled end
        if value.min == nil then value.min = default_value.min end
        if value.max == nil then value.max = default_value.max end
        if value.values == nil then value.values = default_value.values end
    end

    if parameter.range then
        local min_value = tonumber(value.min)
        local max_value = tonumber(value.max)
        local clamped_min = math.max(parameter.range.min, math.min(parameter.range.max, min_value or parameter.range.min))
        local clamped_max = math.max(parameter.range.min, math.min(parameter.range.max, max_value or parameter.range.max))
        value.min = clamped_min
        value.max = clamped_max
        if value.min > value.max then value.max = value.min end
    end

    target[leaf_key] = value
    if BR.mod and BR.mod.config then BR.mod.config[tab.id] = config end
    return value
end

local function make_tooltip_node(help_text)
    if not help_text then return nil end

    local tooltip_text = type(help_text) == "table" and help_text or {tostring(help_text)}

    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            minw = 0.39,
            maxw = 0.39,
            minh = 0.39,
            maxh = 0.39,
            padding = 0.02,
            r = 0.20,
            colour = UI.COLORS.help,
            hover = true,
            tooltip = {
                text = tooltip_text
            }
        },
        nodes = {
            {n = G.UIT.T, config = {
                text = "?",
                scale = 0.32,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true
            }}
        }
    }
end

local function make_help_node(parameter)
    local help_text = parameter.help_key and loc_lines(parameter.help_key, parameter.help) or parameter.help
    local help = make_tooltip_node(help_text)
    if not help then return nil end

    return {
        n = G.UIT.C,
        config = {align = "cm", minw = 0.50, maxw = 0.50, minh = 0.50, maxh = 0.50, padding = 0},
        nodes = {help}
    }
end

local function cycle_bound(parameter, side, current)
    local range = parameter.range
    if not range then return current end
    local step = range.step or 1
    local next_value = current + (side == "next" and step or -step)
    if next_value > range.max then next_value = range.min end
    if next_value < range.min then next_value = range.max end
    return next_value
end

function G.FUNCS.brnd_cycle_range(args)
    if not args or not args.config then return end
    local data = args.config.ref_table or args.config
    local tab = find_tab(data.tab_id)
    local parameter = nil
    for _, item in ipairs(tab.parameters or {}) do
        if item.key == data.parameter_key then parameter = item break end
    end
    if not parameter or not parameter.range then return end

    local config = get_parameter_config(tab, parameter)
    local field = data.range_field == "max" and "max" or "min"
    local current = tonumber(config[field])
    if current == nil then
        current = field == "min" and parameter.range.min or parameter.range.max
    end

    config[field] = cycle_bound(parameter, data.side, current)

    if config.min ~= nil and config.max ~= nil then
        if config.min > config.max then
            if field == "min" then config.max = config.min else config.min = config.max end
        end
    end

    mark_parameter_changed()
    UI.refresh_content(tab.id)
end

local function make_cycle_button(tab, parameter, field, side)

    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            minw = 0.50,
            maxw = 0.50,
            minh = 0.46,
            maxh = 0.46,
            padding = 0,
            r = 0.06,
            colour = G.C.RED,
            shadow = true,
            button = "brnd_cycle_range",
            focus_args = {type = "none"},
            ref_table = {
                tab_id = tab.id,
                parameter_key = parameter.key,
                range_field = field,
                side = side
            }
        },
        nodes = {
            {n = G.UIT.T, config = {
                text = side == "next" and ">" or "<",
                scale = 0.36,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true
            }}
        }
    }
end

local function make_range_value(tab, parameter, field, value)
    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            minw = 0.78,
            maxw = 0.78,
            minh = 0.46,
            maxh = 0.46,
            shadow = true,
            padding = 0.01,
            r = 0.06,
            colour = G.C.RED
        },
        nodes = {
            {n = G.UIT.T, config = {
                text = tostring(value),
                scale = 0.36,
                colour = G.C.UI.TEXT_LIGHT,
                shadow = true
            }}
        }
    }
end

local function make_range_header()

    return {
        n = G.UIT.R,
        config = {
            align = "cr",
            minw = 4.95,
            maxw = 4.95,
            minh = 0.28,
            padding = 0.01
        },
        nodes = {
            {n = G.UIT.C, config = {align = "cm", minw = 0.16, maxw = 0.16, padding = 0}, nodes = {}},
            {n = G.UIT.C, config = {align = "cm", minw = 1.94, maxw = 1.94, padding = 0}, nodes = {
                {n = G.UIT.T, config = {text = loc("br_min", "Min"), scale = 0.30, colour = UI.COLORS.text_dim, shadow = true}}
            }},
            {n = G.UIT.C, config = {align = "cm", minw = 0.16, maxw = 0.16, padding = 0}, nodes = {}},
            {n = G.UIT.C, config = {align = "cm", minw = 1.94, maxw = 1.94, padding = 0}, nodes = {
                {n = G.UIT.T, config = {text = loc("br_max", "Max"), scale = 0.30, colour = UI.COLORS.text_dim, shadow = true}}
            }}
        }
    }
end

local function make_range_controls(tab, parameter, config)
    local minimum = tonumber(config.min)
    local maximum = tonumber(config.max)
    if minimum == nil then minimum = parameter.range.min end
    if maximum == nil then maximum = parameter.range.max end

    local function spacer(width)
        return {n = G.UIT.C, config = {align = "cm", minw = width, maxw = width, padding = 0}, nodes = {}}
    end

    return {
        n = G.UIT.R,
        config = {align = "cr", minw = 4.04, maxw = 4.04, minh = 0.46, maxh = 0.46, padding = 0},
        nodes = {
            {n = G.UIT.C, config = {align = "cm", minw = 1.94, maxw = 1.94, padding = 0}, nodes = {
                make_cycle_button(tab, parameter, "min", "prev"),
                spacer(0.08),
                make_range_value(tab, parameter, "min", minimum),
                spacer(0.08),
                make_cycle_button(tab, parameter, "min", "next")
            }},
            spacer(0.16),
            {n = G.UIT.C, config = {align = "cm", minw = 1.94, maxw = 1.94, padding = 0}, nodes = {
                make_cycle_button(tab, parameter, "max", "prev"),
                spacer(0.08),
                make_range_value(tab, parameter, "max", maximum),
                spacer(0.08),
                make_cycle_button(tab, parameter, "max", "next")
            }}
        }
    }
end

local function make_parameter_row(tab, parameter)
    local config = get_parameter_config(tab, parameter)

    local nodes = {}
    if parameter.range then
        nodes[#nodes + 1] = make_range_header()
    end

    local bottom_nodes = {
        {
            n = G.UIT.C,
            config = {align = "cl", minw = 5.25, padding = 0.12},
            nodes = {
                {n = G.UIT.T, config = {
                    text = display_label(parameter),
                    scale = 0.42,
                    colour = UI.COLORS.text,
                    shadow = true
                }}
            }
        }
    }

    local help_node = make_help_node(parameter)
    if help_node then bottom_nodes[#bottom_nodes + 1] = help_node end

    bottom_nodes[#bottom_nodes + 1] = {
        n = G.UIT.C,
        config = {align = "cm", minw = 0.72, padding = 0.02},
        nodes = {
            create_toggle({
                label = "",
                scale = 0.78,
                w = 0,
                shadow = true,
                ref_table = config,
                ref_value = parameter.ref_value or "enabled",
                callback = mark_parameter_changed
            })
        }
    }

    if parameter.range then
        bottom_nodes[#bottom_nodes + 1] = {
            n = G.UIT.C,
            config = {align = "cr", minw = 4.95, padding = 0.02},
            nodes = {make_range_controls(tab, parameter, config)}
        }
    end

    nodes[#nodes + 1] = {
        n = G.UIT.R,
        config = {
            align = "cl",
            minw = 11.50,
            minh = parameter.range and 0.58 or 0.58,
            padding = 0.02
        },
        nodes = bottom_nodes
    }

    return {
        n = G.UIT.R,
        config = {
            align = "cl",
            minw = 11.50,
            minh = parameter.range and 0.90 or 0.58,
            padding = 0.06,
            r = 0.06,
            colour = UI.COLORS.row
        },
        nodes = nodes
    }
end

local function apply_preset(preset)
    if not preset or not BR.Presets or not BR.mod then return end
    local built = BR.Presets:build(preset)
    local config = BR.mod.config or {}

    for key in pairs(BR.Config.defaults or {}) do
        if key ~= "debug" then
            config[key] = clone_value(built[key])
        end
    end

    config.__active_preset = preset.id
    BR.mod.config = config
    BR.Config.current = config
    UI.active_preset = preset.id
    save_config()
end

function G.FUNCS.brnd_select_preset(args)
    if not args or not args.config then return end
    local data = args.config.ref_table or args.config
    local preset = BR.Presets and BR.Presets:find(data.preset_id)
    if not preset then return end
    apply_preset(preset)

    UI.refresh_content(UI.active_tab)
    UI.refresh_content("presets")
end

local function preset_label(preset)
    return loc(preset.label_key, preset.label)
end

local function preset_description(preset)
    if preset.description_key then return loc_lines(preset.description_key, preset.description) end
    return type(preset.description) == "table" and preset.description or {tostring(preset.description or "")}
end

local function make_preset_button(preset)
    local active = preset.id == UI.active_preset
    return UIBox_button({
        id = "brnd_preset_" .. preset.id,
        button = "brnd_select_preset",
        label = {preset_label(preset)},
        ref_table = {preset_id = preset.id},
        colour = active and UI.COLORS.preset_active or UI.COLORS.tab,
        minw = 12.35,
        maxw = 12.35,
        minh = 0.58,
        maxh = 0.58,
        scale = 0.42,
        shadow = true,
        focus_args = {type = "none"}
    })
end

local function make_presets_content()
    local rows = {
        {n = G.UIT.R, config = {align = "cl", minw = 13.1307, maxw = 13.1307, minh = 0.58, padding = 0.02}, nodes = {
            {n = G.UIT.T, config = {text = loc("br_tab_presets", "Presets"), scale = 0.42, colour = G.C.EDITION, shadow = true}}
        }}
    }

    for _, preset in ipairs(BR.Presets.list) do
        local preset_help = make_tooltip_node(preset_description(preset))
        local preset_nodes = {
            {n = G.UIT.C, config = {align = "cl", minw = 12.35, maxw = 12.35, padding = 0}, nodes = {
                make_preset_button(preset)
            }}
        }
        if preset_help then
            preset_nodes[#preset_nodes + 1] = {
                n = G.UIT.C,
                config = {align = "cr", minw = 0.50, maxw = 0.50, padding = 0.02},
                nodes = {preset_help}
            }
        end

        rows[#rows + 1] = {
            n = G.UIT.R,
            config = {align = "cl", minw = 13.1307, maxw = 13.1307, minh = 0.58, maxh = 0.58, padding = 0.025},
            nodes = preset_nodes
        }
    end

    return {
        n = G.UIT.ROOT,
        config = {align = "tl", minw = 13.1307, maxw = 13.1307, minh = 6.49, maxh = 6.49, padding = 0.02, r = 0.10, colour = UI.COLORS.panel_inner},
        nodes = rows
    }
end

local function make_content(tab_id)
    local tab = find_tab(tab_id)
    if tab.id == "presets" then
        return make_presets_content()
    end
    local rows = {}
    local title = loc("br_title_" .. tab.id, display_label(tab) .. " " .. loc("br_randomization_suffix", "randomization"))

    rows[#rows + 1] = {
        n = G.UIT.R,
        config = {align = "tl", minw = 13.1307, maxw = 13.1307, minh = 0.58, padding = 0.06},
        nodes = {
            {n = G.UIT.T, config = {
                text = title,
                scale = 0.42,
                colour = G.C.EDITION,
                shadow = true
            }}
        }
    }

    if tab.placeholder then
        rows[#rows + 1] = {
            n = G.UIT.R,
            config = {align = "cl", minw = 13.1307, maxw = 13.1307, minh = 3.5, padding = 0.18},
            nodes = {
                {n = G.UIT.T, config = {
                    text = loc("br_presets_placeholder", "Presets will be available in the next configuration UI stage."),
                    scale = 0.36,
                    colour = UI.COLORS.text_dim
                }}
            }
        }
    elseif #tab.parameters == 0 then
        rows[#rows + 1] = {
            n = G.UIT.R,
            config = {align = "cl", minw = 13.1307, maxw = 13.1307, minh = 3.5, padding = 0.18},
            nodes = {
                {n = G.UIT.T, config = {
                    text = loc("br_no_parameters", "No parameters."),
                    scale = 0.36,
                    colour = UI.COLORS.text_dim
                }}
            }
        }
    else
        for index, parameter in ipairs(tab.parameters) do
            rows[#rows + 1] = make_parameter_row(tab, parameter)
            if index < #tab.parameters then
                rows[#rows + 1] = make_vertical_gap(13.1307)
            end
        end
    end

    return {
        n = G.UIT.ROOT,
        config = {
            align = "tl",
            minw = 13.1307,
            maxw = 13.1307,
            minh = 6.49,
            maxh = 6.49,
            padding = 0.02,
            r = 0.10,
            colour = UI.COLORS.panel_inner
        },
        nodes = rows
    }
end

UI.make_content = make_content

local function refresh_content(e)
    local selected = e.config.tab_id or (e.config.ref_table and e.config.ref_table.tab_id)
    UI.active_tab = selected

    local content_wrap = e.UIBox:get_UIE_by_ID("brnd_tab_content")
    if content_wrap and content_wrap.config.object then
        content_wrap.config.object:remove()
    end

    if content_wrap then
        content_wrap.config.object = UIBox({
            definition = make_content(selected),
            config = {
                offset = {x = 0, y = 0},
                align = "cm",
                parent = content_wrap
            }
        })
    end

    for _, tab in ipairs(UI.tabs) do
        local button = e.UIBox:get_UIE_by_ID("brnd_tab_" .. tab.id)
        if button then
            button.config.chosen = tab.id == selected and 'vert' or nil
            button.config.colour = tab.id == selected and UI.COLORS.tab_active or UI.COLORS.tab
        end
    end

    UI.active_preset = detect_active_preset() or UI.active_preset
    for _, preset in ipairs((BR.Presets and BR.Presets.list) or {}) do
        local button = e.UIBox:get_UIE_by_ID("brnd_preset_" .. preset.id)
        if button then
            button.config.colour = preset.id == UI.active_preset and UI.COLORS.preset_active or UI.COLORS.tab
        end
    end

    if content_wrap and content_wrap.config.object then
        content_wrap.config.object:recalculate()
    end
end

UI.refresh_content = function(tab_id)
    local overlay = G and G.OVERLAY_MENU
    if not overlay then return end
    local content_wrap = overlay:get_UIE_by_ID("brnd_tab_content")
    if not content_wrap then return end

    if content_wrap.config.object then content_wrap.config.object:remove() end
    content_wrap.config.object = UIBox({
        definition = make_content(tab_id),
        config = {offset = {x = 0, y = 0}, align = "cm", parent = content_wrap}
    })
    UI.active_preset = detect_active_preset()
    for _, preset in ipairs((BR.Presets and BR.Presets.list) or {}) do
        local button = overlay:get_UIE_by_ID("brnd_preset_" .. preset.id)
        if button then
            button.config.colour = preset.id == UI.active_preset and UI.COLORS.preset_active or UI.COLORS.tab
        end
    end
    if content_wrap.config.object then
        content_wrap.config.object:recalculate()
    end
end

G.FUNCS.brnd_select_tab = refresh_content

local function make_tab_button(tab)

    return UIBox_button({
        id = "brnd_tab_" .. tab.id,
        button = "brnd_select_tab",
        label = {display_label(tab)},
        ref_table = {tab_id = tab.id},
        choice = true,
        chosen = tab.id == UI.active_tab and 'vert' or nil,
        colour = tab.id == UI.active_tab and UI.COLORS.tab_active or UI.COLORS.tab,
        minw = 3.40,
        maxw = 3.40,
        minh = 0.58,
        maxh = 0.58,
        scale = 0.42,
        shadow = true,
        focus_args = {type = "none"}
    })
end

function UI.config_tab()
    UI.active_preset = detect_active_preset()
    find_tab(UI.active_tab)

    local tab_buttons = {}
    for _, tab in ipairs(UI.tabs) do
        tab_buttons[#tab_buttons + 1] = make_tab_button(tab)
    end

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            minw = 17.6088,
            maxw = 17.6088,
            minh = 7.20,
            padding = 0.14,
            r = 0.10,
            colour = UI.COLORS.panel
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", minw = 17.166, maxw = 17.166, minh = 6.75, padding = 0},
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "tm",
                            minw = 3.58,
                            maxw = 3.58,
                            minh = 6.65,
                            padding = 0.07
                        },
                        nodes = tab_buttons
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            align = "tm",
                            minw = 13.401,
                            maxw = 13.401,
                            minh = 6.65,
                            maxh = 6.65,
                            padding = 0.08,
                            r = 0.10,
                            colour = UI.COLORS.panel_inner
                        },
                        nodes = {
                            {
                                n = G.UIT.O,
                                config = {
                                    id = "brnd_tab_content",
                                    minw = 13.1307,
                                    maxw = 13.1307,
                                    object = UIBox({
                                        definition = make_content(UI.active_tab),
                                        config = {offset = {x = 0, y = 0}}
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end
