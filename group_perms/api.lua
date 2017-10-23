function group_perms.add_to_group(player_name, group)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    local groups = player:get_attribute('group_perms.groups')
    if groups then
        groups = minetest.parse_json(groups)
        table.insert(groups, group)
    else groups = {group} end
    player:set_attribute('group_perms.groups', minetest.write_json(groups))
    return group_perms._add_privs(player_name, group)
end

function group_perms.set_group(player_name, group)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    player:set_attribute('group_perms.groups', minetest.write_json({group}))
    group_perms._rem_all_privs(player_name)
    return group_perms._add_privs(player_name, group)
end

function group_perms.rem_from_group(player_name, group)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    local ch = group_perms._rem_privs(player_name, group)
    if not ch then return false end
    local groups = minetest.parse_json(player:get_attribute('group_perms.groups'))
    if not groups then return false end
    for key, value in pairs(groups) do
        if value == group then
            table.remove(groups, key)
            break
        end
    end
    player:set_attribute('group_perms.groups', minetest.write_json(groups))
    return true
end

function group_perms.get_player_groups(player_name)
    if not minetest.player_exists(player_name) then return nil end
    return minetest.parse_json(minetest.get_player_by_name(player_name):get_attribute('group_perms.groups'))
end

function group_perms.check_player_group(player_name, group)
    local groups = group_perms.get_player_groups(player_name)
    if not groups then return nil end
    for key, value in pairs(groups) do
        if type(value) == 'table' then
            for k, v in pairs(value) do
                if k == group then return true end
            end
        elseif value == group then return true end
    end
    return false
end
