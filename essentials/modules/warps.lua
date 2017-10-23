local S = essentials._initlib

-- LOCAL FUNCTIONS
local function str_warps(t)
    local result = ''
    for key, value in pairs(t) do
        result = result .. value .. ', '
    end
    return result:sub(0, result:len()-2)
end

-- MENU SUPPORT
local function reg_gui()
    if minetest.global_exists('gui_menu') then
        for key in pairs(essentials.__warps) do 
            gui_menu.add_button(S('Warps'), 'ess.warp.' .. key, key, nil, essentials.warp, {key})
        end
    end
end
reg_gui()

-- API PART
function essentials.get_warps()
    if not essentials.__warps then return nil end
    local result = {}
    for key in pairs(essentials.__warps) do
        table.insert(result, key)
    end
    return result
end

function essentials.get_string_warps()
    local warps = essentials.get_warps()
    if not warps then return nil end
    return str_warps(warps)
end

function essentials.warp_exists(name)
    if not essentials.__warps then return false end
    if essentials.__warps[name] then return true end
    return false
end

function essentials.set_warp(pos, name, owner_name)
    if not essentials.__warps then essentials.__warps = {} end
    essentials.__warps[name] = {owner = owner_name}
    essentials.__warps[name].pos = pos
    mod_configs.save_json('essentials', 'warps', essentials.__warps)
    reg_gui()
end

function essentials.del_warp(name)
    if not essentials.__warps or not essentials.__warps[name] then return false end
    essentials.__warps[name] = nil
    mod_configs.save_json('essentials', 'warps', essentials.__warps)
    reg_gui()
    return true
end

function essentials.get_warp(name)
    if not essentials.__warps or not essentials.__warps[name] then return nil end
    return essentials.__warps[name]
end

function essentials.get_player_warps(player_name)
    if not essentials.__warps then return nil end
    local result = {}
    local i = 1
    for key, value in pairs(essentials.__warps) do
        if value.owner == player_name then
            result[i] = {name = key, data = value}
            i = i + 1
        end
    end
    return result
end

function essentials.get_string_player_warps(player_name)
    local warps = essentials.get_layer_warps(player_name)
    if not warps then return nil end
    return str_warps(warps)
end

function essentials.warp(player, name)
    if not essentials.__warps or not essentials.__warps[name] then return false end
    essentials.set_full_pos(player, essentials.__warps[name].pos)
    return true
end

function essentials.get_warps_limit(player_name)
    local result = 0
    if minetest.global_exists('group_perms') then
        local groups = group_perms.get_player_groups(player_name)
        for key, value in pairs(essentials.__settings.warplimits) do
            local group, limit = value:split('=')
            limit = tonumber(limit)
            for k, v in pairs(groups) do
                if group == v and limit > result then result = limit end
            end
        end
    else
        result = essentials.__settings.warplimit
    end
    return result
end

function essentials.get_available_warps_limit(player_name)
    local limit = essentials.get_warps_limit(player_name)
    local warps = essentials.get_player_warps(player_name)
    if not warps then return limit end
    return limit - #warps
end

-- COMMANDS
minetest.register_chatcommand('warp', {
    params = '<warp>',
    description = S('teleport to warp'),
    privs = {warp = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not warp') end
        local result = essentials.warp(minetest.get_player_by_name(name), params:trim())
        if result then return true, S('you teleported to warp %s'):format(params)
        else return false, S('warp %s not set'):format(params) end
    end,
})

minetest.register_chatcommand('towarp', {
    params = '<player> <warp>',
    description = S('teleport player to warp'),
    privs = {towarp = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 2 then return S('invalid command, not nick') end
        if #params < 3 then return S('invalid command, not warp') end
        if not minetest.player_exists(params[2]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[2]:trim())
        if not player:is_player_connected() then return false, S('player not online') end
        local warp = params[3]:trim()
        local result = essentials.warp(player, warp)
        if result then return true, S('%s teleported to warp %s'):format(player:get_player_name(), warp)
        else return false, S('warp %s not set'):format(warp) end
    end,
})

minetest.register_chatcommand('warps', {
    params = 'none',
    description = S('show warps list'),
    privs = {warps = true},
    func = function(name, params)
        local result = essentials.get_warps()
        if not result then return false, S('not warps') end
        return true, S('Warps (%d)'):format(#result) .. ': ' .. str_warps(result)
    end,
})

minetest.register_chatcommand('mywarps', {
    params = 'none',
    description = S('show you warps list'),
    privs = {mywarps = true},
    func = function(name, params)
        local result = essentials.get_player_warps(name)
        if not result then return false, S('not warps') end
        return true, S('You warps (%d)'):format(#result) .. ': ' .. str_warps(result)
    end,
})

minetest.register_chatcommand('pwarps', {
    params = '<player>',
    description = S('show player warps list'),
    privs = {pwarps = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player') end
        local result = essentials.get_player_warps(params)
        if not result then return false, S('not warps') end
        return true, S('%s warps (%d)'):format(params, #result) .. ': ' .. str_warps(result)
    end,
})

minetest.register_chatcommand('setwarp', {
    params = '<warp name>',
    description = S('set warp point'),
    privs = {setwarp = true},
    func = function(name, params)
        local limit = essentials.get_warps_limit(name)
        if not minetest.check_player_privs(name, {setwarpnl=true}) and limit <= essentials.get_available_warps_limit(name) then
            return false, S('sorry, warps limit %d is over'):format(limit)
        end
        if not params or params:trim():len() == 0 then return false, S('invalid command, not warp name') end
        essentials.set_warp(essentials.get_full_pos(minetest.get_player_by_name(name)), params:trim(), name)
        return true, S('warp %s success set'):format(params)
    end,
})

minetest.register_chatcommand('delwarp', {
    params = '<warp>',
    description = S('del warp point'),
    privs = {delwarp = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not warp name') end
        local warp = essentials.get_warp(params)
        if not warp then return false, S('warp %s not found'):format(params) end
        if warp.owner ~= name and not minetest.check_player_privs(name, {delallwarps=true}) then
            return false, S('%s not your warp'):format(params)
        end
        essentials.del_warp(params)
        return true, S('warp %s success deleted'):format(params)
    end,
})
