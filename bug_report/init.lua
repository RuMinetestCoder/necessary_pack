local fs = require 'minifs'

local sep = fs.separator()
local path = minetest.get_worldpath() .. sep .. 'bugreports'

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- LOCAL FUNCTIONS
local function get_form()
    local result = 'size[10.25,9]field[0.4,0;10,1;bug_report.theme;;' .. S('No theme') .. ']'
    return result .. 'textarea[0.4,1;10,8;bug_report.text;;]button_exit[4,8;3,1;bug_report.send;' .. S('Send') .. ']'
end

local function save(text)
    if not fs.exists(path) then fs.mkdir(path) end
    local file = io.open(path .. sep .. os.date('%Y-%m-%d-%H-%M-%S-') .. tostring(os.time()) .. '.txt', 'w')
    file:write(text)
    file:flush()
    file:close()
end

-- EVENTS
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == 'bug_report' then
        local player_name = player:get_player_name()
        if not minetest.check_player_privs(player_name, {bugreport=true}) then return end
        if fields and fields['bug_report.text'] and fields['bug_report.text']:trim():len() > 0 and fields['bug_report.send'] then
            local result = ''
            if fields['bug_report.theme'] then result = fields['bug_report.theme']:trim() .. '\n=====================\n' end
            result = result .. fields['bug_report.text']:trim() .. '\n=====================\n'
            result = result .. player_name .. '\n=====================\n'
            result = result .. minetest.pos_to_string(player:getpos()) .. '\n=====================\n'
            result = result .. player:get_inventory_formspec()
            save(result)
            minetest.chat_send_player(player_name, S('Bug report sent'))
        else
            minetest.chat_send_player(player_name, S('Canceling sending'))
        end
    end
end)

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_button(S('Bug report'), 'bug_report.gui', S('Bug report'), nil,
        function(player)
            local player_name = player:get_player_name()
            if not minetest.check_player_privs(player_name, {bugreport=true}) then return end
            minetest.show_formspec(player_name, 'bug_report', get_form())
        end, {}
    )
end

-- REGISTRATIONS
minetest.register_privilege('bugreport', S('Can use /bug'))

-- COMMANDS
minetest.register_chatcommand('bug', {
	params = 'none',
	description = 'open bug report gui',
	privs = {bugreport = true},
	func = function(name, text)
		minetest.show_formspec(name, 'bug_report', get_form())
		return true, S('Bug report GUI is open')
	end,
})
