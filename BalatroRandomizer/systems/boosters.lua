BR.Boosters = BR.Boosters or {}

function BR.Boosters:apply_center_costs()
    if not BR.State.config or not BR.State.config.boosters then return end
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Booster then return end

    for _, center in ipairs(G.P_CENTER_POOLS.Booster) do
        if center and center.key then
            if center._br_original_cost == nil then
                center._br_original_cost = center.cost or 4
            end
            local booster_config = BR.State.config.boosters[center.key]
            if booster_config and booster_config.buy_cost ~= nil then
                center.cost = booster_config.buy_cost
            else
                center.cost = center._br_original_cost
            end
        end
    end
end

function BR.Boosters:restore_center_costs()
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Booster then return end

    for _, center in ipairs(G.P_CENTER_POOLS.Booster) do
        if center and center._br_original_cost ~= nil then
            center.cost = center._br_original_cost
        end
    end
end

local previous_calculate = BR.mod.calculate
function BR.mod.calculate(self, context)
    if previous_calculate then
        local result = previous_calculate(self, context)
        if result ~= nil then return result end
    end

    if context and context.modify_shop_card and context.card and context.card.config and context.card.config.center then
        local center = context.card.config.center
        if center.set == "Booster" then
            local booster_config = BR.State.config and BR.State.config.boosters and BR.State.config.boosters[center.key]
            if booster_config and booster_config.buy_cost ~= nil then
                context.card.base_cost = booster_config.buy_cost
                context.card:set_cost()
            end
        end
    end
end
