# gui_menu

Libray for create GUI menu. Only mods using.

## Commands

* **/menu** - open GUI (need 'guimenu' priv)

## Settings in minetest.conf

* **gui_menu.e** - true or false, for open GUI press E (aux1)

## API

```
#!lua

-- add button to GUI
-- menu_category - string, name of global category
-- button_name - string, for internal use
-- button_text - string, text on button
-- button_image - string, path to image file
-- button_func - function(player_name, [you_args])
-- returning table '{menu_category = {button_name = {text = button_text, image = button_image}}}' if not fields
-- (called from show GUI)
-- or table '{func = function(player, ...), args = {}}' if fields
-- (called from push button in GUI)
-- button_args - array, place after player (example array: '{"string_message"}', example function: 'function(player_name, text)')
gui_menu.add_button(menu_category, button_name, button_text, button_image, button_func, button_args)

-- set category button image
-- category - string, name of global category
-- image - string, path to image file
gui_menu.set_cat_image(category, image)

-- set you fromspec, show with open GUI menu
-- fromspec - string
gui_menu.set_formspec(player_name, formspec)

-- delete you fromspec
gui_menu.reset_formspec(player_name)

-- show category browse for player
gui_menu.show_cat(player_name, category)

-- show custom buttons set for player
-- buttons - table '{menu_category = {button_name = {text = button_text, image = button_image}}}'
gui_menu.show_buttons(player_name, category, buttons, page)

-- add function for calls from show GUI and push buttons
-- function(player_name, category, page, fields)
-- if not fields - call from open GUI, else - call from push button
gui_menu.add_listener(func)
```

### Examples

```
#!lua

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    gui_menu.add_listener(function(player_name, cat, page, fields)
        local function gh()
            local add = essentials.get_homes(player_name)
            if add then
                local result = {}
                result[S('Homes')] = {}
                for key, value in pairs(add) do
                    result[S('Homes')]['ess.home.' .. key] = {text = key}
                end
                return result
            end
        end
    
        if not cat and not fields then
            return gh()
        elseif not fields then return nil
        elseif fields['gui_menu:cat.' .. S('Homes')] then
            gui_menu.show_buttons(player_name, S('Homes'), gh()[S('Homes')], 1)
        elseif cat == S('Homes') and fields['gui_menu:pgo'] then
            gui_menu.show_buttons(player_name, S('Homes'), gh()[S('Homes')], page + 1)
        elseif cat == S('Homes') and fields['gui_menu:pback'] then
            gui_menu.show_buttons(player_name, S('Homes'), gh()[S('Homes')], page - 1)
        elseif cat == S('Homes') and fields then
            local function f(player, home)
                essentials.set_full_pos(player, essentials.get_home(player_name, home))
            end
            
            local homes = essentials.get_homes(player_name)
            if not homes then return nil end
            for key, value in pairs(homes) do
                if fields['ess.home.' .. key] then
                    return {func = f, args = {key}}
                end
            end
        end
    end)
end
```

```
#!lua

-- MENU SUPPORT
if minetest.global_exists('gui_menu') then
    for key in pairs(essentials.__warps) do 
        gui_menu.add_button(S('Warps'), 'ess.warp.' .. key, key, nil, essentials.warp, {key})
    end
end
```
