local S = essentials._initlib

-- EVENTS
minetest.register_on_newplayer(function(player)
    if not essentials.__settings.hello then return end
    local player_name = player:get_player_name()
    local mess = essentials.__settings.hellomess:format(player_name)
    minetest.chat_send_player(player_name, mess)
    for _, p in ipairs(minetest.get_connected_players()) do
        local name = p:get_player_name()
        if minetest.check_player_privs(name, {ehello=true}) then
            minetest.chat_send_player(name, mess)
        end
    end
end)
