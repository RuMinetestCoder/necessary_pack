superchat = {}
local sep = package.path:match('(%p)%?%.')
local modpath = minetest.get_modpath(minetest.get_current_modname())
local path = minetest.get_worldpath() .. sep .. 'superchat.log'
local settings = {}
local channels = {}
local chatters = {}

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
    settings = mod_configs.load_json('superchat', 'settings')
    if not settings then
        settings = {
            format = '[$channel] $prefix $player: $message',
            dchannel = 'Local',
            channels = {
                Local = {
                    rad = 50, glob = false, show = 'L', priv = false
                },
                Global = {
                    rad = 0, glob = true, show = 'G', priv = false
                },
                Spec = {
                    rad = 0, glob = true, show = 'S', priv = true
                }
            },
            prefixes = {
                default = 'Def'
            },
            filters = {
                ips = {'((%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?))'},
                urls = {'%w+://([^/]+)'},
                exclude = {'mysite.ru'},
                swear = {'fuck', 'dumb', 'dick'}
            }
        }
        mod_configs.save_json('superchat', 'settings', settings)
    end
end

load_settings()

local function filter(str)
    for key, value in pairs(settings.filters.swear) do
        str = str:gsub(value, S('[SWEAR]'))
    end
    for key, value in pairs(settings.filters.exclude) do
        if str:match(value) then return str end
    end
    for key, value in pairs(settings.filters.ips) do
        str = str:gsub(value, S('[IP]'))
    end
    for key, value in pairs(settings.filters.urls) do
        str = str:gsub(value, S('[URL]'))
    end
end

local function get_channel(str)
    local str = str:lower()
    for key, value in pairs(settings.channels) do
        if str == key:lower() or str == value.show:lower() then
            return key
        end
    end
    return nil
end

local function format(player_name, channel, mess)
    local result = settings.format
    local ch = ''
    if settings.channels and settings.channels[channel] then
        ch = settings.channels[channel].show
    end
    local prefix = minetest.get_player_by_name(player_name):get_attribute('superchat.prefix')
    result = result:gsub('$channel', ch)
    result = result:gsub('$player', player_name)
    result = result:gsub('$message', mess)
    if prefix then
        result = result:gsub('$prefix', prefix)
    else
        result = result:gsub('$prefix', '')
    end
    return result:trim()
end

local function log(str)
    local mess = os.date('[%Y-%m-%d %X]: ') .. str
    local log = io.open(path, 'a')
    log:write(mess .. '\n')
    log:flush()
    log:close()
    minetest.log('action', mess)
end

-- API
function superchat.get_all_channels()
    if not settings.channels then return {} end
    local result = {}
    for key in pairs(settings.channels) do
        table.insert(result, key)
    end
    return result
end

function superchat.get_virt_channels()
    local result = {}
    for key in pairs(channels) do
        table.insert(result, key)
    end
    return result
end

function superchat.is_exists(ch)
    if settings.channels and settings.channels[ch] then return true end
    return false
end

function superchat.is_virt_exists(ch)
    if channels[ch] then return true end
    return false
end

function superchat.get_player_channels(player_name)
    if not settings.channels then return nil end
    local player = minetest.get_player_by_name(player_name)
    if not player then return nil end
    local result = {}
    for key in pairs(settings.channels) do
        local p = minetest.parse_json('{"superchat.ch.' .. key .. '":true}')
        if not settings.channels[key].priv or minetest.check_player_privs(player_name, p) then
            table.insert(result, key)
        end
    end
    return result
end

function superchat.is_access(player_name, ch)
    if not minetest.player_exists(player_name) then return false end
    if not settings.channels or not settings.channels[ch] then
        if channels[ch] then return true else return false end
    end
    local p = minetest.parse_json('{"superchat.ch.' .. key .. '":true}')
    if minetest.check_player_privs(name, p) then return true end
    return false
end

