stats = {}
local sep = package.path:match('(%p)%?%.')
local logpath = minetest.get_worldpath() .. sep .. 'stats.log'
local data = {}

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- LOCAL FUNCTIONS
local function set_data()
    data = {
        nicks = {}, ips = {}, times = {}, news = {}, start = os.time()
    }
end

local function contains(arr, value)
    for k, v in pairs(arr) do
        if v == value then return true end
    end
    return false
end

local function load_data()
    data = mod_configs.load_json('stats', 'data')
    if data then
        local t = os.time()
        for name in pairs(data.times) do
            data.times[name].all = data.times[name].all + (t - data.times[name].join)
        end
    else set_data() end
end
load_data()

local function save_data()
    mod_configs.save_json('stats', 'data', data)
end

local function get_online()
    local len = 0
    local time = 0
    for key, value in pairs(data.times) do
        time = time + value.all
        len = len + 1
    end
    return time / len
end

local function write_log()
    local log = io.open(logpath, 'a')
    log:write(os.date('========== [%Y-%m-%d %X] ==========') .. '\n')
    log:write(S('PER LAST 24 HOURS') .. '\n')
    log:write(S('Total nicks -> %d'):format(#data.nicks) .. '\n')
    log:write(S('Total IPs -> %d'):format(#data.ips) .. '\n')
    log:write(S('Newbies -> %d'):format(#data.news) .. '\n')
    log:write(S('Average online seconds -> %d'):format(get_online()) .. '\n')
    log:flush()
    log:close()
end

local function tick()
    if os.time() - data.start >= 86400 then
        write_log()
        set_data()
    end
    minetest.after(1, tick)
end
minetest.after(1, tick)

local function send_info(name)
    minetest.chat_send_player(name, S('======= STATISTIC ======='))
    minetest.chat_send_player(name, S('Total nicks -> %d'):format(#data.nicks))
    minetest.chat_send_player(name, S('Total IPs -> %d'):format(#data.ips))
    minetest.chat_send_player(name, S('Newbies -> %d'):format(#data.news))
    minetest.chat_send_player(name, S('Average online seconds -> %d'):format(get_online()))
end

-- API
function stats.get_stat()
    local result = {}
    result.nicks = #data.nicks
    result.ips = #data.ips
    result.newbies = #data.news
    result.online = get_online()
    return result
end

-- EVENTS
minetest.register_on_newplayer(function(player)
    table.insert(data.news, player:get_player_name())
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local ip = minetest.get_player_ip(name)
    if not contains(data.nicks, name) then
        table.insert(data.nicks, name)
    end
    if not contains(data.ips, ip) then
        table.insert(data.ips, ip)
    end
    if not data.times[name] then
        data.times[name] = {all = 0, join = os.time()}
    else
        data.times[name].join = os.time()
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    data.times[name].all = data.times[name].all + (os.time() - data.times[name].join)
end)

minetest.register_on_shutdown(function()
    save_data()
end)

-- REGISTRATIONS
minetest.register_privilege('showstat', S('Can use /stat'))

-- COMMANDS
minetest.register_chatcommand('stat', {
    params = 'none',
    description = S('show statistic'),
    privs = {showstat = true},
    func = function(name, params)
        send_info(name)
        return true, S('======= /STATISTIC =======')
    end,
})
