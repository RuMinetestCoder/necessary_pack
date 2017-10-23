local effil = require 'effil'
local thread = nil
local tsync = effil.table({stop = false, data = ''})
local settings = {}

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- LOCAL FUNCTIONS
local function load_settings()
    settings = mod_configs.get_conf('query', 'settings')
    if not settings then
        settings = {
            general = {
                enabled = true,
                host = '0.0.0.0',
                port = 20500
            },
            info = {
                status = true, uptime = true, time = true, days = true, gametime = true, players = true, slots = true
            }
        }
        mod_configs.save_conf('query', 'settings', settings)
    end
end
load_settings()

local function get_players()
    local result = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        table.insert(result, player:get_player_name())
    end
    return result
end

local function tick()
    local data = {}
    if settings.info.status then data.status = minetest.get_server_status() end
    if settings.info.uptime then data.uptime = minetest.get_server_uptime() end
    if settings.info.time then data.time = minetest.get_timeofday() end
    if settings.info.days then data.days = minetest.get_day_count() end
    if settings.info.gametime then data.gametime = minetest.get_gametime() end
    if settings.info.players then data.players = get_players() end
    if settings.info.slots then data.slots = minetest.setting_get('max_users') end
    tsync.data = minetest.write_json(data)
    if not tsync.stop then minetest.after(1, tick) end
end
minetest.after(1, tick)

local function loop(t, host, port)
    local socket = require 'socket'
    local s = nil
    if not pcall(function() s = assert(socket.bind(host, port)) end) then return end
    s:settimeout(1)
    while s and not t.stop do
        pcall(function()
            local c = nil
            local r, err = pcall(function() c = assert(s:accept()) end)
            if r and c then
                c:settimeout(1)
                c:send(t.data .. '\r\n')
                c:close()
            end
        end)
    end
end

local function start()
    tsync.stop = false
    minetest.after(1, tick)
    local runner = effil.thread(loop)
    thread = runner(tsync, settings.general.host, settings.general.port)
end

local function stop()
    tsync.stop = true
end

if settings.general.enabled then
    start()
end

-- EVENTS
minetest.register_on_shutdown(function()
    stop()
end)

-- REGISTRATION PRIVS
minetest.register_privilege('queryadm', S('For access to admin commands query'))

-- COMMANDS
minetest.register_chatcommand('querystart', {
    params = 'none',
    description = S('start query'),
    privs = {queryadm = true},
    func = function(name, params)
        local status, err = thread:status()
        if status == 'running' then return false, S('query already started') end
        start()
        return true, S('query started')
    end,
})

minetest.register_chatcommand('querystop', {
    params = 'none',
    description = S('stop query'),
    privs = {queryadm = true},
    func = function(name, params)
        local status, err = thread:status()
        if status == 'running' then
            stop()
            return true, S('query stopped')
        else return false, S('query already stopped') end
    end,
})

minetest.register_chatcommand('queryreload', {
    params = 'none',
    description = S('reload settings from config file'),
    privs = {queryadm = true},
    func = function(name, params)
        load_settings()
        return true, S('settings reloaded')
    end,
})
