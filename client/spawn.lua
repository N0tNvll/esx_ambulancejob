function GetClosestRespawnPoint()
    local plyCoords = GetEntityCoords(PlayerPedId())
    local closestDist, closestHospital 
  
    for i=1, #Config.RespawnPoints do 
        local dist = #(plyCoords - Config.RespawnPoints[i].coords) 
  
        if not closestDist or dist <= closestDist then
            closestDist, closestHospital = dist, Config.RespawnPoints[i] 
        end 
    end 
    
    return closestHospital
end

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)

    TriggerEvent('esx_basicneeds:resetStatus')
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
end