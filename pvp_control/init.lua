pvp_control = {}
local settings = {}
local waiters = {}
local nopvp = {}
local cuboids = {}
local news = {}

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- API
function pvp_control.is_pvp(player_name)
    if nopvp[player_name] then return false end
    return true
end

function pvp_control.is_wait(player_name)
    if waiters[player_name] and settings.general.wait > os.time() - waiters[player_name] then return true end
    return false
end

function pvp_control.is_newbie_protect(player_name)
    if news[player_name] and settings.general.newbie > os.time() - news[player_name] then return true end
    return false
end

function pvp_control.toggle_pvp(player_name)
    if not nopvp[player_name] then
        nopvp[player_name] = true
        return false
    else
        nopvp[player_name] = nil
        return true
    end
end

function pvp_control.add_cuboid(name, cube, wait, pvp_mode)
    cuboids[name] = {}
    cuboids[name]['name'] = name
    cuboids[name]['cube'] = cube
    cuboids[name]['wait'] = wait
    cuboids[name].mode = pvp_mode
end

function pvp_control.del_cuboid(name)
    cuboids[name] = nil
end

-- LOAD SETTINGS
local function load_settings()
    settings = mod_configs.get_conf('pvp_control', 'settings')
    if not settings then
        settings = {
            general = {
                pvp = true, wait = 10, newbie = 600, no_area = true, log = true
            }
        }
        mod_configs.save_conf('pvp_control', 'settings', settings)
    end
end
load_settings()

-- LOCAL FUNCTIONS
local function get_cube(pos)
    for key, value in pairs(cuboids) do
        if cuboids_lib.contains(value.cube, pos) then return value end
    end
    return nil
end

local function is_empty(t)
    for k, v in pairs(t) do
        if k or v then return true end
    end
    return false
end

-- REGISTRATIONS
minetest.register_privilege('pvpnw', S('For no wait to exit'))
minetest.register_privilege('pvptoggle', S('Can use /pvp'))
minetest.register_privilege('opvptoggle', S('Can use /opvp'))
minetest.register_privilege('pvpon', S('Can use /pvpon'))
minetest.register_privilege('opvpon', S('Can use /opvpon'))
minetest.register_privilege('pvpi', S('Can use /pvpi'))

-- EVENTS
minetest.register_on_newplayer(function(player)
    if settings.general.newbie > 0 then news[player:get_player_name()] = os.time() end
end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    local cube = get_cube(player:getpos())
    if ((waiters[player_name] and settings.general.wait > os.time() - waiters[player_name]) and
        ((cube and cube.wait and cube.pvp_mode) or not cube) and
        not minetest.check_player_privs(player_name, {pvpnw=true})) then
        minetest.chat_send_player(player_name, S('O NO, LEVE IN PVP! YOU DEATH!'))
        player:set_hp(0)
        if settings.general.log then minetest.log('action', S('%s leave in pvp, die'):format(player_name)) end
    end
    waiters[player_name] = nil
    nopvp[player_name] = nil
    news[player_name] = nil
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, pos, damage)
    if not player:is_player() or not hitter:is_player() then return end
    local pname = player:get_player_name()
    local hname = player:get_player_name()
    if nopvp[pname] then
        minetest.chat_send_player(hname, S('%s pvp is off'):format(pname))
        return true
    end
    if pvp_control.is_newbie_protect(pname) then
        minetest.chat_send_player(hname, S('%s is newbie, pvp delay'))
        return true
    end
    local cube = get_cube(pos)
    if cube and not cube.pvp_mode then
        minetest.chat_send_player(hname, S('pvp not allowed in this cuboid'))
        return true
    end
    if settings.general.no_area and minetest.global_exists('gui_menu') and not is_empty(areas:getAreasAtPos(pos)) then
        minetest.chat_send_player(hname, S('pvp not allowed in area'))
        return true
    end
    if not settings.general.pvp and (not cube or not cube.pvp_mode) then
        --minetest.chat_send_player(hname, S('pvp is disallow'))
        return true
    end
    waiters[pname] = os.time()
end)

-- COMMANDS
minetest.register_chatcommand('pvp', {
    params = 'none',
    description = S('toggle pvp mode'),
    privs = {pvptoggle = true},
    func = function(name, params)
        if pvp_control.toggle_pvp(name) then return true, S('pvp on')
        else return true, S('pvp off') end
    end,
})

minetest.register_chatcommand('opvp', {
    params = '<player>',
    description = S('toggle player pvp mode'),
    privs = {opvptoggle = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return false, S('%s not exists'):format(params) end
        if not minetest.get_player_by_name(params):is_player_connected() then return false, S('%s not online'):format(paramd) end
        if pvp_control.toggle_pvp(name) then
            minetest.chat_send_player(params, S('pvp on'))
            return true, S('%s pvp on'):format(params)
        else
            minetest.chat_send_player(params, S('pvp off'))
            return true, S('%s pvp off'):format(params)
        end
    end,
})

minetest.register_chatcommand('pvpon', {
    params = 'none',
    description = S('on pvp, off newbie protection'),
    privs = {pvpon = true},
    func = function(name, params)
        news[name] = nil
        return true, S('pvp on')
    end,
})

minetest.register_chatcommand('opvpon', {
    params = '<player>',
    description = S('on pvp player, off newbie protection'),
    privs = {opvpon = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return false, S('%s not exists'):format(params) end
        if not minetest.get_player_by_name(params):is_player_connected() then return false, S('%s not online'):format(paramd) end
        news[params] = nil
        minetest.chat_send_player(params, S('pvp on'))
        return true, S('%s pvp on'):format(params)
    end,
})

minetest.register_chatcommand('pvpi', {
    params = '<player>',
    description = S('show pvp info'),
    privs = {pvpi = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return false, S('%s not exists'):format(params) end
        if not minetest.get_player_by_name(params):is_player_connected() then return false, S('%s not online'):format(paramd) end
        return true, S('{%s} pvp mode %s, %s wait, %s newbie protect'):format(params, tostring(pvp_control.is_pvp(params)),
                        tostring(pvp_control.is_wait(params)), tostring(pvp_control.is_newbie_protect(params)))
    end,
})
