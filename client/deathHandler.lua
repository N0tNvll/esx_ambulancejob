RegisterNetEvent('esx_ambulancejob:clsearch')
AddEventHandler('esx_ambulancejob:clsearch', function(medicId)
  local playerPed = PlayerPedId()

  if isDead then
    local coords = GetEntityCoords(playerPed)
    local playersInArea = ESX.Game.GetPlayersInArea(coords, 50.0)

    for i = 1, #playersInArea, 1 do
      local player = playersInArea[i]
      if player == GetPlayerFromServerId(medicId) then
        medic = tonumber(medicId)
        isSearched = true
        break
      end
    end
  end
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  local formattedCoords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1)}

  RespawnPed(playerPed, formattedCoords, 0.0)
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  TriggerEvent('esx_deathscreen:endDeathCam') 
  DoScreenFadeIn(800)
end)

function revivePlayer(closestPlayer)
	isBusy = true

	ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
		if quantity > 0 then
			local closestPlayerPed = GetPlayerPed(closestPlayer)

			if IsPedDeadOrDying(closestPlayerPed, 1) then
				local playerPed = PlayerPedId()
				local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
				ESX.ShowNotification(TranslateCap('revive_inprogress'))

				for i = 1, 15 do
					Wait(900)

					ESX.Streaming.RequestAnimDict(lib, function()
						TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
						RemoveAnimDict(lib)
					end)
				end

				TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
				TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
			else
				ESX.ShowNotification(TranslateCap('player_not_unconscious'))
			end
		else
			ESX.ShowNotification(TranslateCap('not_enough_medikit'))
		end
		isBusy = false
	end, 'medikit')
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if Config.Debug then
		print("[^2INFO^7] Healing Player - ^5" .. tostring(healType) .. "^7")
	end
	if not quiet then
		ESX.ShowNotification(TranslateCap('healed'))
	end
end)

RegisterNetEvent('esx_ambulancejob:PlayerDead')
AddEventHandler('esx_ambulancejob:PlayerDead', function(Player)
	if Config.Debug then
		print("[^2INFO^7] Player Dead | ^5" .. tostring(Player) .. "^7")
	end
	deadPlayers[Player] = "dead"
end)

RegisterNetEvent('esx_ambulancejob:PlayerNotDead')
AddEventHandler('esx_ambulancejob:PlayerNotDead', function(Player)
	if deadPlayerBlips[Player] then
		RemoveBlip(deadPlayerBlips[Player])
		deadPlayerBlips[Player] = nil
	end
	if Config.Debug then
		print("[^2INFO^7] Player Alive | ^5" .. tostring(Player) .. "^7")
	end
	deadPlayers[Player] = nil
end)

RegisterNetEvent('esx_ambulancejob:setDeadPlayers')
AddEventHandler('esx_ambulancejob:setDeadPlayers', function(_deadPlayers)
	deadPlayers = _deadPlayers

	if isOnDuty then
		for playerId, v in pairs(deadPlayerBlips) do
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		for playerId, status in pairs(deadPlayers) do
			if Config.Debug then
				print("[^2INFO^7] Player Dead | ^5" .. tostring(playerId) .. "^7")
			end
			if status == 'distress' then
				if Config.Debug then
					print("[^2INFO^7] Creating Distress Blip for Player - ^5" .. tostring(playerId) .. "^7")
				end
				local player = GetPlayerFromServerId(playerId)
				local playerPed = GetPlayerPed(player)
				local blip = AddBlipForEntity(playerPed)

				SetBlipSprite(blip, 303)
				SetBlipColour(blip, 1)
				SetBlipFlashes(blip, true)
				SetBlipCategory(blip, 7)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
				EndTextCommandSetBlipName(blip)

				deadPlayerBlips[playerId] = blip
			end
		end
	end
end)

RegisterNetEvent('esx_ambulancejob:PlayerDistressed')
AddEventHandler('esx_ambulancejob:PlayerDistressed', function(playerId, playerCoords)
	deadPlayers[playerId] = 'distress'

	if isOnDuty then
		if Config.Debug then
			print("[^2INFO^7] Player Distress Recived - ID:^5" .. tostring(playerId) .. "^7")
		end
		ESX.ShowNotification(TranslateCap('unconscious_found'), "error", 10000)
		deadPlayerBlips[playerId] = nil

		local blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		SetBlipSprite(blip, Config.DistressBlip.Sprite)
		SetBlipColour(blip, Config.DistressBlip.Color)
		SetBlipScale(blip, Config.DistressBlip.Scale)
		SetBlipFlashes(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
		EndTextCommandSetBlipName(blip)

		deadPlayerBlips[playerId] = blip
	end
end)