playersHealing, deadPlayers = {}, {}

function getDeadState(src)
    if not src then return nil end

    if deadPlayers[src] then
        return true
    end

	return false
end

function isDeadState(src, bool)
	if not src or bool == nil then return end

	Player(src).state:set('isDead', bool, true)
end

RegisterNetEvent('esx_ambulancejob:revive', function(playerId)
	playerId = tonumber(playerId)
	local xPlayer = source and ESX.GetPlayerFromId(source)

	if xPlayer and xPlayer.job.name == 'ambulance' then
		local xTarget = ESX.GetPlayerFromId(playerId)
		if xTarget then
			if deadPlayers[playerId] then
				if Config.ReviveReward > 0 then
					xPlayer.showNotification(TranslateCap('revive_complete_award', xTarget.name, Config.ReviveReward))
					xPlayer.addMoney(Config.ReviveReward, "Revive Reward")
					xTarget.triggerEvent('esx_ambulancejob:revive')
					isDeadState(xTarget.source, false)
				else
					xPlayer.showNotification(TranslateCap('revive_complete', xTarget.name))
					xTarget.triggerEvent('esx_ambulancejob:revive')
					isDeadState(xTarget.source, false)
				end
				local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

				for _, xPlayer in pairs(Ambulance) do
					if xPlayer.job.name == 'ambulance' then
						xPlayer.triggerEvent('esx_ambulancejob:PlayerNotDead', playerId)
					end
				end
				deadPlayers[playerId] = nil
			else
				xPlayer.showNotification(TranslateCap('player_not_unconscious'))
			end
		else
			xPlayer.showNotification(TranslateCap('revive_fail_offline'))
		end
	end
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
	local source = source
	deadPlayers[source] = 'dead'
	local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")
	isDeadState(source, true)

	for _, xPlayer in pairs(Ambulance) do
		xPlayer.triggerEvent('esx_ambulancejob:PlayerDead', source)
	end
end)

RegisterServerEvent('esx_ambulancejob:svsearch', function()
	TriggerClientEvent('esx_ambulancejob:clsearch', -1, source)
end)

RegisterNetEvent('esx_ambulancejob:onPlayerDistress', function()
	local source = source
	local injuredPed = GetPlayerPed(source)
	local injuredCoords = GetEntityCoords(injuredPed)

	if deadPlayers[source] then
		deadPlayers[source] = 'distress'
		local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			xPlayer.triggerEvent('esx_ambulancejob:PlayerDistressed', source, injuredCoords)
		end
	end
end)

RegisterNetEvent('esx_ambulancejob:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulancejob:heal', target, type)
	end
end)

RegisterNetEvent('esx_ambulancejob:setDeathStatus', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { isDead, xPlayer.identifier })
		isDeadState(source, isDead)
			
		if not isDead then
			local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")
			for _, xPlayer in pairs(Ambulance) do
				xPlayer.triggerEvent('esx_ambulancejob:PlayerNotDead', source)
			end
		end
	end

end)