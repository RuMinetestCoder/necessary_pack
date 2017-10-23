# stats

Player statistic per 24 hours:

* Unique nicks;
* Unique IPs;
* Newbies;
* Average online time in seconds.

Log path: %worldpath%/stats.log

## Commands and privs

* **/stat** - show info (need *showstat* priv)

## API

* *stats.get_stat()* - return table "{nicks = number, ips = number, newbies = number, online = number}"

## Depends

* mod_configs
* initlib?
