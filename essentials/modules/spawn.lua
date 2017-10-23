local S = essentials._initlib

-- API PART
function essentials.set_spawn(pos) -- full pos
    local conf = mod_configs.load_json('essentials', 'spawn')
    if not conf then conf = {} end
    local spos = minetest.write_json(pos)
    essentials.__spawn = {spawn = pos}
    if conf.nspawn and conf.spawn and conf.spawn == conf.nspawn then
        essentials.__spawn.nspawn = pos
    elseif not conf.nspawn then
        essentials.__spawn.nspawn = pos
    end
    mod_configs.save_json('essentials', 'spawn', essentials.__spawn)
end

function essentials.set_nspawn(pos) -- full pos
    essentials.__spawn = {nspawn = pos, spawn = essentials.__spawn.spawn}
    mod_configs.save_json('essentials', 'spawn', essentials.__spawn)
end

function essentials.get_spawn()
    if not essentials.__spawn then return nil end
    return essentials.__spawn.spawn
end

function essentials.get_nspawn()
    if not essentials.__spawn then return nil end
    return essentials.__spawn.nspawn
end

function essentials.spawn(player)
    if essentials.__spawn then
        essentials.set_full_pos(player, essentials.__spawn.spawn)
        return true
    else return false end
end

function essentials.nspawn(player)
    if essentials.__spawn then
        essentials.set_full_pos(player, essentials.__spawn.nspawn)
        return true
    else return false end
end

-- MENU SUPPORT
local function reg()
    if minetest.global_exists('gui_menu') then
        gui_menu.add_button(S('Spawn'), 'ess.spawn', S('To spawn'), nil, essentials.spawn, {})
        gui_menu.add_button(S('Spawn'), 'ess.nspawn', S('To nspawn'), nil, essentials.nspawn, {})
    end
end
reg()

-- EVENTS
minetest.register_on_respawnplayer(function(player)
    if essentials.__settings.respawn and essentials.__spawn and essentials.__spawn.spawn then
        essentials.spawn(player)
    end
end)
minetest.register_on_newplayer(function(player)
    if essentials.__settings.nspawn and essentials.__spawn and essentials.__spawn.nspawn then
        essentials.nspawn(player)
    end
end)

-- COMMANDS
minetest.register_chatcommand('spawn', {
    params = 'none',
    description = S('teleport to spawn'),
    privs = {spawn = true},
    func = function(name, params)
        local result = essentials.spawn(minetest.get_player_by_name(name))
        if result then return true, S('you teleported to spawn')
        else return false, S('spawn not set') end
    end,
})

minetest.register_chatcommand('nspawn', {
    params = 'none',
    description = S('teleport to newbie spawn'),
    privs = {nspawn = true},
    func = function(name, params)
        local result = essentials.nspawn(minetest.get_player_by_name(name))
        if result then return true, S('you teleported to newbie spawn')
        else return false, S('nspawn not set') end
    end,
})

minetest.register_chatcommand('setspawn', {
    params = 'none',
    description = S('set spawn point'),
    privs = {setspawn = true},
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        essentials.set_spawn(essentials.get_full_pos(player))
        reg()
        return true, S('spawn point set')
    end,
})

minetest.register_chatcommand('setnspawn', {
    params = 'none',
    description = S('set newbie spawn point'),
    privs = {setnspawn = true},
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        essentials.set_nspawn(essentials.get_full_pos(player))
        reg()
        return true, S('newbie spawn point set')
    end,
})

minetest.register_chatcommand('delspawn', {
    params = 'none',
    description = S('delete spawn point'),
    privs = {setspawn = true},
    func = function(name, params)
        essentials.__spawn.spawn = nil
        mod_configs.save_json('essentials', 'spawn', essentials.__spawn)
        reg()
        return true, S('spawn point deleted')
    end,
})

minetest.register_chatcommand('delnspawn', {
    params = 'none',
    description = S('delete newbie spawn point'),
    privs = {setnspawn = true},
    func = function(name, params)
        essentials.__spawn.nspawn = nil
        mod_configs.save_json('essentials', 'spawn', essentials.__spawn)
        reg()
        return true, S('newbie spawn point deleted')
    end,
})

minetest.register_chatcommand('tospawn', {
    params = '<player>',
    description = S('teleport player to spawn'),
    privs = {tospawn = true},
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        if params then player = minetest.get_player_by_name(params) end
        if not player then return false, S('player not found') end
        local result = essentials.spawn(player)
        if result then return true, S('%s teleported to spawn'):format(player:get_player_name())
        else return false, S('spawn point not set') end
    end,
})

minetest.register_chatcommand('tonspawn', {
    params = '<player>',
    description = S('teleport player to newbie spawn'),
    privs = {tonspawn = true},
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        if params then player = minetest.get_player_by_name(params) end
        if not player then return false, S('player not found') end
        local result = essentials.nspawn(player)
        if result then return true, S('%s teleported to newbie spawn'):format(player:get_player_name())
        else return false, S('newbie spawn point not set') end
    end,
})
