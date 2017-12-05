# Necessary Mod Pack

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XPWULB42QVJCJ)

The most necessary mods. List:

* **Essentials** - more commands (spawn, warps, homes, mutes, bans, vanish and etc)
* **Bug Report** - GUI form for sending information to log
* **PVP Control** - protect newbies and other
* **Superchat** - chat channels and prefixes, filters
* **Stats** - server online statistic
* **Query** - easy socket server for sending server info
* **Coins** - easy money
* **Group Perms** - manage privs in player groups
* **Gui Menu** - convenient control buttons
* **Mod Configs** - libray for easy manage config files
* **Cuboids Lib** - libray for coordinate operitions

This modpack require librays from [luarocks](https://luarocks.org/). For using **mod_configs** and **query** need disable mod security.

```
#!shell

# for mod_configs
luarocks-5.1 install minifs
luarocks-5.1 install inifile
luarocks-5.1 install lyaml
luarocks-5.1 install rapidjson

# for query
luarocks-5.1 install effil
pacman -S lua51-socket
```

Read all readme's in mod folders for more information.
