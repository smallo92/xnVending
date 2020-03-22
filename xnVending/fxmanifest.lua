fx_version 'adamant'
games { 'gta5' }

name 'xnVending'
author 'smallo92'
contact 'https://github.com/smallo92/'
download 'https://github.com/smallo92/xnVending'
description 'Allows players to use vending machines'

server_scripts {
	'config.lua',
	'@vrp/lib/utils.lua', -- for vRP Compatibility
	'server/server.lua'
}

client_scripts {
	'config.lua',
	'client/vrp_proxy.lua', -- for vRP Compatibility
	'client/client.lua'
}
