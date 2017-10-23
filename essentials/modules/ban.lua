local S = essentials._initlib

-- API PART
function essentials.ban(player_name, baner, reason)
    if not essentials.__ban then essentials.__ban = {} end
    essentials.__ban[player_name] = minetest.parse_json('{"baner":"' .. baner .. '","reason":"' .. reason .. '"}')
    mod_configs.save_json('essentials', 'ban', essentials.__ban)
end

function essentials.unban(player_name)
    if not essentials.__ban or not essentials.__ban[player_name] then return false end
    essentials.__ban[player_name] = nil
    mod_configs.save_json('essentials', 'ban', essentials.__ban)
    return true
end

function essentials.tempban(player_name, baner, time, reason)
    if not essentials.__ban then essentials.__ban = {} end
    essentials.__ban[player_name] = minetest.parse_json('{"baner":"' .. baner .. '","reason":"' .. reason .. '","time":' .. time .. '}')
    mod_configs.save_json('essentials', 'ban', essentials.__ban)
end

function essentials.get_ban_info(player_name)
    if not essentials.__ban or not essentials.__ban[player_name] then return nil end
    return essentials.__ban[player_name]
end

function essentials.is_banned(player_name)
    local info = essentials.get_ban_info(player_name)
    if not info then return false end
    if info.time then
        if info.time > os.time() then return true
        else essentials.unban(player_name) end
    end
    return false
end

function essentials.banip(ip, baner, reason)
    if not essentials.__banip then essentials.__banip = {} end
    essentials.__banip[ip] = minetest.parse_json('{"baner":"' .. baner .. '","reason":"' .. reason .. '"}')
    mod_configs.save_json('essentials', 'banip', essentials.__banip)
end

function essentials.unbanip(ip)
    if not essentials.__banip or not essentials.__banip[ip] then return false end
    essentials.__banip[ip] = nil
    mod_configs.save_json('essentials', 'banip', essentials.__banip)
    return true
end

function essentials.tempbanip(ip, baner, time, reason)
    if not essentials.__banip then essentials.__banip = {} end
    essentials.__banip[ip] = minetest.parse_json('{"baner":"' .. baner .. '","reason":"' .. reason .. '","time":' .. time .. '}')
    mod_configs.save_json('essentials', 'banip', essentials.__banip)
end

function essentials.get_banip_info(ip)
    if not essentials.__banip or not essentials.__banip[ip] then return nil end
    return essentials.__banip[ip]
end

function essentials.is_bannedip(ip)
    local info = essentials.get_banip_info(ip)
    if not info then return false end
    if info.time then
        if info.time > os.time() then return true
        else essentials.unbanip(ip) end
    end
    return false
end

-- LOCAL FUNCTIONS
local function banlog(str)
    local mess = os.date('[%Y-%m-%d %X]: ') .. str
    local log = io.open(essentials.__path_banlog, 'a')
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
        if minetest.check_player_privs(name, {ebansee=true}) then
            minetest.chat_send_player(name, str)
        end
    end
end

-- EVENTS
minetest.register_on_prejoinplayer(function(name, ip)
    if essentials.is_banned(name) then
        local info = essentials.get_ban_info(name)
        if info.time then
            local prefix, ctime = essentials.get_time(info.time)
            return S('You banned %s (%s). Please wait %d %s'):format(info.baner, info.reason, ctime, S(prefix))
        else
            return S('You banned %s (%s).'):format(info.baner, info.reason)
        end
    elseif essentials.is_bannedip(ip) then
        local info = essentials.get_banip_info(ip)
        if info.time then
            local prefix, ctime = essentials.get_time(info.time)
            return S('You ip banned %s (%s). Please wait %d %s'):format(info.baner, info.reason, ctime, S(prefix))
        else
            return S('You ip banned %s (%s).'):format(info.baner, info.reason)
        end
    end
end)

