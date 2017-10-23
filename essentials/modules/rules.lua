local S = essentials._initlib

-- API PART
function essentials.open_rules(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player or not player:is_player_connected(player_name) then return end
    local str = 'size[20.25,9]textlist[0,0;20,8;essentials:rulestxt;'
    for line in io.lines(essentials.__path_rules) do str = str .. minetest.formspec_escape(line) .. ',' end
    str = str:sub(0, str:len() - 1)
    str = str .. ']button_exit[5,8;3,1;essentials:agree;' .. S('I Agree') .. ']'
    str = str .. 'button_exit[11,8;3,1;essentials:disagree;' .. S('Disagree') .. ']'
    minetest.show_formspec(player_name, 'essentials:rules', str)
end

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_button(S('Information'), 'ess.rules.open', S('Rules'), nil,
        function(player) essentials.open_rules(player:get_player_name()) end, {}
    )
end

-- EVENTS
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == 'essentials:rules' then
        if fields['essentials:agree'] then
            player:set_attribute('essentials.rules', 'true')
        elseif fields['essentials:disagree'] or fields.quit then
            player:set_attribute('essentials.rules', 'false')
            minetest.kick_player(player:get_player_name(), S('You disagree rules, bye.'))
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    if essentials.__settings.rulesshow then
        local agree = player:get_attribute('essentials.rules')
        if not agree or agree ~= 'true' then
            minetest.after(essentials.__settings.rulespause, essentials.open_rules, player:get_player_name())
        end
    end
end)

-- COMMANDS
minetest.register_chatcommand('erules', {
    params = 'none',
    description = S('show rules page'),
    privs = {erules = true},
    func = function(name, params) essentials.open_rules(name) end,
})
