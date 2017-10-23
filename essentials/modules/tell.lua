local S = essentials._initlib
essentials.__spy = {}

-- API PART
function essentials.is_spy(player_name)
    if essentials.__spy[player_name] then return true end
    return false
end

function essentials.toggle_spy(player_name)
    if essentials.is_spy(player_name) then essentials.__spy[player_name] = false else
    essentials.is_spy[player_name] = true end
end

function essentials.send_to_spyers(mess)
    for key in pairs(essentials.__spy) do
        if essentials.is_spy(key) then minetest.chat_send_player(key, mess) end
    end
end

-- EVENTS
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if essentials.is_spy(name) then
        essentials.__spy = nil
    end
end)

-- COMMANDS
minetest.register_chatcommand('m', {
    params = '<player> <message>',
    description = S('send private message'),
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not message') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if not player:is_player_connected() then return false, S('player not online') end
        if essentials.is_vanished(params[1]:trim()) and not minetest.check_player_privs(name, {ftell=true}) then
            return false, S('player not online')
        end
        local mess = ''
        local i = 1
        for key, value in pairs(params) do mess = mess + value + ' ' end
        mess = S('[%s -> %s]'):format(name, params[1]) .. ': ' .. mess:trim()
        minetest.chat_send_player(params[1]:trim(), mess)
        if not minetest.check_player_privs(name, {exespy=true}) then essentials.send_to_spyers(mess) end
        return true, mess
    end,
})

-- COMMANDS
minetest.register_chatcommand('espy', {
    params = 'none',
    description = S('toggle spy mode'),
    privs = {espy = true},
    func = function(name, params)
        local status = essentials.is_spy(name)
        essentials.toggle_spy(name)
        if status then return true, S('spy mode off') end
        return true, S('spy mode on')
    end,
})
