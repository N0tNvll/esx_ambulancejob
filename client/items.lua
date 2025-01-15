RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
  ESX.CloseContext()

  if itemName == 'medikit' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'big', true)
      ESX.ShowNotification(TranslateCap('used_medikit'))
    end)

  elseif itemName == 'bandage' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'small', true)
      ESX.ShowNotification(TranslateCap('used_bandage'))
    end)
  end
end)

RegisterNetEvent('esx_ambulancejob:RemoveItemsAfterRPDeath', function()
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
  
    CreateThread(function()
      ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
        local ClosestHospital = GetClosestRespawnPoint()
  
        ESX.SetPlayerData('loadout', {})
  
        DoScreenFadeOut(800)
        RespawnPed(PlayerPedId(), ClosestHospital.coords, ClosestHospital.heading)
        while not IsScreenFadedOut() do
          Wait(0)
        end
        DoScreenFadeIn(800)
      end)
    end)
end)