local S = essentials._initlib

-- COMMANDS
minetest.register_chatcommand('list', {
    params = 'none',
    description = S('get players list'),
    privs = {list = true},
    func = function(name, params)
        local players = minetest.get_connected_players()
        if not players or #players == 0 then return false, S('not online players') end -- lol
        local list = S('Players [%d]'):format(#players) .. ': '
        for _,player in ipairs(players) do
            local pname = player:get_player_name()
            if essentials.is_vanished(pname) then
                if minetest.check_player_privs(pname, {hlist=true}) then
                    pname = S('[HIDE]') .. pname
                end
            end
            if essentials.is_afk(pname) then pname = S('[AFK]') .. pname end
            list = list .. pname .. ', '
        end
        return true, list:sub(0, list:len() - 2)
    end,
})
