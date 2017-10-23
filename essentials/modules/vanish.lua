local S = essentials._initlib
essentials.__vanished = {}

-- API PART
function essentials.is_vanished(player_name)
    if essentials.__vanished[player_name] then return true end
    return false
end

function essentials.toggle_vanish(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    if essentials.is_vanished(player_name) then
        player:set_properties({is_vidible = true})
        essentials.__vanished = false
    else
        player:set_properties({is_vidible = false})
        essentials.__vanished[player_name] = true
    end
    return true
end

-- EVENTS
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if essentials.is_vanished(name) then essentials.toggle_vanish(name) end
    if essentials.__vanished[name] ~= nil then essentials.__vanished[player_name] = nil end
end)

-- COMMANDS
minetest.register_chatcommand('v', {
    params = 'none',
    description = S('toggle you visible'),
    privs = {vanish = true},
    func = function(name, params)
        essentials.toggle_vanish(name)
        if essentials.is_vanished(name) then return true, S('you invisible') end
        return true, S('you visible')
    end,
})

minetest.register_chatcommand('ov', {
    params = '<player>',
    description = S('toggle player visible'),
    privs = {ovanish = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        essentials.toggle_vanish(params)
        if essentials.is_vanished(params) then return true, S('%s invisible'):format(params) end
        return true, S('%s visible'):format(params)
    end,
})
