# grop_pems

This mod for easy manage privs, sorted in custom groups.

## Config files

* [you world dir]/configs/group_perms/settings.conf - settings this mod
* [you world dir]/configs/group_perms/perms.conf - manage groups

### settings.conf

* **default_group** option - name initial add group, giving all new players
* **new_player_method** option - *set* or *add*; set - only group privs, add - add from group privs

### perms.conf

Easy example:

```
#!ini

[default]
interact=true
shout=true
privs=true

[stuff]
zoom=true
```

## Commands

/perms add [player] [group] - add player to group
/perms set [player] [group] - remove player from all groups, set only selected group
/perms del [player] [group] - remove player from selected group
/perms-groups [player] - show player groups list
/perms-show - show all available groups
/perms-reload - reload all config files

## Privs

* **perms** - for manage groups (acces to commands)

## Depends

* **mod_configs**
* **initlib?**

## API

* *group_perms.get_group_privs(group)* - return table privs ([priv]=true/false) or nil
* *group_perms.group_exists(group)* - true or false
* *group_perms.get_groups()* - return array (table [number]=string)
* *group_perms.add_to_group(player_name, group)* - add player to group, return true or false
* *group_perms.set_group(player_name, group)* - set player group, return true or false
* *group_perms.rem_from_group(player_name, group)* - remove player from group, return true or false
* *group_perms.get_player_groups(player_name)* - return array (table [number]=string) or nil
* *group_perms.check_player_group(player_name, group)* - return true if player in group or false
* *group_perms._reload()* - call reload configs

### Example

```
#!lua

if minetest.player_exists('InterVi') then
    local my_privs = minetest.get_player_privs('InterVi')
    if minetest.global_exists('group_perms') and group_perms.group_exists('admins') then
        my_privs = group_perms.get_group_privs('admins')
    end
end
```
