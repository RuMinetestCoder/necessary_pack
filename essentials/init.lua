local fs = require 'minifs'

essentials = {}

local sep = package.path:match('(%p)%?%.')
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- LOAD CONFIG
function essentials.__load_configs()
    local path_settings = mod_configs.get_path('essentials') .. sep .. 'settings.yml'
    if not fs.exists(path_settings) then
        fs.copy(modpath .. sep .. 'configs' .. sep .. 'settings.yml', path_settings)
    end
    local path_kits = mod_configs.get_path('essentials') .. sep .. 'kits.yml'
    if not fs.exists(path_kits) then
        fs.copy(modpath .. sep .. 'configs' .. sep .. 'kits.yml', path_kits)
    end
    essentials.__settings = mod_configs.load_yaml('essentials', 'settings')
    essentials.__spawn = mod_configs.load_json('essentials', 'spawn')
    essentials.__warps = mod_configs.load_json('essentials', 'warps')
    essentials.__kits = mod_configs.load_yaml('essentials', 'kits')
    essentials.__jails = mod_configs.load_json('essentials', 'jails')
    essentials.__ban = mod_configs.load_json('essentials', 'ban')
    essentials.__banip = mod_configs.load_json('essentials', 'banip')
    if not essentials.__spawn then essentials.__spawn = {} end
    if not essentials.__warps then essentials.__warps = {} end
    if not essentials.__jails then essentials.__jails = {} end
    if not essentials.__ban then essentials.__ban = {} end
    if not essentials.__banip then essentials.__banip = {} end
end
essentials.__load_configs()

-- SET PATHS
local path_logs = mod_configs.get_path('essentials') .. sep .. 'logs'
if not fs.exists(path_logs) then fs.mkdir(path_logs) end
essentials.__path_mutelog = path_logs .. sep .. 'mutes.log'
essentials.__path_banlog = path_logs .. sep .. 'bans.log'
essentials.__path_kicklog = path_logs .. sep .. 'kicks.log'
essentials.__path_help = mod_configs.get_path('essentials') .. sep .. 'help.txt'
essentials.__path_help_folder = mod_configs.get_path('essentials') .. sep .. 'help'
if not fs.exists(essentials.__path_help) then
    fs.copy(modpath .. sep .. 'configs' .. sep .. 'help.txt', essentials.__path_help)
end
if not fs.exists(essentials.__path_help_folder) then
    fs.mkdir(essentials.__path_help_folder)
end
essentials.__path_rules = mod_configs.get_path('essentials') .. sep .. 'rules.txt'
if not fs.exists(essentials.__path_rules) then
    fs.copy(modpath .. sep .. 'configs' .. sep .. 'rules.txt', essentials.__path_rules)
end

-- INITLIB
local S, NS
if minetest.global_exists('intllib') then
    S, NS = intllib.make_gettext_pair(minetest.get_current_modname())
else
    S = function(s) return s end
    NS = S
end
essentials._initlib = S

