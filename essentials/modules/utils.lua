-- API PART
function essentials.get_full_pos(player)
    local result = player:getpos()
    result.pitch = player:get_look_vertical()
    result.yaw = player:get_look_horizontal()
    return result
end

function essentials.set_full_pos(player, pos)
    player:setpos(pos)
    player:set_look_vertical(pos.pitch)
    player:set_look_horizontal(pos.yaw)
end

local function is_empty(pos)
    local node = minetest.get_node_or_nil(pos)
    if node and node.name then
    	local def = minetest.registered_nodes[node.name]
    	if def and not def.walkable then
    		return true
    	end
    end
    return false
end

function essentials.find_position(pos) -- {x=.., y=.., z=..}, return true/false, pos
    local function get_near(num) -- return +/- num or 0 if over limit
        if num == 0 then return 1
        elseif num > 0 and num < essentials.__settings.posnear then return num + 1
        elseif num > 0 and num >= essentials.__settings.posnear then return -1
        elseif num < 0 and math.abs(num) < essentials.__settings.posnear then return num - 1
        elseif num < 0 and math.abs(num) >= essentials.__settings.posnear then return 0 end
    end
    
    local function get_pos(xyz, add)
        return {zyx.x + add.x, xyz.y + add.y, xyz.z + add.z}
    end

    local result = {x = 0, y = 0, z = 0}
    while true do
        result.x = get_near(result.x)
        if result.x == 0 then return false, pos end
        local xyz = get_pos(pos, result)
        if is_empty(xyz) and not is_empty({x = xyz.z, y = xyz.y - 1, z = xyz.z})
            then return true, xyz
        else
            while true do
                result.z = get_near(result.z)
                if result.z == 0 then
                    result.z = 0
                    break
                end
                xyz = get_pos(pos, result)
                if is_empty(xyz) and not is_empty({x = xyz.z, y = xyz.y - 1, z = xyz.z}) then
                    return true, xyz
                else
                    while true do
                        result.y = get_near(result.y)
                        if result.y == 0 then
                            result.y = 0
                            break
                        end
                        xyz = get_pos(pos, result)
                        if is_empty(xyz) and not is_empty({x = xyz.z, y = xyz.y - 1, z = xyz.z}) then
                            return true, xyz
                        end
                    end
                end
            end
        end
    end
end

function essentials.find_top_or_down_pos(pos, limit, top)
    local y = 1
    if not top then y = -1 end
    while true do
        local xyz = {x = pos.x, y = pos.y + y, z = pos.z}
        if is_empty(xyz) then return true, xyz end
        if top then y = y + 1 else y = y - 1 end
        if y > essentials.__settings.maxtop then return false, pos end
    end
end

function essentials.parse_time(str) -- s - seconds, m - minutes, h - hours, d - days, return seconds
    local function parse(s)
        local e = s:sub(s:len()-1, s:len()):lower()
        if e == 's' then return tonumber(s:sub(0, s:len() - 1))
        elseif e == 'm' then
            local sec = tonumber(s:sub(0, s:len() - 1))
            if not sec then return nil end
            return sec * 60
        elseif e == 'h' then
            local sec = tonumber(s:sub(0, s:len() - 1))
            if not sec then return nil end
            return sec * 60 * 60
        elseif e == 'd' then
            local sec = tonumber(s:sub(0, s:len() - 1))
            if not sec then return nil end
            return sec * 60 * 60 * 24
        else return tonumber(s) end
    end

    local result = 0
    if str:find(' ') then
        local args = str:split(' ')
        for key, value in pairs(args) do
            local sec = parse(value)
            if sec then result = result + sec end
        end
    else result = parse(str) end
    return result
end

function essentials.get_time(sec)
    local prefix = 'seconds'
    local result = 0
    if sec >= 60 then
        prefix = 'minutes'
        result = sec / 60
    end
    if result >= 60 then
        prefix = 'hours'
        result = result / 60
    end
    if result >= 24 then
        prefix = 'days'
        result = result / 24
    end
    return prefix, result
end

function essentials.table_to_string(t)
    local result = ''
    for key in pairs(t) do
        result = result .. key .. ', '
    end
    return result:sub(0, result:len()-2)
end

function essentials.table_len(t)
    local result = 0
    for key in pairs(t) do result = result + 1 end
    return result
end

function essentials.table_floor(pos)
    for key, value in pairs(pos) do pos[key] = math.floor(value) end
    return pos
end

function essentials.table_equals(t, t2)
    for key, value in pairs(t) do
        if t2[key] and type(value) == 'table' and type(t2[key]) == 'table' then
            if not equal(value, t2[key]) then return false end
        elseif not t2[key] or t2[key] ~= value then return false end
    end
    return true
end
