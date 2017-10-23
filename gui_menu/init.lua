gui_menu = {}
local buttons = {}
local names = {}
local formspec = {}
local players = {}
local images = {}
local listeners = {}
local cache = {}

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end

-- LOCAL FUNCTIONS
local function get_len(t)
    if not t and type(t) ~= 'table' then return 0 end
    local i = 0
    for key in pairs(t) do i = i + 1 end
    return math.ceil(i / 6 / 8)
end

local function get_page(cat, num, add)
    local result = 'size[20,9]'
    if num < 1 then num = 1 end
    local x, y, p = unpack({0, 0, 1})
    local t = {}
    if buttons[cat] then
        for key, value in pairs(buttons[cat]) do t[key] = value end
    end
    if add then -- add[menu_category][button_name] = {text = button_text, image = button_image}
        for key, value in pairs(add) do t[key] = value end
    end
    local len = get_len(t)
    if num > len then num = len end
    for key, value in pairs(t) do
        if p == num then
            if value.image then
                result = result .. 'image_button[' .. tostring(x) .. ',' .. tostring(y) .. ';3,1;' .. value.image .. ';'
                result = result .. key .. ';' .. value.text .. ']'
            else
                result = result .. 'button[' .. tostring(x) .. ',' .. tostring(y) .. ';3,1;'
                result = result .. key .. ';' .. value.text .. ']'
            end
        end
        if x == 15 then
            if y < 8 then y = y + 1
            else
                y = 0
                p = p + 1
            end
            x = 0
        else x = x + 3 end
    end
    result = result .. 'button[19,0;1,1;gui_menu:cat;^]' .. 'button[19,1;1,1;gui_menu:pgo;>]' .. 'button[19,2;1,1;gui_menu:pback;<]'
    return result .. 'label[19,3;' .. tostring(num) .. ']' .. 'label[19,4;/]label[19,5;' .. tostring(len) .. ']'
end

local function get_cat_page(num, add)
    local result = 'size[20,9]'
    if num < 1 then num = 1 end
    local x, y, p = unpack({0, 0, 1})
    local t = {}
    for key, value in pairs(buttons) do t[key] = value end
    if add then -- add[menu_category][button_name] = {text = button_text, image = button_image}
        for key, value in pairs(add) do t[key] = value end
    end
    local len = get_len(t)
    if num > len then num = len end
    for key in pairs(t) do
        if p == num then
            if images[key] then
                result = result .. 'image_button[' .. tostring(x) .. ',' .. tostring(y) .. ';3,1;' .. images[key] .. ';'
                result = result .. 'gui_menu:cat.' .. key .. ';' .. key .. ']'
            else
                result = result .. 'button[' .. tostring(x) .. ',' .. tostring(y) .. ';3,1;'
                result = result .. 'gui_menu:cat.' .. key .. ';' .. key .. ']'
            end
        end
        if x == 15 then
            if y < 8 then y = y + 1
            else
                y = 0
                p = p + 1
            end
            x = 0
        else x = x + 3 end
    end
    result = result .. 'button[19,0;1,1;gui_menu:cgo;>]' .. 'button[19,1;1,1;gui_menu:cback;<]'
    return result .. 'label[19,2;' .. tostring(num) .. ']' .. 'label[19,3;/]label[19,4;' .. tostring(len) .. ']'
end

local function call(player_name, cat, page, fields)
    local result = nil
    for _, func in ipairs(listeners) do
        local add = func(player_name, cat, page, fields)
        if add then
            if not result then result = {} end
            -- add: {menu_category = {button_name = {text = button_text, image = button_image}}}
            -- or
            -- add: {func = function(player, ...), args = {}}
            if fields then
                table.insert(result, add)
            else
                for key, value in pairs(add) do result[key] = value end
            end
        end
    end
    return result
end

