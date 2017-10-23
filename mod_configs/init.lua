local fs = require 'minifs'
local inifile = require 'inifile'
local lyaml = require 'lyaml'
local json = require 'rapidjson'

mod_configs = {}

local sep = fs.separator()
local path = minetest.get_worldpath() .. sep .. 'configs'

local function create_dir(dir_path, subdir)
    if not fs.exists(dir_path) then fs.mkdir(dir_path) end
    local sd_path = dir_path .. sep .. subdir
    if not fs.exists(sd_path) then fs.mkdir(sd_path) end
end

-- [function] save ini config (dir - subdir name in conf dir, name - string key, data - table)
function mod_configs.save_conf(dir, name, data)
    create_dir(path, dir)
    local conf_path = path .. sep .. dir .. sep .. name .. '.conf'
    inifile.save(conf_path, data)
end

-- [function] load ini config (dir - subdir name in conf dir, name - string key), return table or nil
function mod_configs.get_conf(dir, name)
    local conf_path = path .. sep .. dir .. sep .. name .. '.conf'
    if not fs.exists(conf_path) then return nil end
    return inifile.parse(conf_path)
end

-- [function] save yaml config (dir - subdir name in conf dir, name - string key)
function mod_configs.save_yaml(dir, name, data)
    create_dir(path, dir)
    local yaml_path = path .. sep .. dir .. sep .. name .. '.yml'
    fs.write(yaml_path, lyaml.dump(data))
end

-- [function] load yaml config (dir - subdir name in conf dir, name - string key), return table or nil
function mod_configs.load_yaml(dir, name)
    local yaml_path = path .. sep .. dir .. sep .. name .. '.yml'
    if not fs.exists(yaml_path) then return nil end
    return lyaml.load(fs.read(yaml_path))
end

-- [function] save json config (dir - subdir name in conf dir, name - string key)
function mod_configs.save_json(dir, name, data)
    create_dir(path, dir)
    local json_path = path .. sep .. dir .. sep .. name .. '.json'
    json.dump(data, json_path)
end

-- [function] load json config (dir - subdir name in conf dir, name - string key), return table or nil
function mod_configs.load_json(dir, name)
    local json_path = path .. sep .. dir .. sep .. name .. '.json'
    if not fs.exists(json_path) then return nil end
    return json.load(json_path)
end

-- [function] create and get current mod dir
function mod_configs.get_path(mod)
    create_dir(path, mod)
    return path .. sep .. mod
end
