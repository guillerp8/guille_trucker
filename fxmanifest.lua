fx_version 'adamant'

game 'gta5'

author 'guillerp#1928'

client_scripts {
    'client/main.lua',
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
    'config.lua'
}

ui_page 'ui/index.html'

files {
    'ui/script.js',
    'ui/style.css',
    'ui/index.html',
    'ui/bankgothic.ttf'
}