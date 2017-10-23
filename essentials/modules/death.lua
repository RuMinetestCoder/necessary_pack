local S = essentials._initlib

-- EVENTS
minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    local strpos = minetest.pos_to_string(player:getpos())
    minetest.log('action', S('%s died from %s'):format(player_name, strpos))
    if not minetest.check_player_privs(player_name, {deathpos=true}) then return end
    minetest.chat_send_player(player_name, S('You died from %d'):format(strpos))
end)
