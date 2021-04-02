ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 


--[[RegisterCommand('createroute', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = args[1]
    local money = args[2]
    if xPlayer.getGroup() == 'admin' then
        if money == nil then
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Introduce una cantidad valida de dinero')
        else
            print(name)
            print(money)
            MySQL.Async.execute('INSERT INTO truckerroutes (name, coords, money) VALUES (@name, @coords, @money)', {
                ['@name'] = name,
                ['@coords'] = json.encode(xPlayer.getCoords()),
                ['@money'] = money,
            })
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Has creado una ruta con el nombre ' ..name.. ' y con el sueldo de ' ..money)
        end
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'No tienes permiso para usar este comando')
    end
end, false)]]

ESX.RegisterServerCallback('guille_trucker:getRoutes', function(source,cb)
    MySQL.Async.fetchAll('SELECT * FROM truckroutes',{}, function(result)
        local elements = {}
        for i = 1, #result, 1 do
            table.insert(elements, {['name'] = result[i]['titulo'], ['points'] = result[i]['points'], ['money'] = result[i]['money'], ['id'] = result[i]['id'] })
        end
        cb(elements)
    end)
end)

ESX.RegisterServerCallback('guille_trucker:selectRoute', function(source,cb,name)
    MySQL.Async.fetchAll('SELECT * FROM truckerroutes WHERE name = @name',{
        ['@name'] = name
    }, function(result)
        local elements = {}
        for i = 1, #result, 1 do
            table.insert(elements, {['name'] = result[i]['name'], ['coords'] = json.decode(result[i]['coords']), ['money'] = result[i]['money'], ['id'] = result[i]['id'] })
        end
        cb(elements)
    end)
end)

ESX.RegisterServerCallback('guille_trucker:getRoutesStart', function(source,cb,name)
    MySQL.Async.fetchAll('SELECT * FROM truckroutes WHERE titulo = @name',{
        ['@name'] = name
    }, function(result)
        local elements = {}
        for i = 1, #result, 1 do
            table.insert(elements, {['name'] = result[i]['titulo'], ['points'] = result[i]['points'], ['money'] = result[i]['money'], ['id'] = result[i]['id'] })
        end
        cb(elements)
    end)
end)

RegisterCommand('addroute', function(source, args) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local points = tonumber(args[1])
    local name = args[2]
    local money = tonumber(args[3])
    if xPlayer.getGroup() == 'admin' then
        if type(points) == 'number' then
                if type(name) == 'string' then
                    if type(money) == 'number' then
                        MySQL.Async.execute('INSERT INTO truckroutes (points, titulo, owner, money) VALUES (@points, @titulo, @owner, @money)', {
                            ['@points'] = points,
                            ['@titulo'] = name,
                            ['@owner'] = xPlayer.getIdentifier(),
                            ['@money'] = money,
                        })
                        TriggerClientEvent('esx:showNotification', source, 'You started the route creation with ' ..points.. ' points and with the name ' ..name)
                        TriggerClientEvent('guille_trucker:createroute', source, name, points)
                    else
                        TriggerClientEvent('esx:showNotification', source, 'The value must be a number')
                    end
                else
                    TriggerClientEvent('esx:showNotification', source, 'The value must be a string')
                end
            else
                TriggerClientEvent('esx:showNotification', source, 'The value must be a number')
            end
       end
end, false)

RegisterServerEvent('guille_startroutes')
AddEventHandler('guille_startroutes', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('guille_trucker:getroutes', xPlayer.source)
end)

RegisterCommand('seeroutes', function(source, args) 
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() == 'admin' then
        TriggerClientEvent('guille_trucker:getRout', xPlayer.source)
    end

end, false)

RegisterCommand('deleteroute', function(source, args) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = args[1]
    if xPlayer.getGroup() == 'admin' then
        MySQL.Async.execute('DELETE FROM truckroutes WHERE titulo = @titulo', {
            ['@titulo'] = name   
        })
        MySQL.Async.execute('DELETE FROM truckerroutes WHERE name = @name', {
            ['@name'] = name   
        })
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You deleted the route ' ..name)
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'No perms :(')
    end

end, false)

RegisterServerEvent('guille_trucker:pay')
AddEventHandler('guille_trucker:pay', function(money)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addMoney(money)

    TriggerClientEvent('esx:showNotification', xPlayer.source, 'For your work you received ' .. money .. '$, come back when you want')

end)

RegisterServerEvent('guille_trucker:addpointtoroute')
AddEventHandler('guille_trucker:addpointtoroute', function(name, point)
    local xPlayer = ESX.GetPlayerFromId(source)
    local position = xPlayer.getCoords()
    MySQL.Async.execute('INSERT INTO truckerroutes (name, coords, point) VALUES (@name, @coords, @point)', {
        ['@name'] = name,
        ['@coords'] = json.encode(position),
        ['@point'] = point,
    })
end)
