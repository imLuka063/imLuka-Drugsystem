local PlayerData                = {}
ESX                             = nil

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local blips = {
    {title="Orangensammler", colour=17, id=478, x = 2438.2000, y =4108.899, z = 37.2245},
    {title="Orangenverarbeiter", colour=17, id=478, x = 2566.7063, y = 4273.8477, z = 28.7083},
    {title="Orangenverkäufer", colour=17, id=478, x = 2507.820, y = 4200.8087, z = 39.9640},   --Blips für Legale Routen
}
      
Citizen.CreateThread(function()
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 0.8)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.KeycardCoords)

        if distance < 2.0 then
            ESX.ShowHelpNotification("um eine Keycard zu kaufen")
            if IsControlJustReleased(0, 38) then 
                ShowKeycardMenu()
            end
        end
    end
end)


---- Keycardshop

function ShowKeycardMenu()
    local keycardLabels = {
        "Weedlabor Keycard - 5000$",
        "Kokainlabor Keycard - 10000§",
    }

    local elements = {}

    for i, busLabel in ipairs(keycardLabels) do
        table.insert(elements, {
            label = i .. '. ' .. busLabel,
            value = i
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'keycard_menu', {
        title = 'Welche Keycard möchtest du nehmen?',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local selectedKeycardIndex = data.current.value
        local selectedKeycardLabel = keycardLabels[selectedKeycardIndex]

        if selectedKeycardLabel == "Weedlabor Keycard - 5000$" then
           TriggerServerEvent('Luka:Weedkeycard')
        elseif selectedKeycardLabel == "Kokainlabor Keycard - 10000§" then
            TriggerServerEvent('Luka:Cokekeycard')
        end
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

--- Weedlabor Teleport

local TeleportCooldown = 1000 
local isTeleporting = false


function TeleportPlayer(coords)
    Citizen.CreateThread(function()
        isTeleporting = true
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
        Citizen.Wait(TeleportCooldown)
        isTeleporting = false
    end)
end


function IsNearCoords(coords, radius)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = GetDistanceBetweenCoords(playerCoords, coords.x, coords.y, coords.z, true)
    return distance <= radius
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsNearCoords(Config.WeedLaborCoords1, 2.0) then
            ESX.ShowHelpNotification("um das Weedlabor zu betreten")

            if IsControlJustReleased(0, 38) and not isTeleporting then
                if HasItem("weedkeycard") or HasItem("weedkeycard75") or HasItem("weedkeycard50") or HasItem("weedkeycard25") then
                    TriggerServerEvent('Luka:Weedcardabuse')
                    TeleportPlayer(Config.WeedLaborCoords2)
                else
                    ESX.ShowNotification("Dir fehlt die Zugangskarte.")
                end
            end
        end

        if IsNearCoords(Config.WeedLaborCoords2, 2.0) then
            ESX.ShowHelpNotification("um das Weedlabor zu verlassen")

            if IsControlJustReleased(0, 38) and not isTeleporting then
                    TeleportPlayer(Config.WeedLaborCoords1)
            end
        end
    end
end)

function HasItem(itemName)
    local inventory = ESX.GetPlayerData().inventory
    for i = 1, #inventory, 1 do
        if inventory[i].name == itemName then
            return true
        end
    end
    return false
end


-- Weedlabor sammeln 

local isCollecting = false
local lastCollectTime = 0
local collectCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Weed1Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isCollecting then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isCollecting then
                ESX.ShowHelpNotification("E zum Sammeln")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isCollecting = not isCollecting -- Umkehrung von true zu false und umgekehrt
                lastCollectTime = GetGameTimer()
            end
        end

        if isCollecting and GetGameTimer() - lastCollectTime >= collectCooldown then
            lastCollectTime = GetGameTimer()
            exports['an_progBar']:run(1, 'Weed sammeln', '#00bfff') -- Fortschrittsleiste für 2 Sekunden anzeigen
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Weedsammeln')
        end

        if not isCollecting then
            ClearPedTasks(playerPed)
        end
    end
end)

--- Weed Verarbeiten

local isWorking = false
local lastWorkTime = 0
local WorkCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Weed2Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isWorking then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isWorking then
                ESX.ShowHelpNotification("zum Verarbeiten")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isWorking = not isWorking -- Umkehrung von true zu false und umgekehrt
                lastWorkTime = GetGameTimer()
            end
        end

        if isWorking and GetGameTimer() - lastWorkTime >= WorkCooldown then
            lastWorkTime = GetGameTimer()
            exports['an_progBar']:run(1, 'Joints rollen', '#00bfff') -- Fortschrittsleiste für 2 Sekunden anzeigen
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Weedverarbeiten')
        end

        if not isWorking then
            ClearPedTasks(playerPed)
        end
    end
end)

-- Weed Verkaufen 

local isSelling = false
local lastSellTime = 0
local SellCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Weed3Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isSelling then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isSelling then
                ESX.ShowHelpNotification("zum Verkaufen")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isSelling = not isSelling -- Umkehrung von true zu false und umgekehrt
                lastSellTime = GetGameTimer()
            end
        end

        if isSelling and GetGameTimer() - lastSellTime >= SellCooldown then
            lastSellTime = GetGameTimer()
            exports['an_progBar']:run(1, 'Verkaufen', '#00bfff') -- Fortschrittsleiste für 2 Sekunden anzeigen
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Weedverkaufen')
        end

        if not isSelling then
            ClearPedTasks(playerPed)
        end
    end
end)




--------   KOKS --------  

