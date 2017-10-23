local S = essentials._initlib

-- COMMANDS
minetest.register_chatcommand('say', {
    params = '<message>',
    description = S('say message'),
    privs = {say = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not message') end
        local players = minetest.get_connected_players()
        if not players or #players == 0 then return false, S('not online players') end -- lol
        local i = 0
        for _,player in ipairs(players) do
            local name = player:get_player_name()
            if minetest.check_player_privs(name, {ssay=true}) then
                minetest.chat_send_player(name, essentials.__settings.say:format(params))
                i = i + 1
            end
        end
        return true, S('message sent from %d players'):format(i)
    end,
})

minetest.register_chatcommand('bro', {
    params = '<message>',
    description = S('broadcast message'),
    privs = {broadcast = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not message') end
        local players = minetest.get_connected_players()
        if not players or #players == 0 then return false, S('not online players') end -- lol
        local i = 0
        for _,player in ipairs(players) do
            local name = player:get_player_name()
            if minetest.check_player_privs(name, {sbroadcast=true}) then
                minetest.chat_send_player(name, essentials.__settings.broadcast:format(params))
                i = i + 1
            end
        end
        return true, S('message sent from %d players'):format(i)
    end,
})
