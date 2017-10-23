local S = essentials._initlib

-- COMMANDS
minetest.register_chatcommand('fe', {
    params = 'none',
    description = S('send fake leave message'),
    privs = {fakeexit = true},
    func = function(name, params)
        minetest.chat_send_all(essentials.__settings.exit:format(name))
    end,
})

minetest.register_chatcommand('fj', {
    params = 'none',
    description = S('send fake join message'),
    privs = {fakejoin = true},
    func = function(name, params)
        minetest.chat_send_all(essentials.__settings.join:format(name))
    end,
})