-- COMMANDS
minetest.register_chatcommand('eban', {
    params = '<player> <reason>',
    description = S('ban player'),
    privs = {eban = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not reason') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if minetest.check_player_privs(name, {exeban=true}) then
            return false, S('%s exempted of ban'):format(params[1])
        end
        essentials.ban(params[1]:trim(), name, params[2])
        banlog(S('%s banned %s (%s))'):format(name, params[1], params[2]))
        sendmess(S('%s banned %s (%s)'):format(name, params[1], params[2]))
        if player:is_player_connecetd(params[1]:trim()) then
            minetest.kick_player(params[1]:trim(), S('You banned %s (%s)'):format(name, params[2]))
        end
        return true, S('%s banned'):fromat(params[1])
    end,
})

minetest.register_chatcommand('eunban', {
    params = '<player>',
    description = S('unban player'),
    privs = {eban = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local result = essentials.unban(params)
        if not result then return false, S('%s not banned'):format(params) end
        banlog(S('%s unbanned %s'):format(name, params))
        sendmess(S('%s unbanned %s'):format(name, params))
        return true, S('%s unbanned'):format(params)
    end,
})

minetest.register_chatcommand('etempban', {
    params = '<player> <time> <reason>',
    description = S('temp ban player'),
    privs = {etempban = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not time') end
        if #params < 3 then return false, S('invalid command, not reason') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if minetest.check_player_privs(name, {exban=true}) then
            return false, S('%s exempted of ban'):format(params[1])
        end
        local time = essentials.parse_time(params[2]:trim())
        if not time then return false, S('bad command, incorrect time format') end
        essentials.tempban(params[1]:trim(), name, time + os.time(), params[3])
        local prefix, ctime = essentials.get_time(time)
        banlog(S('%s temp banned %s (%s) on %d %s)'):format(name, params[1], params[3], ctime, S(prefix)))
        sendmess(S('%s temp banned %s (%s) on %d %s)'):format(name, params[1], params[3], ctime, S(prefix)))
        if player:is_player_connecetd(params[1]:trim()) then
            minetest.kick_player(params[1]:trim(), S('You temp banned %s (%s) on %d %s'):format(name, params[3], ctime, S(prefix)))
        end
        return true, S('%s temp banned on %d %s'):fromat(params[1], ctime, S(prefix))
    end,
})

minetest.register_chatcommand('ebanip', {
    params = '<ip> <reason>',
    description = S('ban ip'),
    privs = {ebanip = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not ip') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not ip') end
        if #params < 2 then return false, S('invalid command, not reason') end
        local players = minetest.get_connected_players()
        for _,player in ipairs(players) do
            local pname = player:get_player_name()
            if minetest.get_player_ip(pname) == params[1]:trim() and minetest.check_player_privs(pname, {exeban=true}) then
                return false, S('%s exempted of ban'):format(pname)
            else
                minetest.kick_player(pname, S('You ip banned %s (%s)'):format(name, params[2]))
            end
        end
        essentials.banip(params[1]:trim(), name, params[2])
        banlog(S('%s banned ip %s (%s))'):format(name, params[1], params[2]))
        sendmess(S('%s banned ip %s (%s)'):format(name, params[1], params[2]))
        return true, S('ip %s banned'):fromat(params[1])
    end,
})

minetest.register_chatcommand('eunbanip', {
    params = '<ip>',
    description = S('unban ip'),
    privs = {ebanip = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not ip') end
        local result = essentials.unbanip(params)
        if not result then return false, S('ip %s not banned'):format(params) end
        banlog(S('ip %s unbanned %s'):format(name, params))
        sendmess(S('ip %s unbanned %s'):format(name, params))
        return true, S('ip %s unbanned'):format(params)
    end,
})

minetest.register_chatcommand('etempbanip', {
    params = '<ip> <time> <ip>',
    description = S('temp ban player'),
    privs = {etempbanip = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not ip') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not time') end
        if #params < 3 then return false, S('invalid command, not reason') end
        local time = essentials.parse_time(params[2]:trim())
        if not time then return false, S('bad command, incorrect time format') end
        local prefix, ctime = essentials.get_time(time)
        local players = minetest.get_connected_players()
        for _,player in ipairs(players) do
            local pname = player:get_player_name()
            if minetest.get_player_ip(pname) == params[1]:trim() and minetest.check_player_privs(pname, {exeban=true}) then
                return false, S('%s exempted of ban'):format(pname)
            else
                minetest.kick_player(pname, S('You ip temp banned %s (%s) on %d %t'):format(name, params[2], ctime, S(prefix)))
            end
        end
        essentials.tempbanip(params[1]:trim(), name, time + os.time(), params[3])
        banlog(S('%s temp banned ip %s (%s) on %d %s)'):format(name, params[1], params[2], ctime, S(prefix)))
        sendmess(S('%s temp banned ip %s (%s) on %d %s)'):format(name, params[1], params[3], ctime, S(prefix)))
        return true, S('ip %s temp banned on %d %s'):fromat(params[1], ctime, S(prefix))
    end,
})

minetest.register_chatcommand('eibanip', {
    params = '<ip>',
    description = S('show ip ban info'),
    privs = {eibanip = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not ip') end
        if not essentials.is_bannedip(params) then return false, S('ip %s is not banned') end
        local info = essentials.get_banip_info(params)
        local result = ''
        if info.time then result = S('Baner: %s\nReason: %s\nEnd date: %s'):format(info.baner, info.reason, os.date('%Y-%m-%d %X', info.time))
        else result = S('Baner: %s\nReason: %s'):format(info.baner, info.reason) end
        return true, result
    end,
})
