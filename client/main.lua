-- Core

ESX = nil 
Citizen.CreateThread(function() 
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Citizen.Wait(0) 
    end 
    createPed()
    startJob()
end)

-- Fin core

-- Variables

local done = 1
local money = 0

-- Fin variables

-- Threads

-- Fin threads

-- Functions

function createPed()
    startblip = AddBlipForCoord(Config.jobBlip)
    SetBlipSprite(startblip, 318)
    SetBlipColour(startblip, 51)
    SetBlipScale(startblip, 0.8)
    SetBlipAsShortRange(startblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.blipText)
    EndTextCommandSetBlipName(startblip)

    local ped = GetHashKey('s_m_m_trucker_01')
    RequestModel(ped)

    while not HasModelLoaded(ped) do
        Citizen.Wait(1)
    end

    local cped = CreatePed("PED_TYPE_CIVMALE", ped, Config.pedCoords, Config.pedHeading, false, false)
    SetEntityAsMissionEntity(cped, true, true)
    FreezeEntityPosition(cped, true)
    SetEntityInvincible(cped, true)
    SetBlockingOfNonTemporaryEvents(cped, true)
end

function startJob()
    
    local s = true
    while s do
        local wait = 1000
        local pedcoords = GetEntityCoords(PlayerPedId())
        local dist = GetDistanceBetweenCoords(pedcoords, Config.pedCoords, true)

        if dist < 3 then
            wait = 0
            ESX.ShowFloatingHelpNotification('Presiona ~r~E~w~ para hablar con el camionero', Config.pedCoords + vector3(0,0,0+2))
            if IsControlJustPressed(1, 38) then
                getMenu()
                s = false
            end
        end
        Citizen.Wait(wait)
    end

end

