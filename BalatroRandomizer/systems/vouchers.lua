BR.Vouchers = BR.Vouchers or {}

function BR.Vouchers:apply_center_costs()
    if not BR.State.initialized or not BR.State.config or not BR.State.config.vouchers then return end
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Voucher then return end

    for _, center in ipairs(G.P_CENTER_POOLS.Voucher) do
        if center and center.key then
            if center._br_original_cost == nil then
                center._br_original_cost = center.cost or 10
            end
            local voucher_config = BR.State.config.vouchers[center.key]
            if voucher_config and voucher_config.buy_cost ~= nil then
                center.cost = voucher_config.buy_cost
            else
                center.cost = center._br_original_cost
            end
        end
    end
end

function BR.Vouchers:restore_center_costs()
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Voucher then return end

    for _, center in ipairs(G.P_CENTER_POOLS.Voucher) do
        if center and center._br_original_cost ~= nil then
            center.cost = center._br_original_cost
        end
    end
end

function BR.Vouchers:apply_order_mode()
    if not BR.State.initialized or not BR.State.config or not BR.State.config.voucher_order then return end
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Voucher then return end

    if not BR.State.config.voucher_order then
        return
    end

    local changed = 0
    for _, center in ipairs(G.P_CENTER_POOLS.Voucher) do
        if center and center.key then
            if center._br_original_requires == nil then
                if center.requires == nil then
                    center._br_original_requires = false
                else
                    local copy = {}
                    for index, key in ipairs(center.requires) do
                        copy[index] = key
                    end
                    center._br_original_requires = copy
                end
            end
            if center.requires ~= nil then
                center.requires = nil
                changed = changed + 1
            end
        end
    end

    if BR.Config:is_enabled("debug.enabled", false) then
        BR.Log:info(string.format("Voucher order mode applied | removed requirements from %d vouchers", changed))
    end
end

function BR.Vouchers:restore_order_mode()
    if not G or not G.P_CENTER_POOLS or not G.P_CENTER_POOLS.Voucher then return end

    for _, center in ipairs(G.P_CENTER_POOLS.Voucher) do
        if center and center._br_original_requires ~= nil then
            if center._br_original_requires == false then
                center.requires = nil
            else
                local copy = {}
                for index, key in ipairs(center._br_original_requires) do
                    copy[index] = key
                end
                center.requires = copy
            end
        end
    end
end

local previous_new_run = BR.State.new_run

function BR.State:new_run(run_start)
    BR.Vouchers:restore_center_costs()
    BR.Vouchers:restore_order_mode()
    previous_new_run(self, run_start)
    if run_start then
        BR.Vouchers:apply_center_costs()
        BR.Vouchers:apply_order_mode()
    end
end
