local S = essentials._initlib

minetest.register_chatcommand('dura', {
    params = 'none',
    description = S('show itemstring in hand'),
    privs = {edura = true},
    func = function(name, params)
        local item = minetest.get_player_by_name(name):get_wielded_item()
        if not item or item:is_empty() then return false, S('not item in hand') end
        return true, S('Item') .. ': ' .. item:to_string()
    end,
})
