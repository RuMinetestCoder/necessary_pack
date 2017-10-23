local S = essentials._initlib
local tps = {}
local i = 0
local tps2 = {}
local otime = os.time()

-- LOCAL FUNCTIONS
local function counter()
    table.insert(tps2, i)
    while #tps2 > essentials.__settings.tps do
        table.remove(tps2, #tps2)
    end
    i = 0
    minetest.after(1, counter)
end
minetest.after(1, counter)

-- API
function essentials.get_tps()
    local sum = 0
    for key, value in pairs(tps2) do
        sum = sum + value
    end
    return sum / #tps2
end

function essentials.get_overload()
    local c = 0
    for key, value in pairs(tps) do c = c + (value - 0.05) end
    return essentials.__settings.tps, c
end

-- EVENTS
minetest.register_globalstep(function(dtime)
    i = i + 1
    table.insert(tps, dtime)
    while #tps > essentials.__settings.tps / 0.05 do
        table.remove(tps, #tps)
    end
end)

-- COMMANDS
minetest.register_chatcommand('etps', {
    params = 'none',
    description = S('show TPS'),
    privs = {etps = true},
    func = function(name, params)
        return true, S('TPS') .. ': ' .. tostring(essentials.get_tps())
    end,
})

minetest.register_chatcommand('eover', {
    params = 'none',
    description = S('show overlod info'),
    privs = {etps = true},
    func = function(name, params)
        local t, o = essentials.get_overload()
        return true, S('Overload') .. ': ' .. S('%dsec (for %dsec)'):format(o, t)
    end,
})
