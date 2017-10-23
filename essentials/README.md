# essentials

Adding a lot commands. Config path: world/configs/essentials/settings.yml

*Writing in progress...*

## depends

* mod_configs
* gui_menu?
* group_perms?
* initlib?

## Commands and privs

### Spawn

* **/spawn** - teleport to spawn point (*spawn* priv)
* **/nspawn** - teleport to newbie spawn point (*nspawn* priv)
* **/setspawn** - set spawn point and newbie spawn point (if nspawn not set) (*setspawn* priv)
* **/setnspawn** - set newbie spawn point (*setnspawn* priv)
* **/delspawn** - delete spawn point (*setspawn* priv)
* **/delnspawn** - delete newbie spawn point (*setnspawn* priv)
* **/tospawn <player>** - teleport player to spawn point (*tospawn* priv)
* **/tonspawn <player>** - teleport player to newbie spawn point (*tonspawn* priv)

### Warps

* **/warp <warp>** - teleport to warp point (*warp* priv)
* **/towarp <player> <warp>** - teleport player to warp point (*towarp* priv)
* **/warps** - show warps list (*warps* priv)
* **/mywarps** - show you warps list (*mywarps* priv)
* **/pwarps <player>** - show player warps list (*pwarps* priv)
* **/setwarp <warp>** - set warp point (*setwarp* priv)
* **/delwarp <warp>** - delete warp point (*delwarp* priv)

**More privs**

* *setwarpnl* - for unlimited set warp
* *delallwarps* - for deleting all warps (bypass owner)

### Kits

* **/kit <name>** - give kit to you (*kit* priv)
* **/gkit <player> <name>** - give git to player (*gkit* priv)
* **/kits** - show kits list (*kits* priv)
* **/rkit <player> <name>** - reset kit pause for player (*rkit* priv)
* **/pkit <player> <name>** - show kit pause for player (*pkit* priv)

**More privs**

* *kitnopause* - exempt waiting timer

### Vanish

* **/v** - toggle vanish (*vanish* priv)
* **/ov <player>** - toggle player vanish (*ovanish* priv)

### Teleport

#### For admins

* **/tp <player>** - teleport you to player (*teleport* priv)
* **/ftp <player>** - force teleport you to player (exempt find empty point) (*fteleport* priv)
* **/otp <player> <player>** - teleport player to player (*oteleport* priv)
* **/fotp <player> <player>** - force teleport player to player (exempt find empty point) (*foteleport* priv)
* **/s <player>** - teleport player to you (*selftp* priv)
* **/fs <player>** force teleport player to you (exempt find empty point) (*fselftp* priv)
* **/top <nodes?>** - teleport to top position (*top* priv)
* **/down <nodes?>** teleport to down position (*down* priv)

#### Call system

* **/call <player>** - send request teleport you to player (*call* priv)
* **/scall <player>** - send request teleport player to you (*scall* priv)
* **/ty** - allow teleport request (*call* priv)
* **/tn** - deny teleport request (*call* priv)

**More privs**

* *callv* - for call vanished players

### Players list

* **/list** - show players list (*list* priv)

**More privs**

* *hlist* - show vanished players

### Server messages

* **/say <message>** - say message (*say* priv)
* **/bro <message>** - broadcast message (*broadcast* priv)

**More privs**

* *ssay* - for show say messages
* *sbroadcst* - for show broadcast messages

### Fake join/leave

* **/fe** - send fake leave message (*fakeexit* priv)
* **/fj** - send fake join message (*fakejoin* priv)

### Homes

* **/ehome <name>** - teleport to home point (*ehome* priv)
* **/ehomes** - show homes list (*ehome* priv)
* **/esethome <name>** - set home point (*ehome* priv)
* **/eohome <player> <name>** - teleport to player home point (*eohome* priv)
* **/eohomes <player>** - show player homes list (*ehome* priv)
* **/eosethome <player> <name>** - set the home point for other player (*eosethome* priv)
* **/edelhome <name>** - delete home point (*ehome* priv)
* **/eodelhome <player> <name>** - delete player home point (*eodelhome* priv)

### Mutes

* **/mute <player> <time> <reason>** - mute player (*mute* priv)
* **/unmute <player>** - unmute player (*mute* priv)

**More privs**

* *mutesee* - show mute notify in chat
* *exmute* - exempt mute

### Bans

* **/eban <player> <reason>** - ban player (*eban* priv)
* **/eunban <player>** - pardon player (*eban* priv)
* **/etempban <player> <time> <reason>** - temp ban player (*etempban* priv)
* **/ebanip <ip> <reason>** - ban ip (*ebanip* priv)
* **/eunbanip <ip>** - pardon ip (*ebanip* priv)
* **/etempbanip <ip> <time> <ip>** - temp ban ip (*etempbanip* priv)
* **/eibanip <ip>** - show ban ip info (*eibanip* priv)

**More privs**

* *ebansee* - show ban notify in chat
* *exeban* - exempt ban

### Kick

* **/ekick <player> <reason>** - kick player (*ekick* priv)

**More privs**

* *exekick* - exempt kick

### Help and rules

* **/ehelp** - show help GUI (*ehelp* priv)
* **/erules** - show rules GUI (*erules* priv)
* **/ehupdate** - update txt files list (*ehupdate* priv)

### AFK

* **/afk** - toggle AFK (*eafk* priv)

### Whois

* **/whois <player>** - show player information (*whois* priv)

**More privs**

* *exwhois* - exempt whois

### Chat

* **/m <player> <message>** - send private message
* **/espy** - toggle spy mode (reding private messages) (*espy* priv)

**More privs**

* *ftell* - sending private messages to vanished players
* *exespy* - exempt spy mode

### TPS

* **/etps** - show TPS (*etps* priv)
* **/eover** - show overload information (*etps* priv)

### Show itemstring

* **/dura** - show itemstring in hand (*edura* priv)

### Other privs

* *deathpos* - show death position in chat
