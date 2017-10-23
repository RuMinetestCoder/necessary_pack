# pvp_control

Control pvp in server. On or off, death if exit in pvp, pvp toggle, newbies protect, protect cuboids and areas (optional).

## Commands and privs

* **/pvp** - toggle pvp mode (*pvptoggle* priv)
* **/opvp <player>** - toggle player pvp mode (*opvptoggle* priv)
* **/pvpon** - on pvp, off newbie protection (*pvpon* priv)
* **/opvpon <player>** - on pvp for player, off newbie protection (*opvpon* priv)
* **/pvpi <player>** - show pvp info (*pvpi* priv)

## API

* **pvp_control.is_pvp(player_name)** - get pvp mode (setting toggle command), return true or false
* **pvp_control.is_wait(player_name)** - check pvp waiting, return true if player wait before exit or false
* **pvp_control.is_newbie_protect(player_name)** - check newbie protecting, return true or false
* **pvp_control.toggle_pvp(player_name)** - toggle pvp mode, return true if pvp on or false
* **pvp_control.add_cuboid(name, cube, wait, pvp_mode)** - name - string, cube - from *cuboids_lib.get_cube*, wait - bool (if false, players not deathed if exit in pvp), pvp_mode - bool (if true, pvp allowed in cuboid, override *pvp* setting)
* **pvp_control.del_cuboid(name)** - del cuboid

## Depends

* mod_configs
* cuboids_lib
* areas?
* initlib?
