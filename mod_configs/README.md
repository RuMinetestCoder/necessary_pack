# mod_configs

This mod add easy support config files for mods. Formats:

* ini
* yaml 1.1
* json

## Require

* minifs
* inifile
* lyaml
* rapidjson

**Installation**

```
#!shell

luarocks-5.1 install minifs
luarocks-5.1 install inifile
luarocks-5.1 install lyaml
luarocks-5.1 install rapidjson
```

## API

```
#!lua

-- save ini config (dir - subdir name in conf dir, name - string key, data - table)
mod_configs.save_conf(dir, name, data)

-- load ini config (dir - subdir name in conf dir, name - string key), return table or nil
mod_configs.get_conf(dir, name)

-- save yaml config (dir - subdir name in conf dir, name - string key)
-- WARN! shit lib, not working :(
mod_configs.save_yaml(dir, name, data)

-- load yaml config (dir - subdir name in conf dir, name - string key), return table or nil
mod_configs.load_yaml(dir, name)

-- save json config (dir - subdir name in conf dir, name - string key)
mod_configs.save_json(dir, name, data)

-- load json config (dir - subdir name in conf dir, name - string key), return table or nil
mod_configs.load_json(dir, name)

-- create and get current mod dir
function mod_configs.get_path(mod)
```

**See details**

* [inifile](http://docs.bartbes.com/inifile)
* [lyaml](https://github.com/gvvaughan/lyaml)
