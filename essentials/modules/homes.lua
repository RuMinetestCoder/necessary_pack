local S = essentials._initlib

-- API PART
function essentials.set_home(player_name, name, pos)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    local homes = player:get_attribute('ehomes')
    if homes then homes = minetest.parse_json(homes)
    else homes = {} end
    homes[name] = pos
    player:set_attribute('ehomes', minetest.write_json(homes))
    return true
end

function essentials.del_home(player_name, name)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    local homes = player:get_attribute('ehomes')
    if homes then homes = minetest.parse_json(homes)
    else return false end
    if not homes[name] then return false end
    homes[name] = nil
    player:set_attribute('ehomes', minetest.write_json(homes))
    return true
end

function essentials.get_home(player_name, name)
    if not minetest.player_exists(player_name) then return nil end
    local player = minetest.get_player_by_name(player_name)
    local homes = player:get_attribute('ehomes')
    if homes then homes = minetest.parse_json(homes)
    else return nil end
    return homes[name]
end

function essentials.get_homes(player_name)
    if not minetest.player_exists(player_name) then return nil end
    local player = minetest.get_player_by_name(player_name)
    local homes = player:get_attribute('ehomes')
    if homes then homes = minetest.parse_json(homes)
    else return nil end
    return homes
end

function essentials.get_string_homes(player_name)
    local homes = essentials.get_homes(player_name)
    if not homes then return nil end
    return essentials.table_to_string(homes)
end

function essentials.get_num_homes(player_name)
    local homes = essentials.get_homes(player_name)
    if not homes then return 0 end
    return essentials.table_len(homes)
end

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_listener(function(player_name, cat, page, fields)
        local function gh()
            local add = essentials.get_homes(player_name)
            if add then
                local result = {}
                result[S('Homes')] = {}
                for key, value in pairs(add) do
                    result[S('Homes')]['ess.home.' .. key] = {text = key}
                end
                return result
            end
        end
        
        local gh2 = gh()
        if not gh2 then return nil end
        if not cat and not fields then
            return gh2
        elseif not fields then return nil
        elseif fields['gui_menu:cat.' .. S('Homes')] then
            gui_menu.show_buttons(player_name, S('Homes'), gh2[S('Homes')], 1)
        elseif cat == S('Homes') and fields['gui_menu:pgo'] then
            gui_menu.show_buttons(player_name, S('Homes'), gh2[S('Homes')], page + 1)
        elseif cat == S('Homes') and fields['gui_menu:pback'] then
            gui_menu.show_buttons(player_name, S('Homes'), gh2[S('Homes')], page - 1)
        elseif cat == S('Homes') and fields then
            local function f(player, home)
                essentials.set_full_pos(player, essentials.get_home(player_name, home))
            end
            
            local homes = essentials.get_homes(player_name)
            if not homes then return nil end
            for key, value in pairs(homes) do
                if fields['ess.home.' .. key] then
                    return {func = f, args = {key}}
                end
            end
        end
    end)
end

-- COMMANDS
minetest.register_chatcommand('ehome', {
    params = '<home name>',
    description = S('teleport to home point'),
    privs = {ehome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not home name') end
        local home = essentials.get_home(name, params)
        if not home then return false, S('home %s not found or error'):format(params) end
        essentials.set_full_pos(minetest.get_player_by_name(name), home)
        return true, S('teleporting you to %s home point'):format(params)
    end,
})

minetest.register_chatcommand('ehomes', {
    params = 'none',
    description = S('show you homes list'),
    privs = {ehome = true},
    func = function(name, params)
        local list = essentials.get_homes(name)
        if not list then return false, S('not homes') end
        return true, S('Homes (%d)'):format(essentials.table_len(list)) .. ': ' .. essentials.table_to_string(list)
    end,
})

minetest.register_chatcommand('esethome', {
    params = '<home name>',
    description = S('set the home point'),
    privs = {ehome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not home name') end
        if not minetest.check_player_privs(name, {ehomenl=true}) then
            local homes = essentials.get_homes(name)
            if homes then
                local limit = essentials.__settings.home
                if minetest.global_exists('group_perms') then
                    local groups = group_perms.get_player_groups(player_name)
                    for key, value in pairs(essentials.__settings.warplimits) do
                        local group, limit = value:split('=')
                        limit = toessentials.table_lenber(limit)
                        for k, v in pairs(groups) do
                            if group == v and limit > result then result = limit end
                        end
                    end
                end
                if #homes >= limit then return false, S('homes limit %d is over'):format(limit) end
            end
        end
        essentials.set_home(name, params, essentials.get_full_pos(minetest.get_player_by_name(name)))
        return true, S('home %s success set'):format(params)
    end,
})

minetest.register_chatcommand('eohome', {
    params = '<player name> <home name>',
    description = S('teleport to player home point'),
    privs = {eohome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not home') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local home = essentials.get_home(params[1]:trim(), params[2]:trim())
        if not home then return false, S('home %s not found or error'):format(params[2]) end
        essentials.set_full_pos(params[1]:trim(), home)
        return true, S('teleporting you to %s (%s) home point'):format(params[2], params[1])
    end,
})

minetest.register_chatcommand('eohomes', {
    params = '<player name>',
    description = S('show player homes list'),
    privs = {eohome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local list = essentials.get_homes(params)
        if not list then return false, S('not homes') end
        return true, S('%s homes (%d)'):format(params, essentials.table_len(list)) .. ': ' .. essentials.table_to_string(list)
    end,
})

minetest.register_chatcommand('eosethome', {
    params = '<player name> <home name>',
    description = S('set the home point for other player'),
    privs = {eosethome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not home') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        essentials.set_home(params[1]:trim(), params[2]:trim(), essentials.get_full_pos(minetest.get_player_by_name(name)))
        return true, S('home %s for %s success set'):format(params[2], params[1])
    end,
})

minetest.register_chatcommand('edelhome', {
    params = '<home name>',
    description = S('delete home point'),
    privs = {ehome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not home name') end
        if essentials.del_home(name, params) then
            return true, S('home point %s removed'):format(params)
        else
            return false, S('home %s not found or error'):format(params)
        end
    end,
})

minetest.register_chatcommand('eodelhome', {
    params = '<player> <home name>',
    description = S('delete player home point'),
    privs = {eodelhome = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not home') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        if essentials.del_home(params[1]:trim(), params[2]:trim()) then
            return true, S('home point %s removed'):format(params[2])
        else
            return false, S('home %s not found or error'):format(params[2])
        end
    end,
})
