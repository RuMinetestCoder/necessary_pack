local S = essentials._initlib
local afk = {}
local players = {}

-- API
function essentials.is_afk(player_name)
    if afk[player_name] then return true end
    return false
end

function essentials.toggle_afk(player_name)
    if afk[player_name] then
        minetest.chat_send_all(S('%s is no AFK'):format(player_name))
        if essentials.__settings.afkback then
            minetest.get_player_by_name(player_name):setpos(afk[player_name].pos)
            minetest.chat_send_player(player_name, S('teleport to starting posiotion'))
        end
        afk[player_name] = nil
        return false
    else
        afk[player_name] = {time = os.time(), pos = minetest.get_player_by_name(player_name):getpos()}
        minetest.chat_send_all(S('%s is AFK'):format(player_name))
        return true
    end
end

function essentials.get_afk_time(player_name)
    if not afk[player_name] then return 0 end
    return afk[player_name].time
end

function essentials.get_afk_pos(player_name)
    if not afk[player_name] then return nil end
    return afk[player_name].pos
end

-- LOCAL FUNCTIONS
local function check(name)
    if afk[name] then
        minetest.chat_send_player(name, S('you is no AFK'))
        essentials.toggle_afk(name)
    else
        players[name] = os.time()
    end
end

local function tick(bpos)
    local t = os.time()
    local pos = {}
    if bpos then pos = bpos end
    for name, time in pairs(players) do
        local player = minetest.get_player_by_name(name)
        if player:is_player_connected() then
            if pos[name] and not essentials.table_equals(pos[name], player:getpos()) and afk[name] then
                essentials.toggle_afk(name)
                time = t
            end
            if (pos[name] and not essentials.table_equals(pos[name], player:getpos())) or not pos[name] then
                pos[name] = player:getpos()
                players[name] = t
            end
            if t - time >= essentials.__settings.afk * 60 and not afk[name] then
                essentials.toggle_afk(name)
            end
        else
            pos[name] = nil
        end
    end
    minetest.after(1, tick, pos)
end

minetest.after(1, tick, nil)

-- EVENTS
minetest.register_on_joinplayer(function(player)
    players[player:get_player_name()] = os.time()
end)

minetest.register_on_player_hpchange(function(player, hp_change)
    if essentials.__settings.afkkeephp and afk[player:get_player_name()] then return true end
end, nil)

minetest.register_on_chat_message(function(name, message)
    check(name)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    check(player:get_player_name())
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    check(placer:get_player_name())
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    check(puncher:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    afk[name] = nil
    players[name] = nil
end)

-- COMMANDS
minetest.register_chatcommand('afk', {
    params = 'none',
    description = S('toggle afk'),
    privs = {eafk = true},
    func = function(name, params)
        if essentials.toggle_afk(name) then return true, S('you AFK')
        else return true, S('you is no AFK') end
    end,
})