-- REGISTRATION PRIVS
minetest.register_privilege('spawn', S('Can use /spawn'))
minetest.register_privilege('nspawn', S('Can use /spawn'))
minetest.register_privilege('setspawn', S('Can use /setspawn and /delspawn'))
minetest.register_privilege('setnspawn', S('Can use /setnspawn and /delnspawn'))
minetest.register_privilege('tospawn', S('Can use /tospawn'))
minetest.register_privilege('tonspawn', S('Can use /tonspawn'))
minetest.register_privilege('warp', S('Can use /warp'))
minetest.register_privilege('towarp', S('Can use /towarp'))
minetest.register_privilege('warps', S('Can use /warps'))
minetest.register_privilege('mywarps', S('Can use /mywarps'))
minetest.register_privilege('pwarps', S('Can use /pwarps'))
minetest.register_privilege('setwarp', S('Can use /setwarp'))
minetest.register_privilege('setwarpnl', S('Can unlimited setwarp'))
minetest.register_privilege('delwarp', S('Can use /delwarp'))
minetest.register_privilege('delallwarps', S('Can use /delwarp for all warps'))
minetest.register_privilege('kit', S('Can use /kit'))
minetest.register_privilege('kitnopause', S('Can use /kit, exlude pause'))
minetest.register_privilege('pkit', S('Can use /pkit'))
minetest.register_privilege('kits', S('Can use /kits'))
minetest.register_privilege('rkit', S('Can use /rkit'))
minetest.register_privilege('gkit', S('Can use /gkit'))
minetest.register_privilege('vanish', S('Can use /v'))
minetest.register_privilege('ovanish', S('Can use /ov'))
--minetest.register_privilege('weight', S('Can use /w'))
--minetest.register_privilege('oweight', S('Can use /ow'))
--minetest.register_privilege('rweight', S('Can use /pw'))
minetest.register_privilege('teleport', S('Can use /tp'))
minetest.register_privilege('fteleport', S('Can use /ftp'))
minetest.register_privilege('oteleport', S('Can use /otp'))
minetest.register_privilege('foteleport', S('Can use /fotp'))
minetest.register_privilege('selftp', S('Can use /s'))
minetest.register_privilege('fselftp', S('Can use /fs'))
minetest.register_privilege('call', S('Can use /call'))
minetest.register_privilege('scall', S('Can use /scall'))
minetest.register_privilege('callv', S('Can use /call for vanished'))
minetest.register_privilege('top', S('Can use /top'))
minetest.register_privilege('down', S('Can use /down'))
minetest.register_privilege('list', S('Can use /list'))
minetest.register_privilege('hlist', S('Can show hide players in /list'))
minetest.register_privilege('broadcast', S('Can use /bro'))
minetest.register_privilege('say', S('Can use /say'))
minetest.register_privilege('sbroadcast', S('Can show mess from /bro'))
minetest.register_privilege('ssay', S('Can show mess from /say'))
--minetest.register_privilege('heal', S('Can use /heal'))
--minetest.register_privilege('kill', S('Can use /kill'))
--minetest.register_privilege('slap', S('Can use /slap'))
--minetest.register_privilege('backspace', S('Can use /bc'))
--minetest.register_privilege('inv', S('Can use /inv'))
--minetest.register_privilege('deathtool', S('Can use /dt'))
--minetest.register_privilege('thor', S('Can use /thor'))
minetest.register_privilege('fakeexit', S('Can use /fe'))
minetest.register_privilege('fakejoin', S('Can use /fj'))
--minetest.register_privilege('jail', S('Can use /jail'))
--minetest.register_privilege('setjail', S('Can use /setjail'))
minetest.register_privilege('ehome', S('Can use /ehome and other'))
minetest.register_privilege('ehomenl', S('Can ehome unlimited'))
minetest.register_privilege('eohome', S('Can use /eohome and other'))
minetest.register_privilege('eosethome', S('Can use /eosethome'))
minetest.register_privilege('eodelhome', S('Can use /eodelhome'))
minetest.register_privilege('mute', S('Can use /mute and other'))
minetest.register_privilege('mutesee', S('Can see mute messagess'))
minetest.register_privilege('exmute', S('Can exempt of /mute'))
minetest.register_privilege('eban', S('Can use /eban and other'))
minetest.register_privilege('ebansee', S('Can see ban messages'))
minetest.register_privilege('etempban', S('Can use /etempban and other'))
minetest.register_privilege('exeban', S('Can exempt of /eban and other'))
minetest.register_privilege('ebanip', S('Can use /ebanip and other'))
minetest.register_privilege('etempbanip', S('Can use /etempbanip and other'))
minetest.register_privilege('eibanip', S('Can use /eibanip'))
minetest.register_privilege('ekick', S('Can use /ekick'))
minetest.register_privilege('exekick', S('Can exempt of /ekick'))
minetest.register_privilege('ekicksee', S('Can see kick messages'))
minetest.register_privilege('ehelp', S('Can use /ehelp'))
minetest.register_privilege('erules', S('Can use /erules'))
minetest.register_privilege('ehupdate', S('Can use /ehupdate'))
minetest.register_privilege('eafk', S('Can use /afk'))
--minetest.register_privilege('phys', S('Can use /phys'))
--minetest.register_privilege('ophys', S('Can use /ophys'))
--minetest.register_privilege('speed', S('Can use /speed'))
--minetest.register_privilege('ospeed', S('Can use /ospeed'))
--minetest.register_privilege('jump', S('Can use /jump'))
--minetest.register_privilege('ojump', S('Can use /ojump'))
--minetest.register_privilege('grav', S('Can use /grav'))
--minetest.register_privilege('sneak', S('Can use /sneak'))
--minetest.register_privilege('osneak', S('Can use /osneak'))
--minetest.register_privilege('sglitch', S('Can use /sglitch'))
--minetest.register_privilege('osglitch', S('Can use /osglitch'))
minetest.register_privilege('whois', S('Can use /whois'))
minetest.register_privilege('exwhois', S('Can exempt of whois see'))
--minetest.register_privilege('gm', S('Can use /gm'))
--minetest.register_privilege('hp', S('Can use /hp'))
--minetest.register_privilege('sethp', S('Can use /sethp'))
--minetest.register_privilege('ptime', S('Can use /ptime'))
--minetest.register_privilege('optime', S('Can use /optime'))
--minetest.register_privilege('size', S('Can use /size'))
--minetest.register_privilege('osize', S('Can use /osize'))
--minetest.register_privilege('rsize', S('Can use /rsize'))
minetest.register_privilege('ftell', S('Can use /m to vanished'))
minetest.register_privilege('espy', S('Can use /espy'))
minetest.register_privilege('exespy', S('Can exempt of /espy'))
minetest.register_privilege('etps', S('Can use /etps and other'))
--minetest.register_privilege('eback', S('Can use /back'))
minetest.register_privilege('deathpos', S('Can see death position'))
minetest.register_privilege('ehello', S('Can see hello newbies'))
minetest.register_privilege('edura', S('Can use /dura'))

-- INCLUDE MODULES
dofile(modpath .. sep .. 'modules' .. sep .. 'utils.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'spawn.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'warps.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'kits.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'vanish.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'teleport.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'plist.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'say.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'homes.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'mute.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'ban.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'kick.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'help.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'rules.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'fake.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'whois.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'tell.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'tps.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'death.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'hello.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'dura.lua')
dofile(modpath .. sep .. 'modules' .. sep .. 'afk.lua')