--- Cokelabor Teleport

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsNearCoords(Config.KoksLaborCoords1, 2.0) then
            ESX.ShowHelpNotification("um das Kokslabor zu betreten")

            if IsControlJustReleased(0, 38) and not isTeleporting then
                if HasItem("cokekeycard") or HasItem("cokekeycard75") or HasItem("cokekeycard50") or HasItem("cokekeycard25") then
                    TriggerServerEvent('Luka:Cokecardabuse')
                    TeleportPlayer(Config.KoksLaborCoords2)
                else
                    ESX.ShowNotification("Dir fehlt die Zugangskarte.")
                end
            end
        end

        if IsNearCoords(Config.KoksLaborCoords2, 2.0) then
            ESX.ShowHelpNotification("um das Kokslabor zu verlassen")

            if IsControlJustReleased(0, 38) and not isTeleporting then
                    TeleportPlayer(Config.KoksLaborCoords1)
            end
        end
    end
end)

function HasItem(itemName)
    local inventory = ESX.GetPlayerData().inventory
    for i = 1, #inventory, 1 do
        if inventory[i].name == itemName then
            return true
        end
    end
    return false
end


-- Koks sammeln 

local isCollecting2 = false
local lastCollectTime = 0
local collectCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Koks1Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isCollecting2 then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isCollecting2 then
                ESX.ShowHelpNotification("E zum Sammeln")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isCollecting2 = not isCollecting2-- Umkehrung von true zu false und umgekehrt
                lastCollectTime = GetGameTimer()
            end
        end

        if isCollecting2 and GetGameTimer() - lastCollectTime >= collectCooldown then
            lastCollectTime = GetGameTimer()
            
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Kokssammeln')
        end

        if not isCollecting2 then
            ClearPedTasks(playerPed)
        end
    end
end)

-- Koks verarbeiten 


local isWorking2  = false
local lastWorkTime = 0
local WorkCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Koks2Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isWorking2  then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isWorking2  then
                ESX.ShowHelpNotification("zum Verarbeiten")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isWorking2  = not isWorking2  -- Umkehrung von true zu false und umgekehrt
                lastWorkTime = GetGameTimer()
            end
        end

        if isWorking2  and GetGameTimer() - lastWorkTime >= WorkCooldown then
            lastWorkTime = GetGameTimer()
            exports['an_progBar']:run(1, 'Kokain produzieren', '#00bfff') -- Fortschrittsleiste für 2 Sekunden anzeigen
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Koksverarbeiten')
        end

        if not isWorking2  then
            ClearPedTasks(playerPed)
        end
    end
end)


-- Koks verkaufen 

local isSelling2 = false
local lastSellTime = 0
local SellCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Koks3Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isSelling2 then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isSelling2 then
                ESX.ShowHelpNotification("zum Verkaufen")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isSelling2 = not isSelling2 -- Umkehrung von true zu false und umgekehrt
                lastSellTime = GetGameTimer()
            end
        end

        if isSelling2 and GetGameTimer() - lastSellTime >= SellCooldown then
            lastSellTime = GetGameTimer()
            exports['an_progBar']:run(1, 'Verkaufen', '#00bfff') -- Fortschrittsleiste für 2 Sekunden anzeigen
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Koksverkaufen')
        end

        if not isSelling2 then
            ClearPedTasks(playerPed)
        end
    end
end)

--- Orangen sammler

local isCollectingOrange = false
local lastCollectTime = 0
local collectCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Orange1Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isCollectingOrange then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isCollectingOrange then
                ESX.ShowHelpNotification("E zum Sammeln")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isCollectingOrange = not isCollectingOrange-- Umkehrung von true zu false und umgekehrt
                lastCollectTime = GetGameTimer()
            end
        end

        if isCollectingOrange and GetGameTimer() - lastCollectTime >= collectCooldown then
            lastCollectTime = GetGameTimer()
            --exports['an_progBar']:stop()
            TriggerServerEvent('Luka:Osammeln')
        end

        if not isCollectingOrange then
            ClearPedTasks(playerPed)
        end
    end
end)

-- Orange verarbeiten 


local isWorkingOrange  = false
local lastWorkTime = 0
local WorkCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Orange2Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isWorkingOrange  then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isWorkingOrange  then
                ESX.ShowHelpNotification("E zum Verarbeiten")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isWorkingOrange  = not isWorkingOrange  -- Umkehrung von true zu false und umgekehrt
                lastWorkTime = GetGameTimer()
            end
        end

        if isWorkingOrange  and GetGameTimer() - lastWorkTime >= WorkCooldown then
            lastWorkTime = GetGameTimer()
            TriggerServerEvent('Luka:Overarbeiten')
        end

        if not isWorkingOrange  then
            ClearPedTasks(playerPed)
        end
    end
end)

-- Orangen verkaufen 

local isSellingOrange = false
local lastSellTime = 0
local SellCooldown = 3000 -- 3 Sekunden in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.Orange3Coords)
        local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO: Bessere Animationen

        if isSellingOrange then
            RequestAnimDict(lib)

            while not HasAnimDictLoaded(lib) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

        end

        if distance < 2.0 then
            if not isSellingOrange then
                ESX.ShowHelpNotification("E zum Verkaufen")
            else
                ESX.ShowHelpNotification("E zum Aufhören")
            end

            if IsControlJustReleased(0, 38) then
                isSellingOrange = not isSellingOrange -- Umkehrung von true zu false und umgekehrt
                lastSellTime = GetGameTimer()
            end
        end

        if isSellingOrange and GetGameTimer() - lastSellTime >= SellCooldown then
            lastSellTime = GetGameTimer()
            TriggerServerEvent('Luka:Overkaufen')
        end

        if not isSellingOrange then
            ClearPedTasks(playerPed)
        end
    end
end)