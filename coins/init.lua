coins = {}
local sep = package.path:match('(%p)%?%.')
local path = minetest.get_worldpath() .. sep .. 'coins.log'

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- LOCAL FUNCTIONS
local function log(str)
    local mess = os.date('[%Y-%m-%d %X]: ') .. str
    local log = io.open(path, 'a')
    log:write(mess .. '\n')
    log:flush()
    log:close()
    minetest.log('action', str)
end

-- API
function coins.get_coins(player_name)
    if not minetest.player_exists(player_name) then return nil end
    local player = minetest.get_player_by_name(player_name)
    local result = player:get_attribute('coins')
    if result then return tonumber(result) end
    return 0
end

function coins.set_coins(player_name, num)
    if not minetest.player_exists(player_name) then return false end
    local player = minetest.get_player_by_name(player_name)
    player:set_attribute('coins', tostring(num))
    log(S('set balance %s on %d'):format(player_name, num))
    return true
end

function coins.add_coins(player_name, num)
    if not minetest.player_exists(player_name) then return nil end
    local player = minetest.get_player_by_name(player_name)
    local result = player:get_attribute('coins')
    if result then result = tonumber(result) else result = 0 end
    local sum = result + num
    player:set_attribute('coins', tostring(sum))
    log(S('add %d to %s balance (new - %d, old - %d)'):format(num, player_name, sum, result))
    return sum
end

function coins.take_coins(player_name, num)
    if not minetest.player_exists(player_name) then return nil end
    local player = minetest.get_player_by_name(player_name)
    local result = player:get_attribute('coins')
    if result then result = tonumber(result) else result = 0 end
    local dif = result - num
    player:set_attribute('coins', tostring(dif))
    log(S('take %d from balance %s (new - %d, old - %d)'):format(num, player_name, dif, result))
    return dif
end

-- REGISTRATIONS
minetest.register_privilege('coinsbal', S('Can use /bal'))
minetest.register_privilege('coinsobal', S('Can use /obal'))
minetest.register_privilege('coinsbset', S('Can use /bset'))
minetest.register_privilege('coinsbtake', S('Can use /btake'))
minetest.register_privilege('coinsbgive', S('Can use /bgive'))
minetest.register_privilege('coinspay', S('Can use /pay'))

-- COMMANDS
minetest.register_chatcommand('bal', {
    params = 'none',
    description = S('show you balance'),
    privs = {coinsbal = true},
    func = function(name, params)
        local bal = coins.get_coins(name)
        if not bal then bal = 0 end
        return true, S('You balance') .. ': ' .. tostring(bal)
    end,
})

minetest.register_chatcommand('obal', {
    params = '<player>',
    description = S('show player balance'),
    privs = {coinsobal = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player') end
        if not minetest.player_exists(params) then return false, S('player not found') end
        local bal = coins.get_coins(params)
        if not bal then bal = 0 end
        return true, S('%s balance'):format(params) .. ': ' .. tostring(bal)
    end,
})

minetest.register_chatcommand('bset', {
    params = '<player> <number>',
    description = S('set player balance'),
    privs = {coinsbset = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not number') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        if not params[2]:trim():match('^[0-9]*$') then return false, S('invalid number') end
        local result = coins.set_coins(params[1]:trim(), tonumber(params[2]:trim()))
        if result then
            local player = minetest.get_player_by_name(params[1]:trim())
            if player:is_player_connected() then
                minetest.chat_send_player(params[1]:trim(), S('%s set you banance on %s'):format(name, params[2]))
            end
            return true, S('%s balance set to %s'):format(params[1], params[2])
        else return false, S('error') end
    end,
})

minetest.register_chatcommand('btake', {
    params = '<player> <number>',
    description = S('take coins from player balance'),
    privs = {coinsbtake = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not number') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        if not params[2]:trim():match('^[0-9]*$') then return false, S('invalid number') end
        local result = coins.take_coins(params[1]:trim(), tonumber(params[2]:trim()))
        if result then
            local player = minetest.get_player_by_name(params[1]:trim())
            if player:is_player_connected() then
                minetest.chat_send_player(params[1]:trim(), S('%s take %s from you balance'):format(name, params[2]))
            end
            return true, S('%s current balance is %d'):format(params[1], result)
        else return false, S('error') end
    end,
})

minetest.register_chatcommand('bgive', {
    params = '<player> <number>',
    description = S('give coins from player balance'),
    privs = {coinsbgive = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not number') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        if not params[2]:trim():match('^[0-9]*$') then return false, S('invalid number') end
        local result = coins.add_coins(params[1]:trim(), tonumber(params[2]:trim()))
        if result then
            local player = minetest.get_player_by_name(params[1]:trim())
            if player:is_player_connected() then
                minetest.chat_send_player(params[1]:trim(), S('%s give %s to you balance'):format(name, params[2]))
            end
            return true, S('%s current balance is %d'):format(params[1], result)
        else return false, S('error') end
    end,
})

minetest.register_chatcommand('pay', {
    params = '<player> <number>',
    description = S('pay player'),
    privs = {coinspay = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not number') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        if not params[2]:trim():match('^[0-9]*$') then return false, S('invalid number') end
        local sum = tonumber(params[2]:trim())
        if sum <= 0 then return false, S('error, need only positive number') end
        local bal = coins.get_coins(name)
        if not bal or bal < sum then return false, S('%d not in you balance'):format(sum) end
        local result = coins.take_coins(name, sum)
        if not result then return false, S('error') end
        result = coins.add_coins(params[1]:trim(), sum)
        if not result then return false, S('error') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if player:is_player_connected() then
            minetest.chat_send_player(params[1]:trim(), S('%s payed %d to you'):format(name, sum))
        end
        return true, S('%d success payed to %s'):format(sum, params[1])
    end,
})
