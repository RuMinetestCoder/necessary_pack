group_perms = {}

local sep = package.path:match('(%p)%?%.')
local modpath = minetest.get_modpath(minetest.get_current_modname())
local perms = mod_configs.get_conf('group_perms', 'perms')
local settings = mod_configs.get_conf('group_perms', 'settings')

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end
group_perms._initlib = S

-- LOAD CONFIGS
if not perms then
    perms = {
        default = {interact = true, shout = true, privs = true, zoom = true}
    }
    mod_configs.save_conf('group_perms', 'perms', perms)
end

if not settings then
    settings = {
        main = {
            default_group = 'default',
            new_player_method = 'set' --set or add
        }
    }
    mod_configs.save_conf('group_perms', 'settings', settings)
end

-- GENERAL FUNCTIONS
function group_perms._add_privs(player_name, group)
    local group_privs = perms[group]
    if not group_privs then return false end
    local player_privs = minetest.get_player_privs(player_name)
    for key, value in pairs(group_privs) do
        player_privs[key] = value
    end
    minetest.set_player_privs(player_name, player_privs)
    return true
end

function group_perms._rem_all_privs(player_name)
    minetest.set_player_privs(player_name, {})
    return true
end

function group_perms._set_privs(player_name, group)
    if not perms[group] then return false end
    group_perms._rem_all_privs(player_name)
    return group_perms._add_privs(player_name, group)
end

function group_perms._rem_privs(player_name, group)
    local group_privs = perms[group]
    if not group_privs then return false end
    local player_privs = minetest.get_player_privs(player_name)
    for key in pairs(group_privs) do player_privs[key] = nil end
    minetest.set_player_privs(player_name, player_privs)
    return true
end

-- REGISTRATIONS
minetest.register_on_joinplayer(function(player)
    if not player:get_attribute('group_perms.groups') then
        player:set_attribute('group_perms.groups', minetest.write_json({settings['main']['default_group']}))
        local method = settings['main']['new_player_method']
        if method == 'set' then
            group_perms._set_privs(player:get_player_name(), settings['main']['default_group'])
        elseif method == 'add' then
            group_perms._add_privs(player:get_player_name(), settings['main']['default_group'])
        end
    end
end)

minetest.register_privilege('perms', S('Can use /perms'))

-- API
function group_perms.get_group_privs(group)
    if minetest.player_exists(player_name) then
        return perms[group]
    else
        return nil
    end
end

function group_perms.group_exists(group)
    if not perms[group] then return false end
    return true
end

function group_perms._reload()
    perms = mod_configs.get_conf('group_perms', 'perms')
    settings = mod_configs.get_conf('group_perms', 'settings')
end

function group_perms.get_groups()
    local result = {}
    for key in pairs(perms) do
        table.insert(result, key)
    end
    return result
end

dofile(modpath .. sep .. 'api.lua')

-- COMMANDS
dofile(modpath .. sep .. 'commands.lua')