function getMenu()
    ESX.TriggerServerCallback('guille_trucker:getRoutes', function(result)

        local elements = {}
        for i = 1, #result, 1 do
            table.insert(elements, {
                label = '' .. result[i]['name'] .. ' - ' .. result[i]['money'] .. '$',
                value = {name = result[i]['name'], money = result[i]['money'], points = result[i]['points']}
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_routes', {
            title = ('Rutas'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            startRoute(data.current.value['name'], data.current.value['money'], data.current.value['points'])
            --print(data.current.value['coords']['x'] .. ' ' .. data.current.value['money'] .. ' ' .. data.current.value['name'])
        end, function(data, menu)
            menu.close()
            startJob()
        end)
    end)
end

function startRoute(name, money, points)
    ESX.UI.Menu.CloseAll()
    SendNUIMessage({
        show = false; 
        route = name; 
    })

    ESX.ShowNotification('Esperate a que el jefe llegue con el camión, los suministros son aleatorios')
    Citizen.Wait(900)
    ESX.ShowNotification('Si hay un vehículo en el punto de entrega va a tardar más')
    Citizen.Wait(900)
    ESX.ShowNotification('Tienes un indicador abajo a la derecha que te dirá que hacer.')
    while IsAnyVehicleNearPoint(Config.deliverCoords, 6.0) do
        Citizen.Wait(0)
    end
    local hash = GetHashKey('hauler')
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(1)
    end
    local vehicle = CreateVehicle('hauler', Config.truckSpawn, Config.truckHeading, true, true)
    Citizen.Wait(1500)
    local randomtruck = math.random(1,10)
    local hash2 = GetHashKey(Config.Trailers[randomtruck])
    RequestModel(hash2)
    print(Config.Trailers[randomtruck])
    while not HasModelLoaded(hash2) do
        Citizen.Wait(1)
    end
    local trailerobj = CreateVehicle(hash2, Config.trailerSpawn, 0.0, true, false)
    local heading = GetEntityHeading(vehicle)
    SetEntityHeading(trailerobj, heading)
    SetEntityAsMissionEntity(trailerobj, true, true)
    AttachVehicleToTrailer(vehicle, trailerobj, 1.1)
    local ped = GetHashKey('s_m_m_trucker_01')
    RequestModel(ped)

    while not HasModelLoaded(ped) do
        Citizen.Wait(1)
    end

    local cped = CreatePedInsideVehicle(vehicle, "PED_TYPE_CIVMALE", ped, -1, true, false)
    TaskVehicleDriveToCoordLongrange(cped, vehicle, Config.deliverCoords, 30.0, 319, 5.0)
    Citizen.Wait(Config.arriveTime)
    TaskLeaveAnyVehicle(cped, true, true)
    ESX.ShowNotification('El jefe te ha dejado el camión, ve a recogerlo y empieza la ruta ' ..name)

    TaskGoToCoordAnyMeans(cped, Config.byeCoords, 0.2, 0, 0, 786603, 0xbf800000)
    
    while true do
        local ped = PlayerPedId(-1)
        if IsPedInVehicle(ped, vehicle, true) then
            if IsVehicleAttachedToTrailer(vehicle) then
                ESX.ShowNotification('Dirigete a la ubicación marcada en el mapa')
                DeletePed(cped)
                routeStartNow(name, money, points, vehicle)
                
                break
            end
        end
        if not DoesEntityExist(vehicle) then
            ESX.ShowNotification('El vehículo ha sido destruido')
            SendNUIMessage({
                show = true; 
            })
            startJob()
            break
        end
        Citizen.Wait(0)
    end

end

function routeStartNow(name, money, points, vehicle)

    ESX.TriggerServerCallback('guille_trucker:selectRoute', function(result)
        local selectedroute = {}
        local maxpoints = points
        local money = money
        for i = 1, #result, 1 do
            table.insert(selectedroute, result[i]['coords'])
        end
        print(done)
        routeblip = AddBlipForCoord(selectedroute[done]['x'], selectedroute[done]['y'], selectedroute[done]['z'])
        SetBlipRoute(routeblip, true)
        SetBlipScale(routeblip, 0.8)
        SetBlipColour(routeblip, 1)
        SetBlipRouteColour(routeblip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(routeblip)
        while true do
            local pedcoords = GetEntityCoords(PlayerPedId())
            local wait = 1500
            local dist = GetDistanceBetweenCoords(pedcoords, selectedroute[done]['x'], selectedroute[done]['y'], selectedroute[done]['z'], true)
            print(done)
            print(maxpoints)
            if dist < 20 then
                print("yes")
                wait = 0
                DrawMarker(1, selectedroute[done]['x'], selectedroute[done]['y'], selectedroute[done]['z']-0.95, 0, 0, 0, 0, 0, 0, 5.0000, 5.0000, 0.6001,255,0,0, 200, 0, 0, 0, 0)
                ESX.ShowFloatingHelpNotification('Presiona ~r~E~w~ para entregar la mercancia', vector3(selectedroute[done]['x'], selectedroute[done]['y'], selectedroute[done]['z']))
                if dist < 10 and IsVehicleAttachedToTrailer(vehicle)  then
                    if IsControlJustPressed(1, 38) then
                        
                        print(done)
                        RemoveBlip(routeblip)
                        if maxpoints == done then
                            finishDeliver(x, y, z, money, name, vehicle)
                        else
                            done = done + 1
                            routeStartNow(name, money, points, vehicle)
                        end
                        break
                    end
                end
            end
        

            if not IsVehicleAttachedToTrailer(vehicle) then
                SendNUIMessage({
                    route = "Vuelve a enganchar el camión"; 
                })
            else
                SendNUIMessage({
                    route = name;
                })
            end
            if not DoesEntityExist(vehicle) then
                ESX.ShowNotification('El vehículo ha sido destruido')
                startJob()
                SendNUIMessage({
                    show = true; 
                })
                break
            end
            Citizen.Wait(wait)
        end

    end,name,done)
    
end

function finishDeliver(x, y, z, money, name, vehicle)
    ESX.ShowNotification('Vuelve a la ubicación de inicio')
    routeblip = AddBlipForCoord(Config.truckSpawn)
    SetBlipRoute(routeblip, true)
    SetBlipScale(routeblip, 0.8)
    SetBlipColour(routeblip, 1)
    SetBlipRouteColour(routeblip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punto para devolver el camión")
    EndTextCommandSetBlipName(routeblip)
    SendNUIMessage({
        route = "regresa a entregar el camión";
    })
    while true do
        local pedcoords = GetEntityCoords(PlayerPedId())
        local wait = 1500
        local dist = GetDistanceBetweenCoords(Config.truckSpawn, pedcoords, true)

        if dist < 5 and IsPedInVehicle(PlayerPedId(), vehicle) then
            wait = 0
            ESX.ShowFloatingHelpNotification('Presiona ~r~E~w~ para entregar el camión', Config.truckSpawn)
            DrawMarker(1, Config.truckSpawn - vector3(0, 0, 0-0.95), 0, 0, 0, 0, 0, 0, 5.0000, 5.0000, 0.6001,255,0,0, 200, 0, 0, 0, 0)
            if IsControlJustPressed(1, 38) then
                RemoveBlip(routeblip)
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
                TriggerServerEvent('guille_trucker:pay', money)
                SendNUIMessage({
                    show = true; 
                    route = ""; 
                })
                startJob()
                break
            end
        end
        if not IsVehicleAttachedToTrailer(vehicle) then
            SendNUIMessage({
                route = "Vuelve a enganchar el camión"; 
            })
        else
            SendNUIMessage({
                route = "regresa a entregar el camión";
            })
        end
        Citizen.Wait(wait)
    end
end
            
-- Fin functions

-- Events

RegisterNetEvent('guille_trucker:getRout')
AddEventHandler('guille_trucker:getRout', function()

    ESX.TriggerServerCallback('guille_trucker:getRoutes', function(result)
        local elements = {}
        for i = 1, #result, 1 do
            table.insert(elements, {
                label = '' .. result[i]['name'] .. ' - ' .. result[i]['money'] .. '$ - ID:' .. result[i]['id'],
                value = {coords = result[i]['coords'], money = result[i]['money'], name = result[i]['name'], id = result[i]['id']}
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_routes', {
            title = ('Rutas'),
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            print(data.current.value['id'])
            --print(data.current.value['coords']['x'] .. ' ' .. data.current.value['money'] .. ' ' .. data.current.value['name'])
        end, function(data, menu)
            menu.close()
        end)
    end)

end)

RegisterNetEvent('guille_trucker:createroute')
AddEventHandler('guille_trucker:createroute', function(name, points)
    local creating = nil
    local points = tonumber(points)
    local created = 0
    creating = true
    while creating do
        ESX.ShowHelpNotification('Creación de ruta. Presiona ~INPUT_CONTEXT~ para añadir punto a la ruta ' ..name.. ' de un total de ' ..points)
        if IsControlJustPressed(1, 38) then
            created = created + 1
            TriggerServerEvent('guille_trucker:addpointtoroute', name, created)
            if created == 1 then
                ESX.ShowNotification('Has añadido un punto a ' ..name.. ' de un total de ' ..points.. '. Llevas ' ..created.. ' creado')
            else
                ESX.ShowNotification('Has añadido un punto a ' ..name.. ' de un total de ' ..points.. '. Llevas ' ..created.. ' creados')
            end         
        end
        if created == points then
            ESX.ShowNotification('Ruta creada correctamente con todos los puntos guardados')
            break
        end
        Citizen.Wait(0)
    end
end)

--TriggerEvent("chat:addSuggestion", "/createroute", ("Crear una ruta para el trabajo de camionero"), {{name = ("Nombre"), help = ("Nombre de la ruta que se va a crear (sólo una palabra)")}, {name = ("Sueldo"), help = ("Dinero que se va a cobrar al hacer la ruta")}})
TriggerEvent("chat:addSuggestion", "/addroute", ("Crear una ruta para el trabajo de camionero"), {{name = ("Puntos"), help = ("Puntos de la ruta que se va a crear (sólo números)")}, {name = ("Nombre"), help = ("Nombre de la ruta que se va a crear (sólo una palabra)")}, {name = ("Dinero"), help = ("Dinero que se va a cobrar al hacer la ruta")}})
TriggerEvent("chat:addSuggestion", "/seeroutes", ("Ver las rutas de camionero creadas"), {})
TriggerEvent("chat:addSuggestion", "/deleteroute", ("Borrar una ruta para del trabajo de camionero"), {{name = ("Nombre"), help = ("Nombre de la ruta que se desea borrar, revisa los nombres con /seeroutes")}})

-- Fin Events

