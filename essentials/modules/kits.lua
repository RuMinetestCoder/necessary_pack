local S = essentials._initlib

-- API PART
function essentials.get_kits()
    if not essentials.__kits then return nil end
    local result = {}
    for key, value in pairs(essentials.__kits.kits) do
        local data = value:split('=')
        if data[2]:find(',') then data[2] = data[2]:split(',')
        else data[2] = minetest.parse_json('["' .. data[2] .. '"]') end
        result[data[1]] = data[2]
    end
    return result
end

function essentials.get_string_kits()
    local kits = essentials.get_kits()
    if not kits then return nil end
    return essentials.table_to_string(kits)
end

function essentials.get_kit(kit_name)
    if not essentials.__kits or not essentials.__kits[kit_name] then return nil end
    return essentials.__kits[kit_name]
end

function essentials.get_kit_pause(kit_name)
    if not essentials.__kits then return 0 end
    for key, value in pairs(essentials.__kits.pause) do
        local name, pause = value:split('=')
        if name == kit_name then return tonumber(pause) end
    end
    return 0
end

function essentials.check_kit_access(player_name, kit_name)
    if not minetest.global_exists('group_perms') then return true end
    if not minetest.player_exists(player_name) then return false end
    if not essentials.__kits[kit_name] then return false end
    for key, value in pairs(essentials.get_kits()) do
        if key == kit_name then
            for k, v in pairs(value) do
                if group_perms.check_player_group(player_name, v) then return true end
            end
        end
    end
    return false
end

function essentials.get_player_pause(player_name, kit_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return 0 end
    local timestamp = player:get_attribute('essentials.kit.' .. kit_name)
    if not timestamp or timestamp == '0' then return 0 end
    local kit_pause = essentials.get_kit_pause(kit_name)
    if kit_pause == 0 then return 0 end
    return kit_pause - (os.time() - tonumber(timestamp))
end

function essentials.give_kit(player_name, kit_name)
    if not essentials.__kits or not essentials.__kits[kit_name] then return false end
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    for key, value in pairs(essentials.__kits[kit_name]) do
        player:get_inventory():add_item('main', value)
    end
    return true
end

function essentials._update_pause(player_name, kit_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    player:set_attribute('essentials.kit.' .. kit_name, tostring(os.time()))
    return true
end

function essentials._reset_pause(player_name, kit_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    player:set_attribute('essentials.kit.' .. kit_name, '0')
    return true
end

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_listener(function(player_name, cat, page, fields)
        local function gk()
            local add = essentials.get_kits()
            if add then
                local result = {}
                result[S('Kits')] = {}
                for key, value in pairs(add) do
                    if (((essentials.get_player_pause(player_name, key) <= 0) or
                        minetest.check_player_privs(player_name, {kitnopause=true})) and
                        essentials.check_kit_access(player_name, key)) then
                        result[S('Kits')]['ess.kits.' .. key] = {text = key}
                    end
                end
                return result
            end
        end
        
        local gk2 = gk()
        if not gk2 then return nil end
        if not cat and not fields then
            return gk2
        elseif not fields then return nil
        elseif fields['gui_menu:cat.' .. S('Kits')] then
            gui_menu.show_buttons(player_name, S('Kits'), gk2[S('Kits')], 1)
        elseif cat == S('Kits') and fields['gui_menu:pgo'] then
            gui_menu.show_buttons(player_name, S('Kits'), gk2[S('Kits')], page + 1)
        elseif cat == S('Kits') and fields['gui_menu:pback'] then
            gui_menu.show_buttons(player_name, S('Kits'), gk2[S('Kits')], page - 1)
        elseif cat == S('Kits') and fields then
            local function f(player, kit)
                local name = player:get_player_name()
                if essentials.give_kit(name, kit) then
                    minetest.chat_send_player(name, S('kit %s given to you'):format(kit))
                else
                    minetest.chat_send_player(name, S('kit %s not found or error'):format(kit))
                end
            end
            
            for key, value in pairs(gk2[S('Kits')]) do
                if fields[key] then
                    return {func = f, args = {value.text}}
                end
            end
        end
    end)
end

-- COMMANDS
minetest.register_chatcommand('kit', {
    params = '<kit name>',
    description = S('give kit to you'),
    privs = {kit = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not kit name') end
        if not essentials.__kits or not essentials.__kits[params] then
            return false, S('kit %s not found'):format(params)
        end
        if not minetest.check_player_privs(name, {kitnopause=true}) then
            local pause = essentials.get_player_pause(name, params)
            if pause > 0 then return false, S('please wait %d seconds'):format(pause) end
        end
        if not essentials.check_kit_access(name, params) then
            return false, S('sorry, not access')
        end
        local result = essentials.give_kit(name, params)
        if not result then return false, S('error') end
        essentials._update_pause(name, params)
        return true, S('kit %s given to you'):format(params)
    end,
})

minetest.register_chatcommand('gkit', {
    params = '<player> <kit name>',
    description = S('give kit to player'),
    privs = {gkit = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not player name') end
        if #params < 2 then return false, S('invalid command, not kit name') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if not essentials.__kits or not essentials.__kits[params[2]:trim()] then
            return false, S('kit %s not found'):format(params[2])
        end
        local result = essentials.give_kit(name, params[2]:trim())
        if not result then return false, S('error') end
        return true, S('kit %s given to %s'):format(params[2], params[1])
    end,
})

minetest.register_chatcommand('kits', {
    params = 'none',
    description = S('show kits list'),
    privs = {kits = true},
    func = function(name, params)
        local kits = essentials.get_kits()
        if not kits then return false, S('no kits') end
        for key in pairs(kits) do
            if not essentials.check_kit_access(key) then kits[key] = nil end
        end
        return true, S('Kits (%d)'):format(essentials.table_len(kits)) .. ': ' .. essentials.table_to_string(kits)
    end,
})

minetest.register_chatcommand('rkit', {
    params = '<player> <kit name>',
    description = S('reset kit pause for player'),
    privs = {rkit = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not player name') end
        if #params < 2 then return false, S('invalid command, not kit name') end
        local result = essentials._reset_pause(params[1]:trim(), params[2]:trim())
        if not result then return S('player not found') end
        return true, S('kit pause success reset for %s'):format(params[1])
    end,
})

minetest.register_chatcommand('pkit', {
    params = '<player> <kit name>',
    description = S('show player kit pause'),
    privs = {pkit = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not player name') end
        if #params < 2 then return false, S('invalid command, not kit name') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local pause = essentials.get_player_pause(name, params)
        return true, S('%s kit pause: %d seconds'):format(params[1], pause)
    end,
})
