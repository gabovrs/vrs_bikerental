local veh = nil
local pay = 0

Citizen.CreateThread(function()
    local wait = 1500
    CreateBlip()
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())
        local inRange = false

        for k, v in pairs(Config.Locations) do
            if #(pedCoords - v) < 9 then
                inRange = true
                if IsPedSittingInVehicle(PlayerPedId(), veh) then
                    DrawText3Ds(v, _U('return_bike'))
                    DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                    if IsControlJustPressed(0, 38) then
                        ReturnBike()
                    end 
                else
                    DrawText3Ds(v, _U('open_menu'))
                    DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 0, 200, 0, 222, false, false, false, true, false, false, false)
                    if IsControlJustPressed(0, 38) then
                        OpenMenu()
                    end 
                end
            end
        end

        if inRange then
            wait = 7
        else
            if ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'bikerental') then
                ESX.UI.Menu.CloseAll()
            end
            wait = 1500
        end

        Citizen.Wait(wait)
    end
end)

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(coords.x, coords.y, coords.z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end

function ReturnBike()
    DoScreenFadeOut(100)
    Citizen.Wait(1000)
    NetworkFadeOutEntity(veh, true, true)
    DoScreenFadeIn(100)
    Citizen.Wait(1000)
    ESX.Game.DeleteVehicle(veh)
    veh = nil
    local pay = pay / 2
    if pay < Config.MaxPrice then
        TriggerServerEvent('vrs_bikerental:server:returnmoney', pay)
        exports['t-notify']:Custom({
            style  =  'success',
            duration = 3000,
            message  =  _U('returnmoney', pay),
        })
        pay = 0
    end
end

function OpenMenu()

    ESX.UI.Menu.CloseAll()

    local elements = {}

    for k,v in pairs(Config.Menu) do
        table.insert(elements, {
            label = _U(v.model, v.price), value = v.model, value2 = v.price
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bikerental', {
        title = _U('menu_title'),
        align = 'center',
        elements = elements
    }, function(data, menu)
        menu.close()

        local model = data.current.value
        local price = data.current.value2

        ESX.TriggerServerCallback('vrs_bikerental:server:checkMoney', function(hasEnoughMoney)
            if hasEnoughMoney then
                TriggerServerEvent('vrs_bikerental:server:pay', price)
                pay = price
                DoScreenFadeOut(100)
                Citizen.Wait(1000)
                ESX.Game.SpawnVehicle(model, GetEntityCoords(PlayerPedId()), 0.0, function(vehicle)
                    veh = vehicle
                    print(vehicle)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    NetworkFadeOutEntity(veh, true, true)
                end)
                DoScreenFadeIn(500)
                Citizen.Wait(1000)
                NetworkFadeInEntity(veh, false, true)

                exports['t-notify']:Custom({
                    style  =  'success',
                    duration = 3000,
                    message  =  _U('success', price),
                })
            else
                exports['t-notify']:Custom({
                    style  =  'error',
                    duration = 3000,
                    message  =  _U('not_enough_money'),
                })
            end
        end, price)
        
    end, function(data, menu)
		menu.close()
	end)
end

function CreateBlip()
    for k, v in pairs(Config.Locations) do
        local blip = AddBlipForCoord(v)

        SetBlipSprite (blip, 376)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
    
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U('blip'))
        EndTextCommandSetBlipName(blip)
    end
end