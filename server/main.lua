ESX               = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('Luka:Weedkeycard')     ----- WEEDKEYCARD KAUFEN
AddEventHandler('Luka:Weedkeycard', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = Config.Weedkeycarditem
    local count = 1
    local money = 5000
    local account = Config.BuyKeycardAccount
    xPlayer.removeAccountMoney(account, money)
    xPlayer.addInventoryItem(item, count)
end)


RegisterServerEvent('Luka:Weedcardabuse')
AddEventHandler('Luka:Weedcardabuse', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = Config.Weedkeycarditem
    local item2 = Config.Weedkeycarditem75
    local item3 = Config.Weedkeycarditem50
    local item4 = Config.Weedkeycarditem25
    local count = 1

    local hasItem = false

    if xPlayer.getInventoryItem(item).count > 0 then 
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem(item2, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item2).count > 0 then 
        xPlayer.removeInventoryItem(item2, count)
        xPlayer.addInventoryItem(item3, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item3).count > 0 then 
        xPlayer.removeInventoryItem(item3, count)
        xPlayer.addInventoryItem(item4, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item4).count > 0 then
        xPlayer.removeInventoryItem(item4, count)
        TriggerClientEvent('esx:showNotification', _source, "Deine Keycard ist nun defekt.")
        hasItem = true
    end

    if not hasItem then
        TriggerClientEvent('esx:showNotification', _source, "Du besitzt keine gültige Keycard.")
    end
end)


RegisterServerEvent('Luka:Cokekeycard')    --- KOKSKEYCARD KAUFEN
AddEventHandler('Luka:Cokekeycard', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = Config.Cokekeycarditem
    local count = 1
    local money = 10000
    local account = Config.BuyKeycardAccount
    xPlayer.removeAccountMoney(account, money)
    xPlayer.addInventoryItem(item, count)
end)


RegisterServerEvent('Luka:Cokecardabuse')
AddEventHandler('Luka:Cokecardabuse', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = Config.Cokekeycarditem
    local item2 = Config.Cokekeycarditem75
    local item3 = Config.Cokekeycarditem50
    local item4 = Config.Cokekeycarditem25
    local count = 1

    local hasItem = false

    if xPlayer.getInventoryItem(item).count > 0 then 
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem(item2, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item2).count > 0 then 
        xPlayer.removeInventoryItem(item2, count)
        xPlayer.addInventoryItem(item3, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item3).count > 0 then 
        xPlayer.removeInventoryItem(item3, count)
        xPlayer.addInventoryItem(item4, count)
        hasItem = true
    elseif xPlayer.getInventoryItem(item4).count > 0 then
        xPlayer.removeInventoryItem(item4, count)
        TriggerClientEvent('esx:showNotification', _source, "Deine Keycard ist nun defekt.")
        hasItem = true
    end

    if not hasItem then
        TriggerClientEvent('esx:showNotification', _source, "Du besitzt keine gültige Keycard.")
    end
end)

RegisterServerEvent('Luka:Weedsammeln')   --- WEED SAMMELN
AddEventHandler('Luka:Weedsammeln', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'weed1'
    local count = 1
    xPlayer.addInventoryItem(item, count)
end)

RegisterServerEvent('Luka:Weedverarbeiten')  -- WEED VERARBEITEN
AddEventHandler('Luka:Weedverarbeiten', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'weed1'
    local count = 10
    local item2 = 'weed2'
    local count2 = 1

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem(item2, count2)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast Joints gerollt.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug Weed zum Verarbeiten.')
    end
end)

RegisterServerEvent('Luka:Weedverkaufen') -- WEED VERKAUFEN
AddEventHandler('Luka:Weedverkaufen', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'weed2'
    local count = 10
    local account = Config.SellMoneyAccount
    local money = 10000

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addAccountMoney(account, money)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast Joints verkauft.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug Joints.')
    end
end)

RegisterServerEvent('Luka:Kokssammeln')   --- KOKS SAMMELN
AddEventHandler('Luka:Kokssammeln', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'koks1'
    local count = 1
    xPlayer.addInventoryItem(item, count)
end)


RegisterServerEvent('Luka:Koksverarbeiten')  -- KOKS VERARBEITEN
AddEventHandler('Luka:Koksverarbeiten', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'koks1'
    local count = 10
    local item2 = 'koks2'
    local count2 = 1

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem(item2, count2)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast Koks produziert.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug Kokablätter zum Verarbeiten.')
    end
end)


RegisterServerEvent('Luka:Koksverkaufen') -- KOKS VERKAUFEN
AddEventHandler('Luka:Koksverkaufen', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'koks2'
    local count = 10
    local account = Config.SellMoneyAccount
    local money = 10000

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addAccountMoney(account, money)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast Koks verkauft.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug Koks.')
    end
end)



RegisterServerEvent('Luka:Osammeln')   --- Orangen SAMMELN
AddEventHandler('Luka:Osammeln', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'orange1'
    local count = 1
    xPlayer.addInventoryItem(item, count)
end)

RegisterServerEvent('Luka:Overarbeiten')  -- Orange VERARBEITEN
AddEventHandler('Luka:Overarbeiten', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'orange1'
    local count = 10
    local item2 = 'orange2'
    local count2 = 1

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addInventoryItem(item2, count2)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast O-Saft produziert.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug Orangen zum Verarbeiten.')
    end
end)

RegisterServerEvent('Luka:Overkaufen') -- Orange VERKAUFEN
AddEventHandler('Luka:Overkaufen', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local item = 'orange2'
    local count = 5
    local account = Config.SellMoneyAccountLegal
    local money = 7000

    local currentCount = xPlayer.getInventoryItem(item).count
    if currentCount >= count then
        xPlayer.removeInventoryItem(item, count)
        xPlayer.addAccountMoney(account, money)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast O-Saft verkauft.') 
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nicht genug O-Saft.')
    end
end)