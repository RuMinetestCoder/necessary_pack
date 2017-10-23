local S = essentials._initlib

-- LOCAL FUNCTIONS
local function get_string_whois(player_name)
    if not minetest.player_exists(player_name) then return nil end
    local info = minetest.get_player_information(player_name)
    local result = 'IP: %s\nIP VERSION: %d\nmin_rtt: %d\nmax_rtt: %d\navg_rtt: %d\nmin_jitter: %d\nmax_jitter: %d\navg_jitter: %d\n'
    result = result .. 'UPTIME: %d %s\nFirst join: %s\nLast join: %s\nMuted: %s\nBanned: %s\nVanished: %s'
    local fjoin = os.date('%Y-%m-%d %X', essentials.get_first_join(player_name))
    local ljoin = os.date('%Y-%m-%d %X', essentials.get_last_join(player_name))
    local muted = ''
    local banned = ''
    if essentials.is_muted(player_name) then
        local pinfo = essentials.get_mute_info(player_name)
        if pinfo.time then
            local prefix, ctime = essentials.get_time(pinfo.time)
            muted = S('true (%s) on %d %s (%s)'):format(pinfo.reason, ctime, S(prefix), pinfo.muter)
        else muted = S('true (%s / %s)'):format(pinfo.reason, pinfo.muter) end
    else muted = S('false') end
    if essentials.is_banned(player_name) then
        local pinfo = essentials.get_ban_info(player_name)
        if pinfo.time then
            local prefix, ctime = essentials.get_time(pinfo.time)
            banned = S('true (%s) on %d %s (%s)'):format(pinfo.reason, ctime, S(prefix), pinfo.baner)
        else banned = S('true (%s / %s)'):format(pinfo.reason, pinfo.baner) end
    else banned = S('false') end
    local vanished = S(essentials.is_vanished(player_name))
    local prefix, ctime = essentials.get_time(info.connection_uptime)
    return result:format(info.address, info.ip_version, info.min_rtt, info.max_rtt, info.avg_rtt, info.min_jitter, info.max_jitter,
                        info.avg_jitter, ctime, S(prefix), fjoin, ljoin, muted, banned, vanished)
end

-- API PART
function essentials.get_first_join(player_name)
   local player = minetest.get_player_by_name(player_name)
   if not player then return 0 end
   local time = player:get_attribute('essentials.firstjoin')
   if time then time = tonumber(time) else return 0 end
   return time
end

function essentials.get_last_join(player_name)
   local player = minetest.get_player_by_name(player_name)
   if not player then return 0 end
   local time = player:get_attribute('essentials.lastjoin')
   if time then time = tonumber(time) else return 0 end
   return time
end

function essentials.get_string_whois(player_name)
    local status, data = pcall(get_string_whois(player_name))
    if status then return data end
    return nil
end

-- EVENTS
minetest.register_on_joinplayer(function(player)
    player:set_attribute('essentials.lastjoin', os.time())
end)

minetest.register_on_newplayer(function(player)
    player:set_attribute('essentials.firstjoin', os.time())
end)

-- COMMANDS
minetest.register_chatcommand('whois', {
    params = '<player>',
    description = S('show info of player'),
    privs = {whois = true},
    func = function(name, params)
        if not minetest.player_exists(params) then return false, S('player not found'):format(params) end
        if minetest.check_player_privs(params, {exwhois=true}) then return false, S('%s exempted whois'):format(params) end
        local data = essentials.get_string_whois(params)
        if not data then return false, S('error') end
        return true, data
    end,
})
