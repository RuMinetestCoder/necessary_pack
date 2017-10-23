# query

Add statistic socket server.

## Commands and privs

Need *queryadm* priv.

* **/querystart**
* **/querystop**
* **/queryreload** - reload settings from config file

## Requires

* [effil](https://github.com/effil/effil)
* [socket](https://github.com/diegonehab/luasocket)

```
#!shell

luarocks-5.1 install effil
pacman -S lua51-socket
```

## Depends

* mod_configs
* initlib?

## Code example

```
#!python
import socket

s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(('localhost', 20500))

data = s.recv(4096)
if data:
    text = data.decode()
    print('Received: ' + text)
s.close()
```
