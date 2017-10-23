local S = group_perms._initlib

local function check(params)
    if not params or params:len() < 3 then return S('not arguments') end
    local params = params:split(' ')
    if #params < 2 then return S('not nick') end
    if #params < 3 then return S('not group') end
    if not minetest.player_exists(params[2]:trim()) then return S('player not found') end
    if not group_perms.group_exists(params[3]:trim()) then return S('group not found') end
    return nil
end

local function trim_table_values(t)
    local result = {}
    for key, value in pairs(t) do
        result[key] = value:trim()
    end
    return result
end

minetest.register_chatcommand('perms', {
    params = '<add player group | set player group | rem player group>',
    description = S('base command for manage privs'),
    privs = {perms = true},
    func = function(name, params)
        local ch = check(params)
        if ch ~= nil then return false, ch end
        local params = trim_table_values(params:split(' '))
        local cmd = params[1]:lower()
        if cmd == 'add' then
            local result = group_perms.add_to_group(params[2], params[3])
            if not result then return false, S('error') end
            return true, S('%s success added to %s'):format(params[2], params[3])
        elseif cmd == 'set' then
            local result = group_perms.set_group(params[2], params[3])
            if not result then return false, S('error') end
            return true, S('%s success set group %s'):format(params[2], params[3])
        elseif cmd == 'del' or cmd == 'rem' then
            local result = group_perms.rem_from_group(params[2], params[3])
            if not result then return false, S('error') end
            return true, S('%s success removed from group %s'):format(params[2], params[3])
        end
        return false, S('broken command')
    end,
})

minetest.register_chatcommand('perms-groups', {
    params = '<player>',
    description = S('show player groups'),
    privs = {perms = true},
    func = function(name, params)
        if not params or params:len() == 0 then return false, S('not arguments') end
        local params = trim_table_values(params:split(' '))
        if #params < 1 then return false, S('not nick') end
        if not minetest.player_exists(params[1]) then return false, S('player not found') end
        local player = minetest.get_player_by_name(params[1])
        local groups = minetest.parse_json(player:get_attribute('group_perms.groups'))
        if not groups then return false, S('player has no groups') end
        local result = S('Groups') .. ': '
        for key, value in pairs(groups) do
            result = result .. value .. ', '
        end
        return true, result:sub(0, result:len()-2)
    end,
})

minetest.register_chatcommand('perms-reload', {
    params = 'none',
    description = S('reload configs'),
    privs = {perms = true},
    func = function(name, params)
        group_perms._reload()
        return true, S('configs reloaded')
    end,
})

minetest.register_chatcommand('perms-show', {
    params = 'none',
    description = S('show group names'),
    privs = {perms = true},
    func = function(name, params)
        local groups = group_perms.get_groups()
        if not groups then return false, S('no groups') end
        local result = S('Groups') .. ': '
        for key, value in pairs(groups) do
            result = result .. value .. ', '
        end
        return true, result:sub(0, result:len()-2)
    end,
})
