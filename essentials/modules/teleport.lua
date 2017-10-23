local S = essentials._initlib

essentials.__callers = {}

-- API PART
function essentials.teleport_ptp(player_name_from, player_name_to, force)
    local from = minetest.get_player_by_name(player_name_from)
    local to = minetest.get_player_by_name(player_name_to)
    if not from or not to then return false end
    if not from:is_player_connected(player_name_from) or not to:is_player_connected(player_name_to) then
        return false
    end
    local empty, pos = essentials.find_position(to:getpos())
    if empty or force then
        from:setpos(pos)
        return true
    end
    return false
end

-- EVENTS
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
	if essentials.__callers[name] then essentials.__callers[name] = nil
	else
	    local i = 1
        for key in pairs(essentials.__callers) do
            if key == name then
                table.remove(essentials.__callers, i)
                break
            end
        end
    end
end)

-- COMMANDS
minetest.register_chatcommand('tp', {
    params = '<player>',
    description = S('teleport to player'),
    privs = {teleport = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        local result = essentials.teleport_ptp(name, params, false)
        if result then return true, S('you teleporting to %s'):format(params) end
        return false, S('not safe position near')
    end,
})

minetest.register_chatcommand('ftp', {
    params = '<player>',
    description = S('force teleport to player'),
    privs = {teleport = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        local result = essentials.teleport_ptp(name, params, true)
        if result then return true, S('you teleporting to %s'):format(params) end
        return false, S('error')
    end,
})

minetest.register_chatcommand('otp', {
    params = '<player> <player>',
    description = S('teleport player to player'),
    privs = {oteleport = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 2 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params[1]:trim()) or not minetest.player_exists(params[2]:trim()) then
            return S('player not found')
        end
        local to = minetest.get_player_by_name(params[1]:trim())
        local from = minetest.get_player_by_name(params[2]:trim())
        if not player:is_player_connected(params[1]:trim()) then return false, S('%s not online'):format(params[1]) end
        if not player:is_player_connected(params[2]:trim()) then return false, S('%s not online'):format(params[2]) end
        local result = essentials.teleport_ptp(params[1]:trim(), params[2]:trim(), false)
        if result then return true, S('%s teleporting to %s'):format(params[1], params[2]) end
        return false, S('not safe position near')
    end,
})

minetest.register_chatcommand('fotp', {
    params = '<player> <player>',
    description = S('force teleport player to player'),
    privs = {foteleport = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 2 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params[1]:trim()) or not minetest.player_exists(params[2]:trim()) then
            return S('player not found')
        end
        local to = minetest.get_player_by_name(params[1]:trim())
        local from = minetest.get_player_by_name(params[2]:trim())
        if not player:is_player_connected(params[1]:trim()) then return false, S('%s not online'):format(params[1]) end
        if not player:is_player_connected(params[2]:trim()) then return false, S('%s not online'):format(params[2]) end
        local result = essentials.teleport_ptp(params[1]:trim(), params[2]:trim(), true)
        if result then return true, S('%s teleporting to %s'):format(params[1], params[2]) end
        return false, S('error')
    end,
})

minetest.register_chatcommand('s', {
    params = '<player>',
    description = S('teleport player to you'),
    privs = {selftp = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        local result = essentials.teleport_ptp(params, name, false)
        if result then return true, S('% teleporting to you'):format(params) end
        return false, S('not safe position near')
    end,
})

minetest.register_chatcommand('fs', {
    params = '<player>',
    description = S('force teleport player to you'),
    privs = {fselftp = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        local result = essentials.teleport_ptp(params, name, true)
        if result then return true, S('% teleporting to you'):format(params) end
        return false, S('error')
    end,
})

minetest.register_chatcommand('call', {
    params = '<player>',
    description = S('request teleport you to player'),
    privs = {call = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        if essentials.is_vanished(params) and not minetest.check_player_privs(name, {callv=true}) then
            return false, S('%s not online'):format(params)
        end
        essentials.__[params] = {time = os.time(), self = false, player = name}
        minetest.chat_send_player(params, S('%s requested teleport to you, write /ty if yes or /tn'):format(name))
        return true, S('teleport success requested to %s'):format(params)
    end,
})

minetest.register_chatcommand('scall', {
    params = '<player>',
    description = S('request teleport player to you'),
    privs = {scall = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        if not minetest.player_exists(params) then return S('player not found') end
        local player = minetest.get_player_by_name(params)
        if not player:is_player_connected(params) then return false, S('%s not online'):format(params) end
        if essentials.is_vanished(params) and not minetest.check_player_privs(name, {callv=true}) then
            return false, S('%s not online'):format(params)
        end
        essentials.__[params] = {time = os.time(), self = true, player = name}
        minetest.chat_send_player(params, S('requested you to %s, write /ty if yes or /tn'):format(name))
        return true, S('teleport success requested to %s'):format(params)
    end,
})

minetest.register_chatcommand('ty', {
    params = 'none',
    description = S('accept request teleport'),
    privs = {call = true},
    func = function(name, params)
        if not essentials.__callers[name] then return false, S('no requests') end
        local caller = essentials.__callers[name]
        if os.time() - caller.time > essentials.__settings.callover then
            essentials.__callers[name] = nil
            return false, S('time is over')
        end
        if not minetest.player_exists(caller.player) then return false, S('%s not found'):format(caller.player) end
        local player = minetest.get_player_by_name(caller.player)
        if not player:is_player_connected(caller.player) then return false, S('%s not online'):format(caller.player) end
        if not caller.self then
            local result = essentials.teleport_ptp(name, caller.player, false)
            if result then return true, S('you teleporting to %s'):format(caller.player) end
            return false, S('not safe position near')
        else
            local result = essentials.teleport_ptp(caller.player, name, false)
            if result then return true, S('teleporting %s to you'):format(params) end
            return false, S('not safe position near')
        end
        essentials.__callers[name] = nil
    end,
})

minetest.register_chatcommand('tn', {
    params = 'none',
    description = S('deny request teleport'),
    privs = {call = true},
    func = function(name, params)
        if not essentials.__callers[name] then return false, S('no requests') end
        local caller = essentials.__callers[name]
        if minetest.player_exists(caller.player) and player:is_player_connected(caller.player) then
            minetest.chat_send_player(caller.player, S('%s denied you teleport request'):format(name))
        end
        essentials.__callers[name] = nil
        return true, S('%s teleport request denied'):format(caller.player)
    end,
})

minetest.register_chatcommand('top', {
    params = '<nodes?>',
    description = S('teleport to top position'),
    privs = {top = true},
    func = function(name, params)
        local limit = essentials.__settings.mintop
        if params or params:trim():len() > 0 then
            if not params:match('^[0-9]*$') then return false, S('invalid number') end
            local plimit = tonumber(params)
            if not plimit then return false, S('bad command, param not number') end
            if plimit > essentials.__settings.maxtop then
                return false, S('you number > %d'):format(essentials.__settings.maxtop)
            end
            limit = plimit
        end
        local player = minetest.get_player_by_name(name)
        local finded, pos = essentials.find_top_or_down_pos(player:get_name(), limit, true)
        if not finded then return false, S('top position not found') end
        player:setpos(pos)
        return true, S('teleported to top position')
    end,
})

minetest.register_chatcommand('down', {
    params = '<nodes?>',
    description = S('teleport to down position'),
    privs = {down = true},
    func = function(name, params)
        local limit = essentials.__settings.mindown
        if params or params:trim():len() > 0 then
            if not params:match('^[0-9]*$') then return false, S('invalid number') end
            local plimit = tonumber(params)
            if not plimit then return false, S('bad command, param not number') end
            if plimit > essentials.__settings.maxdown then
                return false, S('you number > %d'):format(essentials.__settings.maxdown)
            end
            limit = plimit
        end
        local player = minetest.get_player_by_name(name)
        local finded, pos = essentials.find_top_or_down_pos(player:get_name(), limit, false)
        if not finded then return false, S('down position not found') end
        player:setpos(pos)
        return true, S('teleported to down position')
    end,
})