function superchat.get_player_channel(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return nil end
    if chatters[player_name] then return chatters[player_name] end
    local ch = player:get_attribute('superchat.ch')
    return ch
end

function superchat.send(player_name, channel, mess)
    local fmess = format(player_name, channel, mess)
    for _,player in ipairs(minetest.get_connected_players()) do
	    local name = player:get_player_name()
	    local ch = superchat.get_player_channel(name)
	    if ch == channel then
	        minetest.chat_send_player(name, fmess)
        end
    end
    log(fmess)
end

function superchat.change_channel(player_name, ch)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    if not settings.channels or not settings.channels[ch] then
        if channels[ch] then return true else return false end
    end
    player:set_attribute('superchat.ch', ch)
    return true
end

function superchat.add_channel(name)
    if channels[name] then return false end
    channels[name] = {}
end

function superchat.del_channel(name)
    if not channels[name] then return end
    for key, value in pairs(chatters) do
        if value == name then
            superchat.change_channel(key, settings.dchannel)
        end
    end
    channels[name] = nil
end

function superchat.change_prefix(player_name, prefix)
    if not minetest.player_exists(player_name) then return false end
    minetest.get_player_by_name(player_name):set_attribute('superchat.prefix', prefix)
    return true
end

function superchat.get_prefix(player_name)
    if not minetest.player_exists(player_name) then return nil end
    return minetest.get_player_by_name(player_name):get_attribute('superchat.prefix')
end

-- EVENTS
minetest.register_on_chat_message(function(name, message)
    if not minetest.check_player_privs(name, {scnofilter=true}) then
        message = filter(message)
    end
    superchat.send(name, superchat.get_player_channel(name), message)
    return true
end)

minetest.register_on_joinplayer(function(player)
    if not player:get_attribute('superchat.ch') then
        superchat.change_channel(player:get_player_name(), settings.dchannel)
    end
end)

-- GUI SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_listener(function(player_name, cat, page, fields)
        local function gch()
            local add = superchat.get_player_channels(player_name)
            local ch = superchat.get_player_channel(player_name)
            if add then
                local result = {}
                result[S('Chat channels')] = {}
                for key, value in pairs(add) do
                    if value == ch then
                        result[S('Chat channels')]['superchat.ch.' .. value] = {text = '*' .. value .. '*'}
                    else
                        result[S('Chat channels')]['superchat.ch.' .. value] = {text = value}
                    end
                end
                return result
            end
        end
    
        if not cat and not fields then
            return gch()
        elseif not fields then return nil
        elseif fields['gui_menu:cat.' .. S('Chat channels')] then
            gui_menu.show_buttons(player_name, S('Chat channels'), gch()[S('Chat channels')], 1)
        elseif cat == S('Chat channels') and fields['gui_menu:pgo'] then
            gui_menu.show_buttons(player_name, S('Chat channels'), gch()[S('Chat channels')], page + 1)
        elseif cat == S('Chat channels') and fields['gui_menu:pback'] then
            gui_menu.show_buttons(player_name, S('Chat channels'), gch()[S('Chat channels')], page - 1)
        elseif cat == S('Chat channels') and fields then
            local function f(player, ch)
                superchat.change_channel(player:get_player_name(), ch)
                minetest.chat_send_player(player:get_player_name(), S('Current channel') .. ': ' .. ch)
                gui_menu.show_buttons(player_name, S('Chat channels'), gch()[S('Chat channels')], page)
            end
            
            local ch = superchat.get_player_channels(player_name)
            if not ch then return nil end
            for key, value in pairs(ch) do
                if fields['superchat.ch.' .. value] then
                    return {func = f, args = {value}}
                end
            end
        end
    end)
end

-- REGISTRATIONS
minetest.register_privilege('scomch', S('Can use /omch'))
minetest.register_privilege('scoch', S('Can use /och'))
minetest.register_privilege('scpref', S('Can use /chpref'))
minetest.register_privilege('scopref', S('Can use /chopref'))
minetest.register_privilege('screload', S('Can use /chreload'))
minetest.register_privilege('scnofilter', S('For not filtering messages'))

-- COMMANDS
minetest.register_chatcommand('chlist', {
    params = 'none',
    description = S('show channels list'),
    func = function(name, params)
        local chs = superchat.get_player_channels(name)
        local list = ''
        for key, value in ipairs(chs) do list = list .. value .. ', ' end
        return true, S('Channels') .. ': ' .. list:sub(0, list:len()-2)
    end,
})

minetest.register_chatcommand('mch', {
    params = 'none',
    description = S('show you current channel'),
    func = function(name, params)
        return true, S('You channel') .. ': ' .. superchat.get_player_channel(name)
    end,
})

minetest.register_chatcommand('omch', {
    params = '<player>',
    description = S('show player current channel'),
    privs = {scomch = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player') end
        if not minetest.player_exists(params) then return false, S('player not found') end
        return true, S('%s channel'):format(params) .. ': ' .. superchat.get_player_channel(params)
    end,
})

minetest.register_chatcommand('ch', {
    params = '<channel>',
    description = S('change channel'),
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not channel') end
        local ch = get_channel(params)
        if not ch or not superchat.is_exists(ch) then return false, S('channel not found') end
        local result = superchat.change_channel(name, ch)
        if result then return true, S('Current channel') .. ': ' .. ch end
        return false, S('error')
    end,
})

minetest.register_chatcommand('och', {
    params = '<player> <channel>',
    description = S('change player channel'),
    privs = {scoch = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not channel') end
        if not minetest.player_exists(params[1]:trim()) then return false, S('player not found') end
        local ch = get_channel(params[2]:trim())
        if not ch or not superchat.is_exists(ch) then return false, S('channel not found') end
        local result = superchat.change_channel(params[1]:trim(), ch)
        if result then
            local player = minetest.get_player_by_name(params[1])
            if player:is_player_connected() then
                minetest.chat_send_player(player:get_player_name(), S('Current channel') .. ': ' .. ch)
            end
            return true, S('%s current channel'):format(params[1]) .. ': ' .. ch
        end
        return false, S('error')
    end,
})

minetest.register_chatcommand('chpref', {
    params = '<prefix?>',
    description = S('change prefix'),
    privs = {scpref = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then
            local result = superchat.change_prefix(name, nil)
            if result then return true, S('Prefix deleted') end
        end
        local result = superchat.change_prefix(name, params)
        if result then return true, S('Current prefix') .. ': ' .. params end
        return false, S('error')
    end,
})

minetest.register_chatcommand('chopref', {
    params = '<player> <prefix?>',
    description = S('change player prefix'),
    privs = {scopref = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then
            local result = superchat.change_prefix(params[1]:trim(), nil)
            if result then return true, S('%s prefix deleted'):format(params[1]) end
        end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local result = superchat.change_prefix(params[1]:trim(), params[2]:trim())
        if result then
            local player = minetest.get_player_by_name(params[1])
            if player:is_player_connected() then
                minetest.chat_send_player(player:get_player_name(), S('Current prefix') .. ': ' .. params[2])
            end
            return true, S('%s current prefix'):format(params[1]) .. ': ' .. params[2]
        end
        return false, S('error')
    end,
})

minetest.register_chatcommand('chreload', {
    params = '<none',
    description = S('reload settings'),
    privs = {screload = true},
    func = function(name, params)
        load_settings()
        return true, S('config reloaded')
    end,
})
