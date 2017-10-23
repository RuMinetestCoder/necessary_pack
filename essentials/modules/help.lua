local fs = require 'minifs'
local S = essentials._initlib
local sep = package.path:match('(%p)%?%.')

-- API PART
function essentials.open_help(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player:is_player_connected(player_name) then return end
    local str = 'size[20.25,9]textlist[0,0;20,8;essentials:helptxt;'
    for line in io.lines(essentials.__path_help) do str = str .. minetest.formspec_escape(line) .. ',' end
    str = str:sub(0, str:len() - 1)
    minetest.show_formspec(player_name, 'essentials:help', str .. ']button_exit[8,8;3,1;essentials:exit;' .. S('Exit') .. ']')
end

-- LOCAL FUNCTIONS
local function open(player_name, name)
    local str = 'size[20.25,9]textlist[0,0;20,8;essentials:filetxt;'
    for line in io.lines(essentials.__path_help_folder .. sep .. name) do str = str .. minetest.formspec_escape(line) .. ',' end
    str = str:sub(0, str:len() - 1)
    minetest.show_formspec(player_name, 'essentials:showtxtfile', str .. ']button_exit[8,8;3,1;essentials:exit;' .. S('Exit') .. ']')
end

local function reg()
    if not minetest.global_exists('gui_menu') then return end
    for name in fs.files(essentials.__path_help_folder, false) do
        gui_menu.add_button(S('Information'), 'ess.help.openfile', name:split('.')[1], nil,
            function(player, fname) open(player:get_player_name(), fname) end, {name}
        )
    end
end

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_button(S('Information'), 'ess.help.open', S('Help'), nil,
        function(player) essentials.open_help(player:get_player_name()) end, {}
    )
    reg()
end

-- COMMANDS
minetest.register_chatcommand('ehelp', {
    params = 'none',
    description = S('show help page'),
    privs = {ehelp = true},
    func = function(name, params) essentials.open_help(name) end,
})

minetest.register_chatcommand('ehupdate', {
    params = 'none',
    description = S('update txt files list'),
    privs = {ehupdate = true},
    func = function(name, params)
        reg()
        return true, S('txt files list updated')
    end,
})
