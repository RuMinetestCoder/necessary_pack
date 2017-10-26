local S = essentials._initlib

--essentials.__mutes = {}

-- API PART
function essentials.mute(player_name, time, muter, reason)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    local t = minetest.parse_json('{"time":' .. tostring(time) .. '"muter":"' .. muter .. '","reason":' .. reason .. '}')
    player:set_attribute('essentials.mute', minetest.write_json(t))
    return true
end

function essentials.unmute(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    player:set_attribute('essentials.mute', nil)
    return true
end

function essentials.get_mute_info(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return nil end
    local data = player:get_attribute('essentials.mute')
    if not data then return nil end
    local json = minetest.parse_json(data)
    if not json or not json.time then return nil end
    return json
end

function essentials.is_muted(player_name)
    local info = essentials.get_mute_info(player_name)
    if not info then return false end
    if tonumber(info.time) > os.time() then return true end
    return false
end

-- LOCAL FUNCTIONS
local function mutelog(str)
    local mess = os.date('[%Y-%m-%d %X]: ') .. str
    local log = io.open(essentials.__path_mutelog, 'a')
    log:write(mess .. '\n')
    log:flush()
    log:close()
    minetest.log('action', str)
end

local function sendmess(str)
    local players = minetest.get_connected_players()
    if not players or #players == 0 then return false end -- lol
    for _,player in ipairs(players) do
        local name = player:get_player_name()
        if minetest.check_player_privs(name, {mutesee=true}) then
            minetest.chat_send_player(name, str)
        end
    end
end

-- EVENTS
minetest.register_on_chat_message(function(name, message)
    if essentials.is_muted(name) then
        local info = essentials.get_mute_info(name)
        essentials.__mutes[message] = name
        local prefix, ctime = essentials.get_time(info.time)
        minetest.chat_send_player(name, S('you muted %s (%s), please wait %d %s'):format(info.muter, info.reason, ctime, S(prefix)))
        return true
    end
end)

-- COMMANDS
minetest.register_chatcommand('mute', {
    params = '<player> <time> <reason>',
    description = S('mute player'),
    privs = {mute = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not time') end
        if #params < 3 then return false, S('invalid command, not reason') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if minetest.check_player_privs(name, {exmute=true}) then
            return false, S('%s exempted of mute'):format(params[1])
        end
        local time = essentials.parse_time(params[2]:trim())
        if not time then return false, S('bad command, incorrect time format') end
        essentials.mute(params[1]:trim(), time + os.time(), name, params[3])
        local prefix, ctime = essentials.get_time(time)
        mutelog(S('%s muted %s on %d %s (%d seconds) (%s)'):format(name, params[1], ctime, S(prefix), time, params[3]))
        if player:is_player_connecetd(params[1]:trim()) then
            minetest.chat_send_player(params[1]:trim(), S('you mutted %s on %d %s (%s)'):format(name, ctime, S(prefix), params[3]))
        end
        sendmess(S('%s muted %s on %d %s (%s)'):format(name, params[1], ctime, S(prefix), params[3]))
        return true, S('%s muted on %d %s'):fromat(params[1], ctime, S(prefix))
    end,
})

minetest.register_chatcommand('unmute', {
    params = '<player>',
    description = S('unmute player'),
    privs = {mute = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        essentials.unmute(name)
        mutelog(S('%s unmuted %s'):format(name, params))
        if player:is_player_connecetd(params) then
            minetest.chat_send_player(params, S('you unmuted %s)'):format(name))
        end
        sendmess(S('%s unmuted %s'):format(name, params))
        return true, S('%s unmuted'):format(params)
    end,
})
