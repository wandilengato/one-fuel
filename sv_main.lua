ESX                  = nil



TriggerEvent('esx:getSharedObject', function(obj)
    
    ESX = obj

end)



RegisterNetEvent('one-fuel:initFuel')

AddEventHandler('one-fuel:initFuel', function(sentVeh)

    local veh = NetworkGetEntityFromNetworkId(sentVeh)


    if veh ~= 0 then

        Entity(veh).state.fuel = math.random(40, 60)

    end

end)



RegisterServerEvent('one-fuel:PurchaseSuccessful')

AddEventHandler('one-fuel:PurchaseSuccessful', function(price)

    local xPlayer = ESX.GetPlayerFromId(source)

    local amount = ESX.Math.Round(price)


    if price > 0 then
    
        xPlayer.removeMoney(amount)
    
    end

end)