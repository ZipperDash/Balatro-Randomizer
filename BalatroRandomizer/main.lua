local mod = SMODS.current_mod

BR = BR or {}
BR.mod = mod
BR.version = mod.version or "1.1.2"

mod.process_loc_text = function()
    if not G or not G.localization or not G.localization.descriptions then return end

    local keys = {
        c_talisman = {set = "Spectral", count = 1},
        c_aura = {set = "Spectral", count = 1},
        c_deja_vu = {set = "Spectral", count = 1},
        c_trance = {set = "Spectral", count = 1},
        c_medium = {set = "Spectral", count = 1},
        c_magician = {set = "Tarot", count = 2},
        c_empress = {set = "Tarot", count = 2},
        c_hierophant = {set = "Tarot", count = 2},
        c_lovers = {set = "Tarot", count = 1},
        c_chariot = {set = "Tarot", count = 1},
        c_justice = {set = "Tarot", count = 1},
        c_strength = {set = "Tarot", count = 2},
        c_hanged_man = {set = "Tarot", count = 2},
        c_devil = {set = "Tarot", count = 1},
        c_tower = {set = "Tarot", count = 1},
        c_star = {set = "Tarot", count = 3},
        c_moon = {set = "Tarot", count = 3},
        c_sun = {set = "Tarot", count = 3},
        c_world = {set = "Tarot", count = 3}
    }

    for key, data in pairs(keys) do
        local descriptions = G.localization.descriptions[data.set]
        local entry = descriptions and descriptions[key]
        if entry and type(entry.text) == "table" then
            for index, line in ipairs(entry.text) do
                if type(line) == "string" then
                    local count = tostring(data.count)
                    local pattern = "(^)" .. count .. "(%D)"
                    local updated, changed = line:gsub(pattern, "#1#%2", 1)
                    if changed == 0 then
                        updated, changed = line:gsub("([^%d#])" .. count .. "(%D)", "%1#1#%2", 1)
                    end
                    if changed == 0 then
                        updated = line:gsub("([^%d#])" .. count .. "$", "%1#1#", 1)
                    end
                    entry.text[index] = updated
                end
            end
        end
    end
end

assert(SMODS.load_file("core/log.lua"))()
BR.Log:init()
assert(SMODS.load_file("core/rng.lua"))()
assert(SMODS.load_file("core/config.lua"))()
BR.Config:sync_defaults()
assert(SMODS.load_file("core/presets.lua"))()
assert(SMODS.load_file("core/ui.lua"))()

SMODS.current_mod.config_tab = function()
    return BR.UI.config_tab()
end

SMODS.current_mod.optional_features = function()
    return {
        object_weights = BR.Config:is_enabled("jokers.spawn_weight.enabled", false) or BR.Config:is_enabled("consumables.spawn_weight.enabled", false),
        retrigger_joker = BR.Config:is_enabled("jokers.activation_repeat.enabled", false)
    }
end
assert(SMODS.load_file("core/state.lua"))()
assert(SMODS.load_file("systems/economy.lua"))()
assert(SMODS.load_file("systems/shop.lua"))()
assert(SMODS.load_file("systems/boosters.lua"))()
assert(SMODS.load_file("systems/player_resources.lua"))()
assert(SMODS.load_file("systems/playing_cards.lua"))()
assert(SMODS.load_file("systems/jokers.lua"))()
assert(SMODS.load_file("systems/vouchers.lua"))()
assert(SMODS.load_file("systems/consumables.lua"))()
assert(SMODS.load_file("systems/planets.lua"))()
assert(SMODS.load_file("systems/spectrals.lua"))()

function mod.reset_game_globals(run_start)
    BR.State:reset(run_start)
end

local blinds_system = assert(SMODS.load_file("systems/blinds.lua"))()
if blinds_system then
    blinds_system:install_hooks()
end
