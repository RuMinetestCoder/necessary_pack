local S = essentials._initlib

-- API PART
function essentials.kick(player_name, message)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    if not player:is_player_connecetd(player_name) then return false end
    minetest.kick_player(player_name, message)
    return true
end

-- LOCAL FUNCTIONS
local function kicklog(str)
    local mess = os.date('[%Y-%m-%d %X]: ') .. str
    local log = io.open(essentials.__path_kicklog, 'a')
    log:write(mess .. '\n')
    log:flush()
    log:close()
    minetest.log('action', str)
end

local function sendmess(str)
    local players = minetest.get_connected_players()
    if not players or #players == 0 then return false end -- lol
    for _,player in ipairs(players) do
        local name = player:get_player_name()
        if minetest.check_player_privs(name, {ekicksee=true}) then
            minetest.chat_send_player(name, str)
        end
    end
end

-- COMMANDS
minetest.register_chatcommand('ekick', {
    params = '<player> <reason>',
    description = S('kick player'),
    privs = {ekick = true},
    func = function(name, params)
        if not params or params:trim():len() == 0 then return false, S('invalid command, not player name') end
        local params = params:split(' ')
        if #params < 1 then return false, S('invalid command, not nick') end
        if #params < 2 then return false, S('invalid command, not reason') end
        if not minetest.player_exists(params[1]:trim()) then return S('player not found') end
        local player = minetest.get_player_by_name(params[1]:trim())
        if minetest.check_player_privs(name, {exekick=true}) then
            return false, S('%s exempted of kick'):format(params[1])
        end
        local result = essentials.kick(params[1]:trim(), params[2])
        if not result then return false, S('%s not online'):format(params[1]) end
        kicklog(S('%s kicked %s (%s))'):format(name, params[1], params[2]))
        sendmess(S('%s kicked %s (%s)'):format(name, params[1], params[2]))
        return true, S('%s kicked'):fromat(params[1])
    end,
})
