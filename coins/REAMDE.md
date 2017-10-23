# coins

Easy coins (game money) system. Log path: %worldpath%/coins.log

## Commands and privs

* **/bal** - show you balance (*coinsbal* priv)
* **/pay <player> <number>** - pay coins to player (*coinspay* priv)
* **/obal <player>** - show player balance (*coinsobal* priv)
* **/bset <player> <number>** - set player balance (*coinsbset* priv)
* **/btake <player> <number>** - take coins from player (*coinsbtake* priv)
* **/bgive <player> <number>** - give coins to player (*coinsbgive* priv)

## Depends

* initlib?

## API

* function coins.get_coins(player_name) - return nil or number
* function coins.set_coins(player_name, num) - return true or false
* function coins.add_cons(player_name, num) - return nil or number (new balance)
* function coins.take_coins(player_name, num) - return nil or number (new balance)
