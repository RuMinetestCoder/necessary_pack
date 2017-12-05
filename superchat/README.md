# superchat

Chat channels system, for the convenience of the players. Support filter url's, ip's, swear. Log path: %worldpath%/superchat.log

## Commands and privs

* **/chlist** - show channels list
* **/mch** - show you current channel
* **/omch [player]** - show player current channel (*scomch* priv)
* **/ch [channel]** - change you channel
* **/och [player] [channel]** - change player channel (*scoch* priv)
* **/chpref [prefix?]** - change or prefix (*scpref* priv)
* **/chopref [player] [prefix?]** - change or player prefix (*scopref* priv)
* **/chreload** - reload config (*screload* priv)

*scnofilter* - for not filtering messages

## Depends

* mod_configs
* gui_menu?
* initlib?

## API

* superchat.get_all_channels() - return string array
* superchat.get_virt_channels() - return string array (mods created channels)
* superchat.is_exists(ch) - return true or false
* superchat.is_virt_exists(ch) - return true or false (mods created channels)
* superchat.get_player_channels(player_name) - return nil or string array
* superchat.is_access(player_name, ch) - check access to channel, return true or false
* superchat.get_player_channel(player_name) - return nil or string, get current player channel
* superchat.send(player_name, channel, mess) - send message to channel
* superchat.change_channel(player_name, ch) - return true or false
* superchat.add_channel(name) - adding special channel for you mod, return true if success (false - name is exists)
* superchat.del_channel(name) - kick players from channel to default channel and delete special channel
* superchat.change_prefix(player_name, prefix) - return true or false
* superchat.get_prefix(player_name) - return nil or string