local function show(player_name)
    if formspec[player_name] then
        minetest.show_formspec(player_name, 'gui_menu', formspec[player_name])
        return
    end
    if cache[player_name] then
        minetest.show_formspec(player_name, 'gui_menu', cache[player_name])
        --cache[player_name] = nil
        return
    end
    if not players[player_name] then players[player_name] = {page = 1} end
    if players[player_name].cat and not buttons[players[player_name].cat] then players[player_name].cat = nil end
    local add = call(player_name, players[player_name].cat, players[player_name].page, nil)
    if players[player_name].cat then
        minetest.show_formspec(player_name, 'gui_menu', get_page(players[player_name].cat, players[player_name].page, add))
    else
        minetest.show_formspec(player_name, 'gui_menu', get_cat_page(players[player_name].page, add))
    end
end

-- API
function gui_menu.add_button(menu_category, button_name, button_text, button_image, button_func, button_args)
    if not buttons[menu_category] then buttons[menu_category] = {} end
    buttons[menu_category][button_name] = {text = button_text, image = button_image}
    names[button_name] = {func = button_func, args = button_args}
end

function gui_menu.set_cat_image(cat, image)
    images[cat] = image
end

function gui_menu.set_formspec(player_name, str)
    formspec[player_name] = str
end

function gui_menu.reset_formspec(player_name)
    formspec[player_name] = nil
end

function gui_menu.show_cat(player_name, cat)
    players[player_name].cat = cat
    players[player_name].page = 1
    show(player_name)
end

function gui_menu.show_buttons(player_name, cat, buttons, page)
    players[player_name].cat = cat
    local len = get_len(buttons)
    if page > len then page = len end
    if page < 1 then page = 1 end
    players[player_name].page = page
    local fs = get_page(nil, page, buttons)
    minetest.show_formspec(player_name, 'gui_menu', fs)
    cache[player_name] = fs
end

function gui_menu.add_listener(func) -- func(player_name, category, page, fields)
    table.insert(listeners, func)
end

-- EVENTS
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == 'gui_menu' then
        local player_name = player:get_player_name()
        local t = call(player_name, players[player_name].cat, players[player_name].page, fields)
        if t then
            for k, v in pairs(t) do
                if v and v.func then
                    local args = v.args
                    if not args then args = {} end
                    table.insert(args, 1, player)
                    v.func(unpack(args))
                end
            end
            return true
        end
        if fields['gui_menu:cat'] then
            players[player_name].cat = nil
            players[player_name].page = 1
            cache[player_name] = nil
            show(player_name)
        elseif fields['gui_menu:pgo'] then
            if players[player_name].page >= get_len(buttons[players[player_name].cat]) then return true end
            players[player_name].page = players[player_name].page + 1
            show(player_name)
        elseif fields['gui_menu:pback'] then
            if players[player_name].page <= 1 then return true end
            players[player_name].page = players[player_name].page - 1
            show(player_name)
        elseif fields['gui_menu:cgo'] then
            if players[player_name].page >= get_len(buttons) then return true end
            players[player_name].page = players[player_name].page + 1
            show(player_name)
        elseif fields['gui_menu:cback'] then
            if players[player_name].page <= 1 then return true end
            players[player_name].page = players[player_name].page - 1
            show(player_name)
        else
            for key in pairs(buttons) do
                if fields['gui_menu:cat.' .. key] then
                    players[player_name].cat = key
                    players[player_name].page = 1
                    show(player_name)
                    return true
                end
            end
            for key, value in pairs(names) do
                if fields[key] then
                    local args = value.args
                    if not args then args = {} end
                    table.insert(args, 1, player)
                    value.func(unpack(args))
                    break
                end
            end
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    players[player_name] = nil
    cache[player_name] = nil
end)

minetest.register_globalstep(function(dtime)
    if not minetest.setting_getbool('gui_menu.e') then return end
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_player_control()['aux1'] then
            show(player:get_player_name())
        end
    end
end)

-- REGISTRATIONS
minetest.register_privilege('guimenu', S('Can use /menu'))

-- COMMANDS
minetest.register_chatcommand('menu', {
	params = 'none',
	description = S('open GUI menu'),
	privs = {guimenu = true},
	func = function(name, text)
		show(name)
		return true, S('Server GUI menu is open')
	end,
})
